import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- für SystemChrome
import 'package:hermes/pages/home.dart';
import 'package:hermes/pages/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Nur Hochformat erlauben
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.-
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //navigatorObservers: [routeObserver],
      title: 'Hermes',
      home: const Login(),
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        fontFamily: "Sans",
      ),
    );
  }
}
