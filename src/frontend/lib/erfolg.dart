import 'schwierigkeit.dart';

/// Repräsentiert einen Erfolg oder eine Auszeichnung in einer Anwendung.
///
/// Ein Erfolg besteht aus einem Namen, einer Beschreibung und einer
/// Schwierigkeitsstufe (z. B. Bronze, Silber, Gold).
class Erfolg {
  /// Der Name des Erfolgs.
  String name;

  /// Die Beschreibung des Erfolgs.
  String Beschreibung;

  /// Die Schwierigkeitsstufe des Erfolgs.
  Schwierigkeit schwierigkeit;

  /// Erstellt einen neuen [Erfolg] mit Name, Beschreibung und Schwierigkeit.
  Erfolg(this.name, this.Beschreibung, this.schwierigkeit);

  /// Erstellt eine neue Instanz von [Erfolg] aus einem JSON-Objekt.
  ///
  factory Erfolg.fromJson(Map<String, dynamic> json) {
    return Erfolg(
      json['Name'] as String,
      json['Beschreibung'] as String,
      Schwierigkeit.Bronze // TODO: Aus dem JSON-Wert ableiten
    );
  }

  /// Konvertiert das Objekt in ein JSON-kompatibles Map-Format.
  Map<String, dynamic> toJson() {
    return {
      'Beschreibung': Beschreibung,
      'Name': name,
      'Schwierigkeit': schwierigkeit
    };
  }

  /// Gibt eine String-Darstellung des Erfolgs zurück.
  ///
  /// Dies entspricht der Ausgabe der [toJson] Methode.
  @override
  String toString() {
    return toJson().toString();
  }
}
