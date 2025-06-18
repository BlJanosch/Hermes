import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hermes/components/globals.dart';
import 'package:hermes/pages/home.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manager-Klasse für Validierungslogik rund um Sammelkarten und GPS-Überprüfung.
///
/// Die Klasse enthält statische Methoden, um Sammelkarten-Ziele mit
/// GPS-Standortdaten und NFC-Validierung hinzuzufügen.
///
/// Verhindert Instanziierung durch privaten Konstruktor.
class Validierungsmanager {
  Validierungsmanager._();

  /// Versucht, eine Sammelkarte (Ziel) dem Benutzer hinzuzufügen, sofern dieser
  /// sich in der Nähe (500 Meter) des Zielortes befindet.
  ///
  /// - Liest die aktuelle Benutzer-ID aus SharedPreferences aus.
  /// - Fragt die Ziel-Details (inkl. Latitude/Longitude) vom Server ab.
  /// - Holt die aktuelle Position des Geräts über Geolocator.
  /// - Berechnet die Distanz zwischen aktuellem Standort und Zielkoordinaten.
  /// - Fügt das Ziel über einen POST-Request dem Benutzer hinzu, wenn Distanz <= 500m.
  ///
  /// Parameter:
  /// - [context] (optional): BuildContext zum Anzeigen von Dialogen bei Fehlern.
  /// - [ZielID]: ID des Zieles, das hinzugefügt werden soll.
  /// - [client] (optional): HTTP-Client zur Verwendung (für Tests).
  ///
  /// Fehlerbehandlung:
  /// - Bei Netzwerkproblemen oder Serverfehlern wird eine AlertDialog mit Fehlermeldung angezeigt.
  /// - Wenn das Ziel bereits im Besitz des Benutzers ist, wird ein entsprechender Dialog angezeigt.
  /// - Wenn das Ziel nicht in der Nähe ist, wird der Benutzer darauf hingewiesen.
  ///
  /// Logs:
  /// - Erfolgs- und Fehlerzustände werden geloggt.
  static Future<void> AddSammelkarteNFCGPS(BuildContext? context, int ZielID, {http.Client? client, }) async {
    client ??= http.Client();
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/erfolg/ziel?zielID=$ZielID');
    http.Response response;
    try {
      response = await client.get(url);
      if (response.statusCode != 200) {
        logger.w('Fehler beim Abfragen des Ziel $ZielID');
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      logger.w('Konnte keine Verbindung zum Server herstellen: $e');
      if (context != null){
        showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Verbindungsfehler'),
          content: Text('Konnte keine Verbindung zum Server herstellen: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      }
      return;
    }
    final result = json.decode(response.body);
    Location _location = Location();

    final currentPosition = await Geolocator.getCurrentPosition();
    logger.i(currentPosition);
    double distanceInMeters = Geolocator.distanceBetween(
      result['lat'], result['lng'],
      currentPosition.latitude, currentPosition.longitude,
    );

    logger.i(distanceInMeters);
    
    if (distanceInMeters <= 500){
      // User ist in der nähe des Zieles (500m) & Ziel kann in DB gespeichert werden
      final url = Uri.parse('http://$serverIP:8080/erfolg/add_erreichtesziel');

      final body = json.encode({
        "UID": id,
        "ZID": ZielID
      });

      final response = await client.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 400){
        logger.w('User $id hat Ziel $ZielID schon');
        if (context != null){
          showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Fehler beim Hinzufügen!'),
            content: Text('Ziel befindet sich bereits in deinem Besitz!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        }  
      }
      else if (response.statusCode != 201){
        logger.w('Fehler beim Hinzufügend des Ziels $ZielID zum User $id');
        if (context != null){
          showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Fehler beim Hinzufügen!'),
            content: Text('Ziel konnte nicht hinzugefügt werden!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        }
      }
    }
    else{
      logger.w('Fehler beim Hinzufügend des Ziels $ZielID zum User $id, da er sich nicht in der Nähe davon befindet --> $distanceInMeters m entfernt');
      if (context != null){
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Fehler beim Hinzufügen!'),
            content: Text('Du musst dich in der Nähe vom Ziel befinden, um es hinzufügen zu können!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      logger.i('Ziel $ZielID erfolgreich zum User $id hinzugefügt!');
    }
  }
}