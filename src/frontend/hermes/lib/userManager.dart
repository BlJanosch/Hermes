import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  // Privater Konstruktor verhindert Instanziierung
  UserManager._();

  void SaveUserToDB(){}
  void UpdateUser(String benutzername, String passwort, String profilbild, double hoehenmeter, double kmgelaufen){}
  void DelUser(String benutzername, String passwort){}

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

}
