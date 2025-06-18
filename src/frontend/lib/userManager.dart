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

/// Verwaltungsklasse für Benutzeraktionen wie Login, Registrierung
/// und Laden von Benutzerdaten, Erfolgen und Statistiken.
class UserManager {
  // Privater Konstruktor verhindert Instanziierung
  UserManager._();

  /// Führt einen Login-Versuch mit [username] und [password] durch.
  ///
  /// Optionale [client]-Instanz ermöglicht das Einspritzen eines eigenen HTTP-Clients (für Unit-Tests).
  /// Optionaler [context] wird für das Anzeigen von Dialogen im UI verwendet.
  ///
  /// Gibt `true` zurück, wenn der Login erfolgreich war, andernfalls `false`.
  ///
  /// Zeigt bei Fehlern eine Fehlermeldung im Dialog an (wenn [context] gesetzt).
  static Future<bool> Login(
    BuildContext? context,
    String username,
    String password, {
    http.Client? client,
  }) async {
    client ??= http.Client();
    final url = Uri.parse(
      'http://$serverIP:8080/user/login?benutzername=$username&passwort=$password',
    );
    final response = await client.get(url);
    final result = json.decode(response.body);
    if (result == -1) {
      logger.w('Login fehlgeschlagen!');
      if (context != null) {
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

  /// Registriert einen neuen Benutzer mit [username] und [password].
  ///
  /// Optional kann ein eigener HTTP-Client [client] übergeben werden (Unittests).
  /// Optionaler [context] zeigt bei Fehlern Dialoge im UI an.
  ///
  /// Gibt `true` zurück, wenn die Registrierung erfolgreich war, andernfalls `false`.
  static Future<bool> Register(
    BuildContext? context,
    String username,
    String password, {
    http.Client? client,
  }) async {
    client ??= http.Client();
    final url = Uri.parse('http://$serverIP:8080/user/register');

    final body = json.encode({
      "Benutzername": username,
      "Passwort": password,
      "Profilbild": "Profilbild",
    });

    final response = await client.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode != 200) {
      logger.w("Registrierung fehlgeschlagen");
      if (context != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Registrierung fehlgeschlagen'),
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

    final urlLogin = Uri.parse(
      'http://$serverIP:8080/user/login?benutzername=$username&passwort=$password',
    );
    final responseLogin = await client.get(urlLogin);
    final resultLogin = json.decode(responseLogin.body);
    print(resultLogin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', resultLogin);
    await prefs.setString('username', username);
    await prefs.setBool('isLoggedIn', true);

    logger.i('Registrierung war erfolgreich');
    return true;
  }

  /// Lädt die Benutzerdaten vom Server und gibt sie als Map zurück.
  ///
  /// Optionale Übergabe eines HTTP-Clients [client].
  /// 
  /// Gibt ein Map mit Feldern wie `username`, `kmgelaufen`, `hoehenmeter`,
  /// `passwort`, `profilbild` und `berge` zurück.
  /// Bei Fehlern wird eine leere Map zurückgegeben.
  static Future<Map<String, dynamic>> loadUserData({http.Client? client}) async {
    client ??= http.Client();
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/user/datenabfrage?user_id=$id');
    final response = await client.get(url);
    if (response.statusCode == 401) {
      logger.w('User not found');
      return {};
    }
    final result = json.decode(response.body);
    final urlBerge = Uri.parse('http://$serverIP:8080/erfolg/erreichteziele?userID=$id');
    final responseBerge = await client.get(urlBerge);
    if (responseBerge.statusCode != 200) {
      logger.w('Ungültige Eingabe/Fehler bei Ziel-Abfrage');
    }
    final resultBerge = json.decode(responseBerge.body);
    logger.i('Benutzerdaten erfolgreich geladen');
    return {
      'username': prefs.getString('username') ?? 'Unbekannt',
      'kmgelaufen': result['kmgelaufen'] ?? 0,
      'hoehenmeter': result['hoehenmeter'] ?? 0,
      'passwort': result['Passwort'] ?? '',
      'profilbild': result['Profilbild'] ?? '',
      'berge': resultBerge.length ?? 0,
    };
  }

  /// Lädt die Erfolge des Benutzers als Liste von [Erfolg]-Objekten.
  ///
  /// Optionale Übergabe eines HTTP-Clients [client] (Unittests).
  ///
  /// Wirft eine Exception, wenn die Erfolge nicht geladen werden können.
  static Future<List<Erfolg>> loadUserErfolge({http.Client? client}) async {
    client ??= http.Client();
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/erfolg/get_erfolge?userID=$id');
    final response = await client.get(url);
    if (response.statusCode != 200) {
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

  /// Lädt alle verfügbaren Erfolge vom Server, ohne die Erfolge des Benutzers zu duplizieren.
  ///
  /// Übergibt die bereits geladenen Nutzer-Erfolge in [userErfolge], um Duplikate zu filtern.
  ///
  /// Optionale Übergabe eines HTTP-Clients [client] (Unittests).
  ///
  /// Wirft eine Exception bei Fehlern.
  static Future<List<Erfolg>> loadAllErfolge(
    ErfolgCollection userErfolge, {
    http.Client? client,
  }) async {
    client ??= http.Client();
    final url = Uri.parse('http://$serverIP:8080/erfolg/get_allerfolge');
    final response = await client.get(url);
    if (response.statusCode != 200) {
      logger.w('Fehler beim Laden aller Erfolge');
      throw Exception('Fehler beim Laden aller Erfolge');
    }
    final result = json.decode(response.body);
    ErfolgCollection allErfolge = ErfolgCollection();
    for (int x = 0; x < result.length; x++) {
      final newErfolg = Erfolg.fromJson(result[x] as Map<String, dynamic>);
      final alreadyExists =
          userErfolge.ergebnisse.any((e) => e.name == newErfolg.name);
      if (!alreadyExists) {
        allErfolge.ergebnisse.add(newErfolg);
      }
    }
    logger.i('Alle Erfolge erfolgreich geladen');
    return allErfolge.ergebnisse;
  }

  /// Überprüft, ob der Benutzer neue Erfolge freigeschaltet hat.
  ///
  /// Optionaler [context] zeigt eine Dialogbox bei neuen Erfolgen.
  ///
  /// Optionale Übergabe eines HTTP-Clients [client] (Unittests).
  ///
  /// Wirft eine Exception bei Fehlern.
  static Future<void> checkErfolge(BuildContext? context,
      {http.Client? client}) async {
    client ??= http.Client();
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/erfolg/check_erfolge?userID=$id');
    final response = await client.get(url);
    if (response.statusCode != 200) {
      logger.w('Fehler bei der Abfrage, ob ein neuer Erfolg freigeschaltet wurde');
      throw Exception(
          'Fehler bei der Abfrage, ob ein neuer Erfolg freigeschaltet wurde');
    }
    final result = json.decode(response.body);

    if (result) {
      logger.i('Erfolge erfolgreich überprüft');
      if (context != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Neuer Erfolg!'),
            content: Text('Neuer Erfolg freigeschaltet'),
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

  /// Aktualisiert die Statistik-Daten des Benutzers mit [distance] (in Metern)
  /// und [altitude] (in Höhenmetern).
  ///
  /// Optionale Übergabe eines HTTP-Clients [client].
  ///
  /// Wirft eine Exception bei Fehlern.
  static Future<void> updateStats(double distance, double altitude,
      {http.Client? client}) async {
    client ??= http.Client();
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/user/update_stats');

    final body = json.encode({
      "hoehenmeter": altitude,
      "id": id,
      "kmgelaufen": (distance / 1000),
    });

    final response = await client.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    );

    print(response.statusCode);
    if (response.statusCode != 200) {
      logger.w('Fehler beim Aktualisierung der Stats');
      throw Exception('Fehler beim Aktualisierung der Stats');
    }
    logger.i('Stats erfolgreich aktualisiert');
  }

  /// Lädt die vom Benutzer erreichten Ziele als [SammelkarteCollection].
  ///
  /// Optionale Übergabe eines HTTP-Clients [client].
  ///
  /// Wirft eine Exception bei Fehlern.
  static Future<SammelkarteCollection> getZiele({http.Client? client}) async {
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

  /// Aktualisiert Benutzerdaten wie [username], optionales [password],
  /// [hoehenmeter], [kmgelaufen] und [profilbild].
  ///
  /// Optionale Übergabe eines HTTP-Clients [client].
  ///
  /// Wirft eine Exception bei Fehlern.
  static Future<void> updateData(
    String username,
    String? password,
    double hoehenmeter,
    double kmgelaufen,
    String probilbild, {
    http.Client? client,
  }) async {
    client ??= http.Client();
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/user/update_data');

    final body = json.encode({
      "Benutzername": username,
      "ID": id,
      "Passwort": password,
      "Profilbild": probilbild,
      "hoehenmeter": hoehenmeter,
      "kmgelaufen": kmgelaufen,
    });

    final response = await client.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    );

    print(response.statusCode);
    if (response.statusCode != 200) {
      logger.w('Fehler beim Aktualisierung der Daten');
      throw Exception('Fehler beim Aktualisierung der Daten');
    }
    logger.i('Daten erfolgreich aktualisiert');
  }
}
