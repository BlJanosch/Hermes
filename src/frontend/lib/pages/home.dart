import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:hermes/components/globals.dart';
import 'package:hermes/userManager.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:hermes/components/bottom_nav_bar.dart';
import 'package:hermes/components/tracking_service.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Logging included
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final MapController _mapController = MapController();
  final TrackingService trackingService = TrackingService();
  final Location _location = Location();
  double distance = 0;
  double altitude = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _location.enableBackgroundMode(enable: true);

    trackingService.onLocationUpdated = () {
      if (mounted) {
        setState(() {});
        if (trackingService.trackedRoute.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(
              trackingService.trackedRoute.last,
              _mapController.zoom,
            );
          });
        }
      }
    };

    WidgetsBinding.instance.addPostFrameCallback((_) => _zoomToCurrentLocation());

    _startTimer();
  }

  Future<void> _zoomToCurrentLocation() async {
    final hasPermission = await _location.hasPermission();
    if (hasPermission == PermissionStatus.denied) {
      await _location.requestPermission();
      logger.i('Berechtigung zum Orten nicht erteilt... Erlaubnis wird angefragt');
    }

    final serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      await _location.requestService();
    }

    final currentLocation = await _location.getLocation();
    if (mounted) {
      _mapController.move(
        LatLng(currentLocation.latitude!, currentLocation.longitude!),
        20.0, 
      );
    }
    logger.i('Zum aktuellen Standort gezoomt');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    logger.i('Timer gestartet');
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && trackingService.isTracking) {
        setState(() {});
      }
    });
  }

  void _toggleTracking() {
    if (trackingService.isTracking) {
      logger.i('Tracking Stop wurde gedrückt');
      trackingService.stopTracking();
    } else {
      if (trackingService.startTime != null) {
        logger.i('Tracking Fortsetzung wurde gedrückt');
        trackingService.resumeTracking();
      } else {
        logger.i('Tracking Start wurde gedrückt');
        trackingService.startTracking();
      }
    }
    setState(() {});
  }

  void _resetTracking() {
    logger.i('Zurücksetzen gestartet');
    trackingService.reset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final route = trackingService.trackedRoute;
    distance = trackingService.totalDistance;
    altitude = trackingService.totalAltitudeGain;
    final isTracking = trackingService.isTracking;
    final isTrackingStopped = !isTracking && route.isNotEmpty;
    final duration = trackingService.currentDuration;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: route.isNotEmpty ? route.last : LatLng(47.165, 9.758),
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),

              if (route.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: route,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              CurrentLocationLayer(),
            ],
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.10 + 15,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  color: Colors.transparent,
                  child: Text(
                    'flutter_map | © OpenStreetMap contributors',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),

          if (isTracking || isTrackingStopped)
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
                      'Distanz: ${(distance / 1000).toStringAsFixed(2)} km',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    if (isTrackingStopped)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow, color: Colors.white),
                            onPressed: () {
                              trackingService.resumeTracking();
                              setState(() {});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.white),
                            onPressed: () {
                              _resetTracking();
                              try{
                                UserManager.updateStats(distance, altitude);
                              }
                              catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Aktualisieren der Stats ist fehlgeschlagen'),
                                    content: Text('Fehler: $e'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    Text(
                      'Dauer: ${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
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
                onPressed: isTrackingStopped ? null : _toggleTracking,
                backgroundColor: isTracking
                    ? Colors.red.withOpacity(0.7)
                    : Colors.black.withOpacity(0.5),
                child: Icon(
                  Icons.route_rounded,
                  color: isTracking
                      ? Colors.white
                      : isTrackingStopped
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
            child: MyBottomNavBar(currentIndex: 0),
          ),
        ],
      ),
    );
  }
}
