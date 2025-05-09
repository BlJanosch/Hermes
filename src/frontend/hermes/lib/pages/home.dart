import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hermes/components/bottom_nav_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(47.267, 9.594),
              zoom: 13.0,
            ),
            children: [
              TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
              ),
            ],
          ),
          Positioned(
            bottom: 130.0,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: null,
                child: Icon(Icons.route_rounded, color: Colors.grey),
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 10.0,
            left: 5,
            right: 5,
            child: MyBottomNavBar(),
          ),
        ],
      ),
    );
  }
}
