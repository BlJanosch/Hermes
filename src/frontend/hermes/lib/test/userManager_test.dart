import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/erfolg.dart';
import 'package:hermes/erfolgCollection.dart';
import 'package:hermes/schwierigkeit.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:hermes/userManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Für SharedPreferences und Dialoge

  group('UserManager', () {
    test('sollte false zurückgeben bei Loginfehler', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(-1), 200);
      });

      final result = await UserManager.Login(
        null,
        'falscher_user',
        'falsches_passwort',
        client: client,
      );

      expect(result, false);
    });

    test('sollte bei Login mit "korrekten" Daten true zurückgeben und Daten in SharedPreferences speichern', () async {
      SharedPreferences.setMockInitialValues({}); // Cache zurücksetzen

      final client = MockClient((request) async {
        return http.Response(jsonEncode(456), 200); // Simulierter ID von Benutzer
      });

      final result = await UserManager.Login(
        null,
        'user',
        'pass',
        client: client,
      );

      final prefs = await SharedPreferences.getInstance();

      expect(result, true);
      expect(prefs.getInt('id'), 456);
      expect(prefs.getString('username'), 'user');
      expect(prefs.getBool('isLoggedIn'), true);
    });

    test('sollte false zurückgeben bei Registrierfehler', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(-1), 404);
      });

      final result = await UserManager.Register(
        null,
        'falscher_user',
        'falsches_passwort',
        client: client,
      );

      expect(result, false);
    });

    test('sollte true zurückgeben bei erfolgreicher Registrierung', () async {
      SharedPreferences.setMockInitialValues({});

      final client = MockClient((request) async {
        if (request.url.path.endsWith('/user/register')) {
          return http.Response('', 200); // Registrierung erfolgreich
        }
        if (request.url.path.endsWith('/user/login')) {
          return http.Response(jsonEncode(789), 200); // Simulierter Login
        }
        return http.Response('Not Found', 404);
      });

      final result = await UserManager.Register(
        null,
        'neuer_user',
        'passwort123',
        client: client,
      );

      final prefs = await SharedPreferences.getInstance();

      expect(result, true);
      expect(prefs.getInt('id'), 789);
      expect(prefs.getString('username'), 'neuer_user');
      expect(prefs.getBool('isLoggedIn'), true);
    });

    test('LoadUserData: sollte eine Exception werfen wenn der User nicht gefunden wurde', () async {
      SharedPreferences.setMockInitialValues({});

      final client = MockClient((request) async {
        return http.Response(jsonEncode(-1), 401);
      });

      expect(
        () async => await UserManager.loadUserData(client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('LoadUserData: sollte Exception werfen bei ungültigem Statuscode bei Ziel-Abfrage', () async {
      SharedPreferences.setMockInitialValues({
        'id': 1,
        'username': 'testuser',
      });

      final client = MockClient((request) async {
        if (request.url.path.endsWith('/datenabfrage')) {
          return http.Response(jsonEncode({'kmgelaufen': 10, 'hoehenmeter': 500}), 200);
        }
        if (request.url.path.endsWith('/erfolg/erreichteziele')) {
          return http.Response('Fehler', 400);
        }
        return http.Response('Not Found', 404); // Default
      });

      expect(
        () async => await UserManager.loadUserData(client: client),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Ungültige Eingabe'))),
      );
    });

    test('loadUserData liefert korrekte Daten zurück', () async {
      SharedPreferences.setMockInitialValues({
        'id': 1,
        'username': 'TestUser',
      });

      final client = MockClient((request) async {
        if (request.url.path.endsWith('/datenabfrage')) {
          return http.Response(jsonEncode({
            'kmgelaufen': 42,
            'hoehenmeter': 1234,
          }), 200);
        }
        if (request.url.path.endsWith('/erfolg/erreichteziele')) {
          return http.Response(jsonEncode([
            {'ziel': 'Berg1'},
            {'ziel': 'Berg2'},
            {'ziel': 'Berg3'},
          ]), 200);
        }
        return http.Response('Not Found', 404);
      });

      final data = await UserManager.loadUserData(client: client);

      expect(data['username'], 'TestUser');
      expect(data['kmgelaufen'], 42);
      expect(data['hoehenmeter'], 1234);
      expect(data['berge'], 3);
    });

    test('LoadUserErfolge: sollte eine Exception werfen wenn der http Request eine andere response als 200 hat', () async {
      SharedPreferences.setMockInitialValues({});

      final client = MockClient((request) async {
        return http.Response(jsonEncode(-1), 400);
      });

      expect(
        () async => await UserManager.loadUserErfolge(client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('loadUserErfolge gibt korrekte Liste zurück', () async {
      SharedPreferences.setMockInitialValues({'id': 42});

      final mockResponse = jsonEncode([
        {
          'Name': "Erfolg1",
          'Beschreibung': 'Erfolg 1',
        },
        {
          'Name': "Erfolg2",
          'Beschreibung': 'Erfolg 2',
        },
      ]);

      final client = MockClient((request) async {
        return http.Response(mockResponse, 200);
      });

      final erfolge = await UserManager.loadUserErfolge(client: client);

      expect(erfolge, isA<List<Erfolg>>());
      expect(erfolge.length, 2);

      expect(erfolge[0].name, "Erfolg1");
      expect(erfolge[0].Beschreibung, 'Erfolg 1');
      expect(erfolge[0].schwierigkeit, Schwierigkeit.Bronze);

      expect(erfolge[1].name, "Erfolg2");
      expect(erfolge[1].Beschreibung, 'Erfolg 2');
      expect(erfolge[1].schwierigkeit, Schwierigkeit.Bronze);
    });

    test('LoadAllErfolge: sollte eine Exception werfen wenn der http Request eine andere response als 200 hat', () async {
      SharedPreferences.setMockInitialValues({});

      final client = MockClient((request) async {
        return http.Response(jsonEncode(-1), 400);
      });

      ErfolgCollection list = new ErfolgCollection();

      expect(
        () async => await UserManager.loadAllErfolge(list, client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('loadAllErfolge gibt korrekte Liste zurück', () async {
      SharedPreferences.setMockInitialValues({'id': 42});

      final mockResponse = jsonEncode([
        {
          'Name': "Erfolg1",
          'Beschreibung': 'Erfolg 1',
        },
        {
          'Name': "Erfolg2",
          'Beschreibung': 'Erfolg 2',
        },
      ]);

      final client = MockClient((request) async {
        return http.Response(mockResponse, 200);
      });

      ErfolgCollection list = new ErfolgCollection();

      final erfolge = await UserManager.loadAllErfolge(list, client: client);

      expect(erfolge, isA<List<Erfolg>>());
      expect(erfolge.length, 2);

      expect(erfolge[0].name, "Erfolg1");
      expect(erfolge[0].Beschreibung, 'Erfolg 1');
      expect(erfolge[0].schwierigkeit, Schwierigkeit.Bronze);

      expect(erfolge[1].name, "Erfolg2");
      expect(erfolge[1].Beschreibung, 'Erfolg 2');
      expect(erfolge[1].schwierigkeit, Schwierigkeit.Bronze);
    });

    test('CheckErfolge: sollte eine Exception werfen wenn der http Request eine andere response als 200 hat', () async {
      SharedPreferences.setMockInitialValues({});

      final client = MockClient((request) async {
        return http.Response(jsonEncode(-1), 400);
      });

      expect(
        () async => await UserManager.checkErfolge(null, client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('UpdateStats: sollte eine Exception werfen wenn der http Request eine andere response als 200 hat', () async {
      SharedPreferences.setMockInitialValues({});

      final client = MockClient((request) async {
        return http.Response(jsonEncode(-1), 400);
      });

      expect(
        () async => await UserManager.updateStats(0, client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('updateStats mit "korrekten" Daten sollte einfach durchlaufen ohne eine Exception zu werfen', () async {
      SharedPreferences.setMockInitialValues({'id': 123});

      final client = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/user/update_stats');

        final data = jsonDecode(request.body);
        expect(data['id'], 123);
        expect(data['hoehenmeter'], 0);
        expect(data['kmgelaufen'], 1.5);

        return http.Response('', 200);
      });

      await UserManager.updateStats(1500, client: client);
    });

    test('GetZiele: sollte eine Exception werfen wenn der http Request eine andere response als 200 hat', () async {
      SharedPreferences.setMockInitialValues({});

      final client = MockClient((request) async {
        return http.Response(jsonEncode(-1), 400);
      });

      expect(
        () async => await UserManager.getZiele(client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('getZiele gibt korrektes SammelkarteCollection zurück', () async {
      SharedPreferences.setMockInitialValues({'id': 1});

      final mockJson = jsonEncode([
        {
          "Name": "Zugspitze",
          "Bild": "zugspitze.jpg",
          "Schwierigkeit": Schwierigkeit.Bronze.index, 
          "hoehe": 2962,
          "datum": "2024-08-15"
        },
        {
          "Name": "Großglockner",
          "Bild": "grossglockner.jpg",
          "Schwierigkeit": Schwierigkeit.Silber.index,
          "hoehe": 3798,
          "datum": "2024-09-01"
        }
      ]);

      final client = MockClient((request) async {
        return http.Response(mockJson, 200);
      });

      final collection = await UserManager.getZiele(client: client);

      expect(collection.sammelkarten.length, 2);
      expect(collection.sammelkarten[0].Name, 'Zugspitze');
      expect(collection.sammelkarten[1].Hoehe, 3798);
      expect(collection.sammelkarten[1].schwierigkeit, Schwierigkeit.Silber);
    });
  });
}
