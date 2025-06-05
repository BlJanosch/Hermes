import 'dart:convert';
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

  static Future<void> AddSammelkarteNFCGPS(BuildContext context, int ZielID) async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/erfolg/ziel?zielID=$id');
    final response = await http.get(url);
    final result = json.decode(response.body);
    Location _location = Location();
    final currentLocation = await _location.getLocation();

    double distanceInMeters = Geolocator.distanceBetween(
      result['lat'], result['lng'],
      currentLocation.latitude ?? 0, currentLocation.longitude ?? 0,
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

      if (response.statusCode != 201){
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
    }
  }
}