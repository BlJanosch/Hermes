import 'package:flutter/material.dart';
import 'package:hermes/sammelkarte.dart';
import 'package:hermes/schwierigkeit.dart';
import 'package:hermes/components/karte_detail_dialog.dart';

/// Widget, das eine Sammelkarte darstellt und beim Tippen eine Detailansicht öffnet.
class MySammelkarte extends StatelessWidget {
  /// Die Karte, die dargestellt werden soll.
  final Sammelkarte karte;

  /// Erzeugt ein [MySammelkarte] Widget mit der übergebenen [karte].
  const MySammelkarte({super.key, required this.karte});

  /// Liefert den Pfad zum Hintergrundbild basierend auf der Schwierigkeit der Karte.
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

  /// Bestimmt die Textfarbe, abhängig von der Schwierigkeit der Karte.
  /// 
  /// Für die Schwierigkeit "Galaktisch" wird Weiß verwendet, ansonsten Schwarz.
  Color getTextColor() {
    switch (karte.schwierigkeit) {
      case Schwierigkeit.Galaktisch:
        return Colors.white;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// Öffnet den Detaildialog der Karte beim Tippen.
      onTap: () => showDialog(
        context: context,
        builder: (_) => KarteDetailDialog(karte: karte),
      ),
      child: Container(
        height: 200,
        width: 140,
        margin: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(getHintergrundBildPfad()),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Bild der Karte
              Container(
                height: 80,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage("lib/assets/${karte.Bild}"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              /// Name der Karte
              Text(
                karte.Name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: getTextColor(),
                ),
              ),

              const SizedBox(height: 4),

              /// Höhe der Karte in Metern
              Text(
                '${karte.Hoehe.toStringAsFixed(0)} m',
                textAlign: TextAlign.center,
                style: TextStyle(color: getTextColor()),
              ),

              const SizedBox(height: 4),

              /// Datum der Karte (Tag.Monat.Jahr)
              Text(
                '${karte.Datum.day}.${karte.Datum.month}.${karte.Datum.year}',
                textAlign: TextAlign.center,
                style: TextStyle(color: getTextColor()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
