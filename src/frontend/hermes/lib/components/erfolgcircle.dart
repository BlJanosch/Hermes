import 'package:flutter/material.dart';

class Erfolgcircle extends StatelessWidget {
  const Erfolgcircle({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[400],
                child: Icon(Icons.check, color: Colors.white),
              );
  }
}