import 'package:flutter/material.dart';
import 'package:hermes/components/globals.dart';
import 'package:hermes/userManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:hermes/pages/settings.dart';

/// Seite zum Ändern von Benutzerdaten wie Benutzername oder Passwort.
/// 
/// Je nach [ChangeType] zeigt die Seite unterschiedliche Eingabefelder an.
/// Unterstützte Werte für [ChangeType] sind "Benutzername" und "Passwort".
class ChangeUserdata extends StatefulWidget {
  /// Der Typ der zu ändernden Benutzerdaten.
  final String ChangeType;

  /// Konstruktor, der den Typ der Änderung benötigt.
  const ChangeUserdata({super.key, required this.ChangeType});

  @override
  State<ChangeUserdata> createState() => _ChangeUserdataState();
}

class _ChangeUserdataState extends State<ChangeUserdata> {
  /// Aktueller Benutzername, geladen aus den Benutzerdaten.
  String username = '';

  /// Altes Passwort.
  String oldPassword = '';

  /// Profilbild des Benutzers.
  String profilbild = '';

  /// Gesamte Höhenmeter, die der Benutzer gelaufen ist.
  double hoehenmeter = 0;

  /// Gesamte Kilometer, die der Benutzer gelaufen ist.
  double kmgelaufen = 0;

  /// Controller für das erste Eingabefeld (z.B. altes Passwort).
  final TextEditingController _ersterInput = TextEditingController();

  /// Controller für das zweite Eingabefeld (z.B. neuer Benutzername oder neues Passwort).
  final TextEditingController _zweiterInput = TextEditingController();

  /// Controller für das dritte Eingabefeld (z.B. Passwort-Wiederholung).
  final TextEditingController _dritterInput = TextEditingController();

  @override
  void initState() {
    super.initState();

    try {
      UserManager.loadUserData().then((userData) {
        if (!mounted) return;
        setState(() {
          username = userData['username'] ?? 'Unbekannt';
          oldPassword = userData['passwort'];
          profilbild = userData['profilbild'];
          hoehenmeter = userData['hoehenmeter'] ?? 0;
          kmgelaufen = userData['kmgelaufen'] ?? 0;
        });
        logger.i('Alte Benutzerdaten erfolgreich geladen');
      });
    } catch (e) {
      logger.w('Fehler beim Laden der alten Benutzerdaten $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fehler beim Laden der Benutzerdaten'),
          content: Text('Fehler: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),

      appBar: AppBar(
        title: Text(
          widget.ChangeType,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Settings()),
            );
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.ChangeType == "Passwort")
              TextField(
                controller: _ersterInput,
                decoration: const InputDecoration(
                  labelText: 'Altes Passwort',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _zweiterInput,
              decoration: InputDecoration(
                labelText: widget.ChangeType == 'Benutzername' ? 'Neuer Benutzername' : 'Neues Passwort',
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              obscureText: widget.ChangeType == "Benutzername" ? false : true,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            if (widget.ChangeType == 'Passwort')
              TextField(
                controller: _dritterInput,
                decoration: const InputDecoration(
                  labelText: 'Neues Passwort wiederholen',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (widget.ChangeType == "Benutzername") {
                  try {
                    await UserManager.updateData(_zweiterInput.text, "", hoehenmeter, kmgelaufen, profilbild);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('username', _zweiterInput.text);
                    logger.i('Benutzername erfolgreich aktualisiert');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Settings()),
                    );
                  } catch (e) {
                    logger.w('Fehler beim Aktualisieren der Daten: $e');
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Fehler beim Aktualisieren'),
                        content: Text('Fehler: $e'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  // Passwort ändern
                  if (BCrypt.checkpw(_ersterInput.text, oldPassword)) {
                    if (_zweiterInput.text == _dritterInput.text) {
                      try {
                        await UserManager.updateData(username, _dritterInput.text, hoehenmeter, kmgelaufen, profilbild);
                        logger.i('Passwort erfolgreich aktualisiert');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Settings()),
                        );
                      } catch (e) {
                        logger.w('Fehler beim Aktualisieren der Daten: $e');
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Fehler beim Aktualisieren'),
                            content: Text('Fehler: $e'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      logger.w('Neue Passwörter stimmen nicht überein!');
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Fehler beim Aktualisieren'),
                          content: const Text('Neue Passwörter müssen übereinstimmen'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    logger.w('Altes Passwort ist falsch!');
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Fehler beim Aktualisieren'),
                        content: const Text('Altes Passwort falsch!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
