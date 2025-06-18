import 'package:flutter/material.dart';

/// Ein Widget, das einen kreisförmigen Avatar mit einem Icon und einem darunter angezeigten Text darstellt.
///
/// Wird verwendet, um Erfolge oder Statussymbole visuell darzustellen.
class Erfolgcircle extends StatelessWidget {
  /// Das Icon, das im Kreis angezeigt wird.
  final IconData icon;

  /// Der Text, der unter dem Kreis angezeigt wird.
  final String text;

  /// Erstellt einen neuen [Erfolgcircle] mit einem Icon und Text.
  ///
  /// [icon] und [text] sind erforderlich.
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
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
