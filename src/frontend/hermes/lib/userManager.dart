import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hermes/erfolg.dart';
import 'package:hermes/erfolgCollection.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  // Privater Konstruktor verhindert Instanziierung
  UserManager._();
  
  static Future<bool> Login(BuildContext context, String username, String password) async {
    final url = Uri.parse('http://194.118.174.149:8080/user/login?benutzername=$username&passwort=$password');
    final response = await http.get(url);
    final result = json.decode(response.body);
    if (result == -1){
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
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', result);
    await prefs.setString('username', username);
    await prefs.setBool('isLoggedIn', true);

    return true;
  }

  static Future<bool> Register(BuildContext context, String username, String password) async {
    final url = Uri.parse('http://194.118.174.149:8080/user/register');

    final body = json.encode({
      "Benutzername": username,
      "Passwort": password,
      "Profilbild": "Profilbild"
    });

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    );

    if (response.statusCode == 409){
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
      return false;
    }

    final urlLogin = Uri.parse('http://194.118.174.149:8080/user/login?benutzername=$username&passwort=$password');
    final responseLogin = await http.get(urlLogin);
    final resultLogin = json.decode(responseLogin.body);
    // User ist noch nicht erstellt bevor ich seine ID abrufe
    print(resultLogin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', resultLogin);
    await prefs.setString('username', username);
    await prefs.setBool('isLoggedIn', true);
    return true;
  }

  static Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://194.118.174.149:8080/user/datenabfrage?user_id=$id');
    final response = await http.get(url);
    final result = json.decode(response.body);
    final urlBerge = Uri.parse('http://194.118.174.149:8080/erfolg/erreichteziele?userID=$id');
    final responseBerge = await http.get(urlBerge);
    final resultBerge = json.decode(responseBerge.body);
    return {
      'username': prefs.getString('username') ?? 'Unbekannt',
      'kmgelaufen': result['kmgelaufen'],
      'hoehenmeter': result['hoehenmeter'],
      'berge': resultBerge.length,
    };
  }

  static Future<List<Erfolg>> loadUserErfolge() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://194.118.174.149:8080/erfolg/get_erfolge?userID=$id');
    final response = await http.get(url);
    final result = json.decode(response.body);
    print(result);
    return (result as List)
      .map((e) => Erfolg.fromJson(e as Map<String, dynamic>))
      .toList();
  }

  static Future<List<Erfolg>> loadAllErfolge(ErfolgCollection userErfolge) async {
    final url = Uri.parse('http://194.118.174.149:8080/erfolg/get_allerfolge');
    final response = await http.get(url);
    final result = json.decode(response.body);
    ErfolgCollection allErfolge = ErfolgCollection();
    for (int x = 0; x < result.length; x++) {
      final newErfolg = Erfolg.fromJson(result[x] as Map<String, dynamic>);
      final alreadyExists = userErfolge.ergebnisse.any((e) => e.name == newErfolg.name);
      if (!alreadyExists) {
        allErfolge.ergebnisse.add(newErfolg);
      }
    }
    return allErfolge.ergebnisse;
  }

}
