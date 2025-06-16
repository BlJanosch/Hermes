import 'schwierigkeit.dart';

class Erfolg {
  String name;
  String Beschreibung;
  Schwierigkeit schwierigkeit;
  Erfolg(this.name, this.Beschreibung, this.schwierigkeit);

  factory Erfolg.fromJson(Map<String, dynamic> json) {
    return Erfolg(
      json['Name'] as String,
      json['Beschreibung'] as String,
      Schwierigkeit.Bronze
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
