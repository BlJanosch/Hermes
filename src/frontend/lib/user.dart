/// Repräsentiert einen Benutzer des Systems.
///
/// Enthält Anmeldedaten, Profilinformationen sowie Statistiken
/// wie gelaufene Kilometer und Höhenmeter.
class User {
  /// Die eindeutige ID des Benutzers.
  int ID;

  /// Der öffentliche Benutzername.
  String Benutzername;

  /// Das Passwort des Benutzers.
  String Passwort;

  /// Das Probilbild des Users.
  String Profilbild;

  /// Die insgesamt zurückgelegten Höhenmeter.
  double Hoehenmeter;

  /// Die insgesamt gelaufenen Kilometer.
  double KMGelaufen;

  /// Erstellt einen neuen [User] mit den Basisdaten.
  ///
  /// Die Felder [Hoehenmeter] und [KMGelaufen] sind optional
  /// und haben standardmäßig den Wert `0`.
  User(
    this.ID,
    this.Benutzername,
    this.Passwort,
    this.Profilbild, {
    this.Hoehenmeter = 0,
    this.KMGelaufen = 0,
  });
}
