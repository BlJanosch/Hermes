import 'dart:async';
import 'package:hermes/components/globals.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

/// Singleton-Service zur Erfassung und Verwaltung von Standort-Tracking-Daten.
class TrackingService {
  static final TrackingService _instance = TrackingService._internal();

  /// Factory-Konstruktor, der immer dieselbe Instanz zurückgibt.
  factory TrackingService() => _instance;

  TrackingService._internal();

  /// Location-Plugin zur Standortabfrage.
  final Location location = Location();

  /// Subscription für Location-Updates.
  StreamSubscription<LocationData>? _locationSubscription;

  /// Liste der bisher getrackten GPS-Koordinaten.
  List<LatLng> trackedRoute = [];

  /// Gesamtstrecke in Metern.
  double totalDistance = 0.0;

  /// Gesamter Höhenanstieg in Metern.
  double totalAltitudeGain = 0.0;

  /// Letzte bekannte Höhe, um Höhenunterschiede zu berechnen.
  double? _lastAltitude;

  /// Status, ob das Tracking gerade läuft.
  bool isTracking = false;

  /// Hilfsobjekt zur Distanzberechnung zwischen zwei Koordinaten.
  final Distance _distanceCalculator = Distance();

  /// Zeitpunkt, zu dem das Tracking gestartet oder fortgesetzt wurde.
  DateTime? startTime;

  /// Akkumulierte Tracking-Dauer vor dem letzten Start/Resume.
  Duration accumulatedDuration = Duration.zero;

  /// Callback-Funktion, die bei Standortänderungen aufgerufen wird.
  Function()? onLocationUpdated;

  /// Startet das Tracking und setzt alle relevanten Werte zurück.
  void startTracking() {
    logger.i('Tracking gestartet');
    trackedRoute.clear();
    totalDistance = 0.0;
    totalAltitudeGain = 0.0;
    accumulatedDuration = Duration.zero;
    startTime = DateTime.now();
    isTracking = true;

    _locationSubscription = location.onLocationChanged.listen((loc) {
      final LatLng newPoint = LatLng(loc.latitude!, loc.longitude!);
      
      // Distanz zum letzten Punkt hinzufügen
      if (trackedRoute.isNotEmpty) {
        totalDistance += _distanceCalculator(trackedRoute.last, newPoint);
      }
      
      // Höhenanstieg berechnen, wenn sinnvoll
      if (_lastAltitude != null && loc.altitude != null) {
        double altitudeDiff = loc.altitude! - _lastAltitude!;
        if (altitudeDiff > 1.0 && altitudeDiff < 100) {
          totalAltitudeGain += altitudeDiff;
        }
      }
      
      _lastAltitude = loc.altitude;

      // Neuen Standort speichern
      trackedRoute.add(newPoint);

      // Callback auslösen
      onLocationUpdated?.call();
    });
  }

  /// Stoppt das Tracking und summiert die bisherige Dauer.
  void stopTracking() {
    logger.i('Tracking gestoppt');
    _locationSubscription?.cancel();
    _locationSubscription = null;

    if (startTime != null) {
      accumulatedDuration += DateTime.now().difference(startTime!);
    }

    isTracking = false;
    startTime = null;
  }

  /// Setzt das Tracking fort, ohne die bisherigen Daten zu löschen.
  void resumeTracking() {
    logger.i('Tracking fortgesetzt');
    startTime = DateTime.now();
    isTracking = true;

    _locationSubscription = location.onLocationChanged.listen((loc) {
      final LatLng newPoint = LatLng(loc.latitude!, loc.longitude!);

      // Distanz zum letzten Punkt hinzufügen
      if (trackedRoute.isNotEmpty) {
        totalDistance += _distanceCalculator(trackedRoute.last, newPoint);
      }

      // Höhenanstieg berechnen, wenn sinnvoll
      if (_lastAltitude != null && loc.altitude != null) {
        double altitudeDiff = loc.altitude! - _lastAltitude!;
        if (altitudeDiff > 1.0 && altitudeDiff < 100) {
          totalAltitudeGain += altitudeDiff;
        }
      }

      _lastAltitude = loc.altitude;

      // Neuen Standort speichern
      trackedRoute.add(newPoint);

      // Callback auslösen
      onLocationUpdated?.call();
    });
  }

  /// Gibt die aktuell gemessene Gesamtdauer des Trackings zurück,
  /// inklusive der Zeit seit dem letzten Start/Resume.
  Duration get currentDuration {
    if (startTime == null) return accumulatedDuration;
    return accumulatedDuration + DateTime.now().difference(startTime!);
  }

  /// Setzt alle Tracking-Daten zurück und stoppt das Tracking.
  void reset() {
    logger.i('Tracking zurückgesetzt');
    stopTracking();
    trackedRoute.clear();
    totalDistance = 0.0;
    totalAltitudeGain = 0.0;
    accumulatedDuration = Duration.zero;
  }
}
