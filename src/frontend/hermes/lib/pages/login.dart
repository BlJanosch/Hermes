import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hermes/pages/home.dart';
import 'package:hermes/userManager.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            // Logo
            Container(
              width: 290,
              height: 100,
                child: Image.asset(
                'lib/assets/icon/hermes_logo.png',
                width: 180,
                height: 180,
                ),
            ),

          // Title
          const Text(
          'Willkommen bei Hermes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          ),

          const SizedBox(height: 32),

          // Benutzername
          TextField(
          controller: _usernameController,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Benutzername',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
            ),
          ),
          ),

          const SizedBox(height: 16),

          // Passwort
          TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Passwort',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
            ),
            suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                ? Icons.visibility_off
                : Icons.visibility,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
              _obscurePassword = !_obscurePassword;
              });
            },
            ),
          ),
          ),

          const SizedBox(height: 32),

          // Buttons
          Row(
          children: [
            Expanded(
            child: ElevatedButton(
              onPressed: () async {
              bool login = await UserManager.Login(
                context,
                _usernameController.text,
                _passwordController.text,
              );
              setState(() {
                _isLogin = login;
              });
              if (_isLogin) {
                Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home()),
                );
              }
              },
              style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBBA430),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              ),
              child: const Text(
              'Login',
              style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            ),
            const SizedBox(width: 12),
            Expanded(
            child: ElevatedButton(
              onPressed: () async {
              bool register = await UserManager.Register(
                context,
                _usernameController.text,
                _passwordController.text,
              );
              setState(() {
                _isLogin = register;
              });
              if (_isLogin) {
                Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home()),
                );
              }
              },
              style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A742F),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              ),
              child: const Text(
              'Registrieren',
              style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            ),
          ],
          ),
        ],
        ),
      ),
      ),
    );
  }
}
