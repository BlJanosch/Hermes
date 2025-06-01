import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hermes/pages/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLogin = true;

  Future<bool> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
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
    await prefs.setString('password', password);
    await prefs.setBool('isLoggedIn', true);

    return true;
  }

  Future<bool> _register() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
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

    final prefs = await SharedPreferences.getInstance();
    //await prefs.setInt('id', result); // Hier mit User data abfrage noch ID holen oder noch in Request miteinbinden
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    await prefs.setBool('isLoggedIn', true);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.7),
      body: Stack(
        children: [
            AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Align(
                    alignment: Alignment(0, MediaQuery.of(context).size.height > 600 ? -0.55 : -0.3),
              child: SvgPicture.asset(
              'lib/assets/hermes_logo.svg',
              fit: BoxFit.cover,
              width: 500,
              height: 500,
              ),
            ),
            ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Willkommen bei Hermes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                    const SizedBox(height: 20),
                    Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      controller: _usernameController,
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                      labelText: 'Benutzername',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                      labelText: 'Passwort',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                        _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                        color: Colors.black,
                        ),
                        onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                        },
                      ),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                    ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFBBA430),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              bool login = await _login();
                              setState(() {
                                if (login){
                                  _isLogin = true;
                                }
                                else{
                                  _isLogin = false;
                                }
                              });
                              if (_isLogin){
                                Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Home()),
                                );
                              }
                            },
                            child: const Text('Login'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4A742F),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () async {
                              bool register = await _register();
                              setState(() {
                                if (register){
                                  _isLogin = true;
                                }
                                else{
                                  _isLogin = false;
                                }
                              });
                              if (_isLogin){
                                Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Home()),
                                );
                              }
                            },
                            child: const Text('Registrieren'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}