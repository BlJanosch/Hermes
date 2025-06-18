import 'sammelkarte.dart';

/// Eine Sammlung von [Sammelkarte]-Objekten.
///
/// Diese Klasse ermöglicht das Verwalten und Sortieren von Sammelkarten
/// nach verschiedenen Kriterien wie Name, Datum, Höhe oder Schwierigkeitsgrad.
class SammelkarteCollection {
  /// Die Liste aller enthaltenen Sammelkarten.
  List<Sammelkarte> sammelkarten = [];

  /// Erstellt eine leere Sammlung von Sammelkarten.
  SammelkarteCollection();

  /// Sortiert die Liste der Sammelkarten nach dem angegebenen [kriterium].
  ///
  /// Gültige Werte für [kriterium] sind:
  /// - `'seltenheit'`: Sortiert nach [Schwierigkeit], von selten (Gold) zu häufig (Bronze).
  /// - `'neueste'`: Sortiert nach [Datum], von neu nach alt.
  /// - `'name'`: Sortiert alphabetisch nach dem Namen.
  /// - `'höhe'` oder `'hoehe'`: Sortiert numerisch nach der Höhe.
  ///
  /// Groß-/Kleinschreibung wird ignoriert.
  void sortierenNach(String kriterium) {
    switch (kriterium.toLowerCase()) {
      case 'seltenheit':
        sammelkarten.sort((a, b) => b.schwierigkeit.index.compareTo(a.schwierigkeit.index));
        break;
      case 'neueste':
        sammelkarten.sort((a, b) => b.Datum.compareTo(a.Datum));
        break;
      case 'name':
        sammelkarten.sort((a, b) => a.Name.compareTo(b.Name));
        break;
      case 'höhe':
      case 'hoehe':
        sammelkarten.sort((a, b) => a.Hoehe.compareTo(b.Hoehe));
        break;
    }
  }
}
