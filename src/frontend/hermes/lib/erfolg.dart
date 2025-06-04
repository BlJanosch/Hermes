import 'schwierigkeit.dart';

class Erfolg {
  String name;
  String Beschreibung;
  Schwierigkeit schwierigkeit;
  Erfolg(this.name, this.Beschreibung, this.schwierigkeit);

  // 👇 DAS brauchst du:
  factory Erfolg.fromJson(Map<String, dynamic> json) {
    return Erfolg(
      json['Name'] as String,
      json['Beschreibung'] as String,
      Schwierigkeit.Bronze//Schwierigkeit.values.firstWhere((e) => e.toString() == 'Schwierigkeit.' + (json['schwierigkeit'] as String)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Beschreibung': Beschreibung,
      'Name': name,
      'Schwierigkeit': schwierigkeit
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
