import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hermes/erfolg.dart';
import 'package:hermes/erfolgCollection.dart';
import 'package:hermes/sammelkarte.dart';
import 'package:hermes/sammelkarteCollection.dart';
import 'package:hermes/schwierigkeit.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermes/components/globals.dart';

class UserManager {
  // Privater Konstruktor verhindert Instanziierung
  UserManager._();
  
  // Logging included
  // UnitTest
  static Future<bool> Login(BuildContext? context, String username, String password, {http.Client? client,}) async {
    client ??= http.Client(); // Normalfall, das andere ist nur für die Unit-Tests
    final url = Uri.parse('http://$serverIP:8080/user/login?benutzername=$username&passwort=$password');
    final response = await client.get(url);
    final result = json.decode(response.body);
    if (result == -1){
      logger.w('Login fehlgeschlagen!');
      if (context != null){
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login fehlgeschlagen'),
            content: Text('Benutzername oder Passwort ist falsch.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', result);
    await prefs.setString('username', username);
    await prefs.setBool('isLoggedIn', true);

    logger.i('Login erfolgreich');
    return true;
  }

  // Logging included
  // UnitTest
  static Future<bool> Register(BuildContext? context, String username, String password, {http.Client? client, }) async {
    client ??= http.Client();
    final url = Uri.parse('http://$serverIP:8080/user/register');

    final body = json.encode({
      "Benutzername": username,
      "Passwort": password,
      "Profilbild": "Profilbild"
    });

    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    );

    if (response.statusCode != 200){
      logger.w("Regestrierung fehlgeschlagen");
      if (context != null){
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Regestrierung fehlgeschlagen'),
            content: Text('User existiert bereits'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    final urlLogin = Uri.parse('http://$serverIP:8080/user/login?benutzername=$username&passwort=$password');
    final responseLogin = await client.get(urlLogin);
    final resultLogin = json.decode(responseLogin.body);
    print(resultLogin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', resultLogin);
    await prefs.setString('username', username);
    await prefs.setBool('isLoggedIn', true);

    logger.i('Regestrierung war erfolgreich');
    return true;
  }

  // Logging inclueded
  // UnitTest
  static Future<Map<String, dynamic>> loadUserData({http.Client? client, }) async {
    client ??= http.Client();
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/user/datenabfrage?user_id=$id');
    final response = await client.get(url);
    if (response.statusCode == 401){
      logger.w('User not found');
      throw Exception('User not found');
    }
    final result = json.decode(response.body);
    final urlBerge = Uri.parse('http://$serverIP:8080/erfolg/erreichteziele?userID=$id');
    final responseBerge = await client.get(urlBerge);
    if (responseBerge.statusCode != 200){
      logger.w('Ungülte Eingabe/Fehler bei Ziel-Abfrage');
      throw Exception('Ungültige Eingabe/Fehler bei Ziel-Abfrage');
    }
    final resultBerge = json.decode(responseBerge.body);
    logger.i('Benutzerdaten erfolgreich geladen');
    return {
      'username': prefs.getString('username') ?? 'Unbekannt',
      'kmgelaufen': result['kmgelaufen'] ?? 0,
      'hoehenmeter': result['hoehenmeter'] ?? 0,
      'berge': resultBerge.length ?? 0,
    };
  }

  // Logging included
  // UnitTest
  static Future<List<Erfolg>> loadUserErfolge({http.Client? client, }) async {
    client ??= http.Client();
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/erfolg/get_erfolge?userID=$id');
    final response = await client.get(url);
    if (response.statusCode != 200){
      logger.w('Fehler beim Laden der Erfolge');
      throw Exception('Fehler beim Laden der Erfolge!');
    }
    final result = json.decode(response.body);
    print(result);
    logger.i('Erfolge erfolgreich geladen');
    return (result as List)
      .map((e) => Erfolg.fromJson(e as Map<String, dynamic>))
      .toList();
  }

  // Logging included
  // UnitTest
  static Future<List<Erfolg>> loadAllErfolge(ErfolgCollection userErfolge, {http.Client? client, }) async {
    client ??= http.Client();
    final url = Uri.parse('http://$serverIP:8080/erfolg/get_allerfolge');
    final response = await client.get(url);
    if (response.statusCode != 200){
      logger.w('Fehler beim Laden aller Erfolge');
      throw Exception('Fehler beim Laden aller Erfolge');
    }
    final result = json.decode(response.body);
    ErfolgCollection allErfolge = ErfolgCollection();
    for (int x = 0; x < result.length; x++) {
      final newErfolg = Erfolg.fromJson(result[x] as Map<String, dynamic>);
      final alreadyExists = userErfolge.ergebnisse.any((e) => e.name == newErfolg.name);
      if (!alreadyExists) {
        allErfolge.ergebnisse.add(newErfolg);
      }
    }
    logger.i('Alle Erfolge erfolgreich geladen');
    return allErfolge.ergebnisse;
  }

  // Logging included
  // UnitTest
  static Future<void> checkErfolge(BuildContext? context, {http.Client? client, }) async {
    client ??= http.Client();
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/erfolg/check_erfolge?userID=$id');
    final response = await client.get(url);
    if (response.statusCode != 200){
      logger.w('Fehler bei der Abfrage, ob ein neuer Erfolg freigeschaltet wurde');
      throw Exception('Fehler bei der Abfrage, ob ein neuer Erfolg freigeschaltet wurde');
    }
    final result = json.decode(response.body);
    
    if (result){
      logger.i('Erfolge erfolgreich überprüft');
      if (context != null){
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Neuer Erfolg!'),
            content: Text('Neuer Erfolg freischalten'),
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

  // Logging included
  // UnitTest
  static Future<void> updateStats(double distance, {http.Client? client, }) async {
    client ??= http.Client();
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/user/update_stats');

    final body = json.encode({
      "hoehenmeter": 0, // Höhenmeter noch umsetzen
      "id": id,
      "kmgelaufen": (distance / 1000)
    });

    final response = await client.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    );

    print(response.statusCode);
    if (response.statusCode != 200){
      logger.w('Fehler beim Aktualisierung der Stats');
      throw Exception('Fehler beim Aktualisierung der Stats');
    }
    logger.i('Stats erfolgreich aktualisiert');
  }

  // Logging included
  // UnitTest
  static Future<SammelkarteCollection> getZiele({http.Client? client, }) async {
    client ??= http.Client();
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/erfolg/erreichteziele?userID=$id');
    final response = await client.get(url);

    if (response.statusCode != 200) {
      logger.w('Fehler beim Abrufen der erreichten Ziele');
      throw Exception('Fehler beim Abrufen der erreichten Ziele');
    }

    logger.i('Ziele erfolgreich abgerufen');
    final List<dynamic> jsonList = json.decode(response.body);
    logger.i('Ziele: $jsonList');

    final collection = SammelkarteCollection();

    for (var ziel in jsonList) {
      final karte = Sammelkarte(
        ziel['Name'],
        ziel['Bild'],
        Schwierigkeit.values[ziel['Schwierigkeit']],
        ziel['hoehe'].toDouble(),
        DateTime.parse(ziel['datum']),
      );
      collection.sammelkarten.add(karte);
    }


    return collection;
  }
}