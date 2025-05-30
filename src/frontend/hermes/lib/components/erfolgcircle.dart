import 'package:flutter/material.dart';

class Erfolgcircle extends StatelessWidget {
  final IconData icon;
  final String text;

  const Erfolgcircle({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[400],
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: icon == Icons.check ? Colors.black : Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
      ],
    );
  }
}
