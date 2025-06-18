import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hermes/sammelkarte.dart';
import 'package:hermes/schwierigkeit.dart';

/// Dialog zur Anzeige der Details einer Sammelkarte.
/// 
/// Zeigt ein vergrößertes Bild der Karte, Name, Höhe, Datum und einen Schließen-Button.
/// Der Hintergrund ist unscharf (Blur), um den Fokus auf die Karte zu legen.
/// Die Farben und das Hintergrundbild variieren je nach Schwierigkeit der Karte.
class KarteDetailDialog extends StatelessWidget {
  /// Die anzuzeigende Sammelkarte
  final Sammelkarte karte;

  /// Konstruktor für den Dialog, benötigt eine Sammelkarte
  const KarteDetailDialog({super.key, required this.karte});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(getHintergrundBildPfad()),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    "lib/assets/${karte.Bild}",
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  karte.Name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: getTextColor(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${karte.Hoehe.toStringAsFixed(0)} m',
                  style: TextStyle(fontSize: 18, color: getTextColor()),
                ),
                Text(
                  '${karte.Datum.day}.${karte.Datum.month}.${karte.Datum.year}',
                  style: TextStyle(fontSize: 16, color: getTextColor()),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Schließen'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Gibt den Pfad zum Hintergrundbild entsprechend der Schwierigkeit der Karte zurück.
  String getHintergrundBildPfad() {
    switch (karte.schwierigkeit) {
      case Schwierigkeit.Holz:
        return 'lib/assets/holz.png';
      case Schwierigkeit.Stein:
        return 'lib/assets/stein.png';
      case Schwierigkeit.Bronze:
        return 'lib/assets/bronze.png';
      case Schwierigkeit.Silber:
        return 'lib/assets/silber.png';
      case Schwierigkeit.Gold:
        return 'lib/assets/gold.png';
      case Schwierigkeit.Galaktisch:
        return 'lib/assets/galaktisch.png';
    }
  }

  /// Gibt die Textfarbe zurück, abhängig von der Schwierigkeit der Karte.
  /// Für die Schwierigkeit 'Galaktisch' wird weiß verwendet, sonst schwarz.
  Color getTextColor() {
    switch (karte.schwierigkeit) {
      case Schwierigkeit.Galaktisch:
        return Colors.white;
      default:
        return Colors.black;
    }
  }
}
