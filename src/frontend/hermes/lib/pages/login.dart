import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hermes/pages/home.dart';

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

  void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login mit $username')),
    );
  }

  void _register() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registrieren mit $username')),
    );
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
                              backgroundColor: _isLogin
                                  ? Color(0xFFBBA430)
                                  : Color(0xFF4A742F),
                              foregroundColor: _isLogin
                                  ? Colors.white
                                  : Colors.black,
                              elevation: _isLogin ? 2 : 0,
                            ),
                            onPressed: () {
                              setState(() {
                              _isLogin = true;
                              });
                              Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Home()),
                              );
                            },
                            child: const Text('Login'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_isLogin
                                  ? Color(0xFFBBA430)
                                  : Color(0xFF4A742F),
                              foregroundColor: !_isLogin
                                  ? Colors.white
                                  : Colors.black,
                              elevation: !_isLogin ? 2 : 0,
                            ),
                            onPressed: () {
                              setState(() {
                                _isLogin = false;
                              });
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