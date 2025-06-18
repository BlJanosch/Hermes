import 'package:flutter/material.dart';
import 'package:hermes/components/globals.dart';
import 'package:hermes/userManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:hermes/pages/settings.dart';


class ChangeUserdata extends StatefulWidget {
  final String ChangeType;
  

  const ChangeUserdata({super.key, required this.ChangeType});

  @override
  State<ChangeUserdata> createState() => _ChangeUserdataState();
}

class _ChangeUserdataState extends State<ChangeUserdata> {
  String username = '';
  String oldPassword = '';
  String profilbild = '';
  double hoehenmeter = 0;
  double kmgelaufen = 0;
  final TextEditingController _ersterInput = TextEditingController();
  final TextEditingController _zweiterInput = TextEditingController();
  final TextEditingController _dritterInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    try{
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
    }
    catch (e) {
      logger.w('Fehler beim Laden der alten Benutzerdaten $e');
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Fehler beim Laden der Benutzerdaten'),
            content: Text('Fehler: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
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
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
            decoration: InputDecoration(
              labelText: 'Altes Passwort',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            obscureText: widget.ChangeType == "Benutzername" ? false : true,
            style: TextStyle(color: Colors.white),
          ),
        SizedBox(height: 16),
        TextField(
          controller: _zweiterInput,
          decoration: InputDecoration(
            labelText: widget.ChangeType == 'Benutzername' ? 'Neuer Benutzername' : 'Neues Passwort',
            labelStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          obscureText: widget.ChangeType == "Benutzername" ? false : true,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 16),
        if (widget.ChangeType == 'Passwort')
          TextField(
            controller: _dritterInput,
            decoration: InputDecoration(
              labelText: 'Neues Passwort',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            obscureText: true, 
            style: TextStyle(color: Colors.white),
          ),
        SizedBox(height: 32),
        ElevatedButton(
          onPressed: () async {
            if (widget.ChangeType == "Benutzername"){
              try{
                UserManager.updateData(_zweiterInput.text, "", hoehenmeter, kmgelaufen, profilbild);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('username', _zweiterInput.text);
              }
              catch (e){
                logger.w('Fehler beim Aktualiseren der Daten: $e');
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Fehler beim Aktualisieren'),
                      content: Text('Fehler: $e'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
              }
              logger.i('Benutzername erfolgreich aktualisiert');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Settings()),
              );
            }
            else{
              if (BCrypt.checkpw(_ersterInput.text, oldPassword)){
                if (_zweiterInput.text == _dritterInput.text){
                  try{
                    UserManager.updateData(username, _dritterInput.text, hoehenmeter, kmgelaufen, profilbild);
                  }
                  catch (e){
                    logger.w('Fehler beim Aktualisern der Daten: $e');
                    showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Fehler beim Aktualisieren'),
                      content: Text('Fehler: $e'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                  }
                  
                  logger.i('Passwort erfolgreich aktualisiert');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Settings()),
                  );
                }
                else{
                  logger.w('Neue Passwörter stimmen nicht überein!');
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Fehler beim Aktualisieren'),
                      content: Text('Neue Passwörter müssen übereinstimmen'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
              else{
                logger.w('Altes Passwort ist falsch!');
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Fehler beim Aktualisieren'),
                    content: Text('Altes Passwort falsch!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            }
          },
          child: Text('Speichern'),
        ),
          ],
        ),
      ),
    );
  }
}