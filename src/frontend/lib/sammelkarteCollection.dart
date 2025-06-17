import 'sammelkarte.dart';

class SammelkarteCollection {
  List<Sammelkarte> sammelkarten = [];

  SammelkarteCollection();

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
