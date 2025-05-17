import 'package:flutter/material.dart';
import 'package:hermes/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.-
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hermes',
      home: const Login(),
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
    );
  }
}

