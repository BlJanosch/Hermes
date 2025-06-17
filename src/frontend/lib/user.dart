class User {
  int ID;
  String Benutzername;
  String Passwort;
  String Profilbild;
  double Hoehenmeter;
  double KMGelaufen;

  User(this.ID, this.Benutzername, this.Passwort, this.Profilbild, {this.Hoehenmeter = 0, this.KMGelaufen = 0});
}