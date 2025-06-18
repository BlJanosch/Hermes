import 'schwierigkeit.dart';

/// Repräsentiert eine Sammelkarte mit Bild, Schwierigkeitsgrad und weiteren Eigenschaften.
///
/// Eine [Sammelkarte] enthält Metadaten wie Name, Bildpfad, Schwierigkeitsstufe,
/// Höhe des Berges und das Erstellungs- oder Funddatum.
class Sammelkarte {
  /// Der Name der Sammelkarte.
  String Name;

  /// Das Bild vom Berg.
  String Bild;

  /// Die Schwierigkeitsstufe der Karte (z. B. Bronze, Silber, Gold).
  Schwierigkeit schwierigkeit;

  /// Die Höhe des Berges/Zieles
  double Hoehe;

  /// Das Datum, an dem die Karte erstellt oder erhalten wurde.
  DateTime Datum;

  /// Erstellt eine neue [Sammelkarte] mit allen erforderlichen Eigenschaften.
  Sammelkarte(this.Name, this.Bild, this.schwierigkeit, this.Hoehe, this.Datum);
}
