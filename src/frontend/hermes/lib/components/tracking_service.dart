import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class TrackingService {
  static final TrackingService _instance = TrackingService._internal();

  factory TrackingService() => _instance;

  TrackingService._internal();

  final Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  List<LatLng> trackedRoute = [];
  double totalDistance = 0.0;
  bool isTracking = false;

  final Distance _distanceCalculator = Distance();

  DateTime? startTime;
  Duration accumulatedDuration = Duration.zero;

  Function()? onLocationUpdated; // Optional callback to notify UI

  void startTracking() {
    trackedRoute.clear();
    totalDistance = 0.0;
    accumulatedDuration = Duration.zero;
    startTime = DateTime.now();
    isTracking = true;

    _locationSubscription = location.onLocationChanged.listen((loc) {
      final LatLng newPoint = LatLng(loc.latitude!, loc.longitude!);
      if (trackedRoute.isNotEmpty) {
        totalDistance += _distanceCalculator(trackedRoute.last, newPoint);
      }
      trackedRoute.add(newPoint);
      onLocationUpdated?.call();
    });
  }

  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;

    if (startTime != null) {
      accumulatedDuration += DateTime.now().difference(startTime!);
    }

    isTracking = false;
    startTime = null;
  }

  void resumeTracking() {
    startTime = DateTime.now();
    isTracking = true;

    _locationSubscription = location.onLocationChanged.listen((loc) {
      final LatLng newPoint = LatLng(loc.latitude!, loc.longitude!);
      if (trackedRoute.isNotEmpty) {
        totalDistance += _distanceCalculator(trackedRoute.last, newPoint);
      }
      trackedRoute.add(newPoint);
      onLocationUpdated?.call();
    });
  }

  Duration get currentDuration {
    if (startTime == null) return accumulatedDuration;
    return accumulatedDuration + DateTime.now().difference(startTime!);
  }

  void reset() {
    stopTracking();
    trackedRoute.clear();
    totalDistance = 0.0;
    accumulatedDuration = Duration.zero;
  }
}
