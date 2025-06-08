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

class Validierungsmanager {
  Validierungsmanager._();
  
  // Logging included
  static Future<void> AddSammelkarteNFCGPS(BuildContext context, int ZielID) async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/erfolg/ziel?zielID=$ZielID');
    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode != 200) {
        logger.w('Fehler beim Abfragen des Ziel $ZielID');
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
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
      return;
    }
    final result = json.decode(response.body);
    Location _location = Location();
    final currentLocation = await _location.getLocation();

    double distanceInMeters = Geolocator.distanceBetween(
      result['lat'], result['lng'],
      result['lat'] ?? 0, result['lng'] ?? 0,
    );
    
    if (distanceInMeters <= 500){
      // User ist in der nähe des Zieles (500m) & Ziel kann in DB gespeichert werden
      final url = Uri.parse('http://$serverIP:8080/erfolg/add_erreichtesziel');

      final body = json.encode({
        "UID": id,
        "ZID": ZielID
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 400){
        logger.w('User $id hat Ziel $ZielID schon');
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
      else if (response.statusCode != 201){
        logger.w('Fehler beim Hinzufügend des Ziels $ZielID zum User $id');
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
    else{
      logger.w('Fehler beim Hinzufügend des Ziels $ZielID zum User $id, da er sich nicht in der Nähe davon befindet --> $distanceInMeters m entfernt');
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
      logger.i('Ziel $ZielID erfolgreich zum User $id hinzugefügt!');
    }
  }
}