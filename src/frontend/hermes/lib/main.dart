import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermes/pages/home.dart';
import 'package:hermes/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hermes',
      home: isLoggedIn ? const Home() : const Login(),
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        fontFamily: "Sans",
      ),
    );
  }
}
