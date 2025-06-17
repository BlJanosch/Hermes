import 'package:flutter/material.dart';
import 'package:hermes/sammelkarte.dart';
import 'package:hermes/schwierigkeit.dart';
import 'package:hermes/components/karte_detail_dialog.dart';

class MySammelkarte extends StatelessWidget {
  final Sammelkarte karte;

  const MySammelkarte({super.key, required this.karte});

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
    onTap: () => showDialog(
      context: context,
      builder: (_) => KarteDetailDialog(karte: karte),
    ),
    child: Container(
      height: 200,
      margin: const EdgeInsets.all(15.0),
      width: 140,
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage("lib/assets/${karte.Bild}"),
                  fit: BoxFit.cover,
                ),
              ),
              height: 80,
              width: 100,
            ),
            const SizedBox(height: 10),
            Text(karte.Name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getTextColor())),
            const SizedBox(height: 4),
            Text('${karte.Hoehe.toStringAsFixed(0)} m',
                textAlign: TextAlign.center,
                style: TextStyle(color: getTextColor())),
            const SizedBox(height: 4),
            Text('${karte.Datum.day}.${karte.Datum.month}.${karte.Datum.year}',
                textAlign: TextAlign.center,
                style: TextStyle(color: getTextColor())),
          ],
        ),
      ),
    ),
  );
}

}
