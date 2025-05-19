import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hermes/components/bottom_nav_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;

  bool _isRecording = false;
  bool _trackingStopped = false;

  List<LatLng> _trackedRoute = [];
  StreamSubscription<Position>? _positionStream;

  double _distance = 0.0;
  DateTime? _startTime;
  Duration _accumulatedDuration = Duration.zero;

  final Distance _distanceCalculator = Distance();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(_currentPosition!, 15.0);
  }

  void _startTracking() {
    _trackedRoute.clear();
    _distance = 0.0;
    _accumulatedDuration = Duration.zero;
    _startTime = DateTime.now();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      final LatLng newPoint = LatLng(position.latitude, position.longitude);
      setState(() {
        if (_trackedRoute.isNotEmpty) {
          _distance += _distanceCalculator(_trackedRoute.last, newPoint);
        }
        _trackedRoute.add(newPoint);
      });
      _mapController.move(newPoint, _mapController.zoom);
    });

    _startTimer();

    setState(() {
      _isRecording = true;
      _trackingStopped = false;
    });
  }

  void _stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;

    if (_startTime != null) {
      _accumulatedDuration += DateTime.now().difference(_startTime!);
    }

    _stopTimer();

    setState(() {
      _isRecording = false;
      _trackingStopped = true;
      _startTime = null;
    });
  }

  void _resumeTracking() {
    _startTime = DateTime.now();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      final LatLng newPoint = LatLng(position.latitude, position.longitude);
      setState(() {
        if (_trackedRoute.isNotEmpty) {
          _distance += _distanceCalculator(_trackedRoute.last, newPoint);
        }
        _trackedRoute.add(newPoint);
      });
      _mapController.move(newPoint, _mapController.zoom);
    });

    _startTimer();

    setState(() {
      _isRecording = true;
      _trackingStopped = false;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRecording) {
        setState(() {}); // UI-Aktualisierung
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _toggleTracking() {
    if (_isRecording) {
      _stopTracking();
    } else {
      if (_trackingStopped) {
        _resumeTracking();
      } else {
        _startTracking();
      }
    }
  }

  Duration get _duration {
    if (_startTime == null) return _accumulatedDuration;
    return _accumulatedDuration + DateTime.now().difference(_startTime!);
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentPosition ?? LatLng(47.165, 9.758),
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_trackedRoute.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _trackedRoute,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              CurrentLocationLayer(),
            ],
          ),

          if (_isRecording || _trackingStopped)
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Distanz: ${(_distance / 1000).toStringAsFixed(2)} km',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    if (_trackingStopped)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow, color: Colors.white),
                            onPressed: _resumeTracking,
                          ),
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.white),
                            onPressed: () {
                              // Strecke in DB schreiben
                              setState(() {
                                _trackingStopped = false;
                                _trackedRoute = [];
                              });
                            },
                          ),
                        ],
                      ),
                    Text(
                      'Dauer: ${_duration.inMinutes.toString().padLeft(2, '0')}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
            bottom: 130.0,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
              onPressed: _trackingStopped ? null : _toggleTracking,
              backgroundColor: _isRecording
                ? Colors.red.withOpacity(0.7)
                : Colors.black.withOpacity(0.5),
              child: Icon(
                Icons.route_rounded,
                color: _isRecording
                  ? Colors.white
                  : _trackingStopped
                    ? Colors.grey.withOpacity(0.5)
                    : Colors.grey,
              ),
              ),
            ),
            ),

          Positioned(
            bottom: 10.0,
            left: 5,
            right: 5,
            child: MyBottomNavBar(currentIndex: 0,),
          ),
        ],
      ),
    );
  }
}
