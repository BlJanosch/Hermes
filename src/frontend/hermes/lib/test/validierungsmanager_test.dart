import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/validierungsmanager.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// prompt: Wie kann ich das mit der Location machen beim Validierungsmanager
class FakeGeolocatorPlatform extends GeolocatorPlatform with MockPlatformInterfaceMixin {
  final double mockedDistance;
  final double mockLatitude;
  final double mockLongitude;

  FakeGeolocatorPlatform(this.mockedDistance, this.mockLatitude, this.mockLongitude);

  @override
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return mockedDistance;
  }

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    return Position(
      latitude: mockLatitude,
      longitude: mockLongitude,
      timestamp: DateTime.now(),
      altitude: 0,
      accuracy: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
    );
  }
}
void main() {
  final originalGeolocatorPlatform = GeolocatorPlatform.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({'id': 1});
  });

  tearDown(() {
    GeolocatorPlatform.instance = originalGeolocatorPlatform;
  });

  testWidgets('zeigt Verbindungsfehler Dialog bei Exception', (WidgetTester tester) async {
    final client = MockClient((request) async {
      throw Exception('Server nicht erreichbar');
    });

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              await Validierungsmanager.AddSammelkarteNFCGPS(context, 1, client: client);
            },
            child: Text('Test Button'),
          );
        },
      ),
    ));

    await tester.tap(find.text('Test Button'));
    await tester.pumpAndSettle();

    expect(find.text('Verbindungsfehler'), findsOneWidget);
    expect(find.textContaining('Server nicht erreichbar'), findsOneWidget);
  });

  testWidgets('zeigt "Ziel bereits vorhanden" Dialog bei Status 400', (WidgetTester tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform(100, 48.0, 11.0); // < 500m

    final client = MockClient((request) async {
      if (request.url.path == '/erfolg/ziel') {
        return http.Response(jsonEncode({'lat': 48.0, 'lng': 11.0}), 200);
      } else if (request.url.path == '/erfolg/add_erreichtesziel') {
        return http.Response('', 400);
      }
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () async {
            await Validierungsmanager.AddSammelkarteNFCGPS(context, 1, client: client);
          },
          child: Text('Test Button'),
        );
      }),
    ));

    await tester.tap(find.text('Test Button'));
    await tester.pumpAndSettle();

    expect(find.text('Fehler beim Hinzufügen!'), findsOneWidget);
    expect(find.text('Ziel befindet sich bereits in deinem Besitz!'), findsOneWidget);
  });

  testWidgets('zeigt Fehler Dialog bei anderem Fehlercode als 201 oder 400', (WidgetTester tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform(100, 48.0, 11.0); // < 500m

    final client = MockClient((request) async {
      if (request.url.path == '/erfolg/ziel') {
        return http.Response(jsonEncode({'lat': 48.0, 'lng': 11.0}), 200);
      } else if (request.url.path == '/erfolg/add_erreichtesziel') {
        return http.Response('', 500);
      }
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () async {
            await Validierungsmanager.AddSammelkarteNFCGPS(context, 1, client: client);
          },
          child: Text('Test Button'),
        );
      }),
    ));

    await tester.tap(find.text('Test Button'));
    await tester.pumpAndSettle();

    expect(find.text('Fehler beim Hinzufügen!'), findsOneWidget);
    expect(find.text('Ziel konnte nicht hinzugefügt werden!'), findsOneWidget);
  });

  testWidgets('zeigt "Nicht in der Nähe" Dialog wenn Distanz > 500m', (WidgetTester tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform(600, 47.0, 10.0); // > 500m

    final client = MockClient((request) async {
      if (request.url.path == '/erfolg/ziel') {
        return http.Response(jsonEncode({'lat': 48.0, 'lng': 11.0}), 200);
      }
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () async {
            await Validierungsmanager.AddSammelkarteNFCGPS(context, 1, client: client);
          },
          child: Text('Test Button'),
        );
      }),
    ));

    await tester.tap(find.text('Test Button'));
    await tester.pumpAndSettle();

    expect(find.text('Fehler beim Hinzufügen!'), findsOneWidget);
    expect(find.text('Du musst dich in der Nähe vom Ziel befinden, um es hinzufügen zu können!'), findsOneWidget);
  });
}
