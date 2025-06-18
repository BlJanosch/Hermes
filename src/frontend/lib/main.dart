import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermes/components/globals.dart';
import 'package:hermes/pages/home.dart';
import 'package:hermes/pages/login.dart';
import 'package:hermes/pages/server_offline.dart';
import 'package:hermes/userManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Prüft, ob der Server unter der angegebenen URL erreichbar ist.
///
/// Führt eine HTTP-GET-Anfrage mit einem Timeout von 2 Sekunden aus.
/// Gibt `true` zurück, wenn der Server eine Antwort liefert, andernfalls `false`.
///
/// Parameter:
/// - [url]: Die vollständige URL des Servers, der überprüft werden soll.
///
/// Rückgabe:
/// - Ein [Future] mit dem Ergebnis `true`, wenn der Server online ist,
///   oder `false`, wenn ein Fehler auftritt oder das Timeout erreicht wird.
Future<bool> isServerOnline(String url) async {
  try {
    final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 2));
    return true;
  } catch (e) {
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  bool online = await isServerOnline('http://$serverIP:8080/ui');
  var data;
  try{
    data = await UserManager.loadUserData();
  }
  catch (e){
    data = [];
  }
  bool AccountStillExists = data.length == 0 ? false : true;

  runApp(MyApp(isLoggedIn: isLoggedIn, online: online, AccountStillExists: AccountStillExists,));
}

// Logging included
class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool online;
  final bool AccountStillExists;

  const MyApp({super.key, required this.isLoggedIn, required this.online, required this.AccountStillExists});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hermes',
      home: Builder(
        builder: (context) {
          if (!online) {
            logger.w('Server is offline');
            return const ServerOfflinePage();
          }
          if (isLoggedIn && AccountStillExists) {
            logger.i('Benutzer ist bereits angemeldet... Login wird übersprungen');
            return const Home();
          } else {
            logger.i('Benutzer ist noch nicht angemeldet... Wird auf Login Page weitergeleitet');
            return const Login();
          }
        }
      ),
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        fontFamily: "Sans",
      ),
    );
  }
}
