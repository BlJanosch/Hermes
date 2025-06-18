import 'package:flutter/material.dart';
import 'package:hermes/components/globals.dart';
import 'package:hermes/userManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:hermes/pages/settings.dart';
import 'package:url_launcher/url_launcher.dart';


class Info extends StatefulWidget {
  
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      
      appBar: AppBar(
        title: Text(
          'Info',
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
        leading: Icon(Icons.info, color: Colors.white),
        title: Text('App Version', style: TextStyle(color: Colors.white)),
        subtitle: Text('1.0.0', style: TextStyle(color: Colors.white70)),
          ),
          Divider(color: Colors.white24),
          ListTile(
        leading: Icon(Icons.person, color: Colors.white),
        title: Text('Entwickler', style: TextStyle(color: Colors.white)),
        subtitle: Text('Jannik \nNoah', style: TextStyle(color: Colors.white70)),
          ),
          Divider(color: Colors.white24),
          ListTile(
        leading: Icon(Icons.map, color: Colors.white),
        title: Text('OpenStreetMap', style: TextStyle(color: Colors.white)),
        subtitle: GestureDetector(
          onTap: () {
            launchUrl(Uri.parse('https://www.openstreetmap.org/copyright'));
          },
          child: Text(
            '© OpenStreetMap contributors',
            style: TextStyle(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
          ),
          Divider(color: Colors.white24),
        ListTile(
        leading: Icon(Icons.link, color: Colors.white),
        title: Text('Karten', style: TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
          launchUrl(Uri.parse('https://de.vecteezy.com/vektorkunst/48189557-himmel-sternenklar-universum-hintergrund-dunkelblau-himmel-galaxis-raum-wolke-mit-nebel-und-sterne'));
              },
              child: Text(
          'Galaktisch',
          style: TextStyle(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
              ),
            ),
            GestureDetector(
              onTap: () {
          launchUrl(Uri.parse('https://de.vecteezy.com/vektorkunst/15973314-abstrakter-vektorhintergrund-mit-goldenem-farbverlauf-und-weich-leuchtender-hintergrund-luxurioses-goldhintergrunddesign-vektor-design-hintergrund'));
              },
              child: Text(
          'Gold',
          style: TextStyle(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
              ),
            ),
            GestureDetector(
              onTap: () {
          launchUrl(Uri.parse('https://de.vecteezy.com/vektorkunst/50384759-einfach-grau-gradient-hintergrund-design'));
              },
              child: Text(
          'Silber',
          style: TextStyle(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
              ),
            ),
            GestureDetector(
              onTap: () {
          launchUrl(Uri.parse('https://de.vecteezy.com/vektorkunst/46436817-gradient-bunt-hintergrund'));
              },
              child: Text(
          'Bronze',
          style: TextStyle(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
              ),
            ),
            GestureDetector(
              onTap: () {
          launchUrl(Uri.parse('https://de.vecteezy.com/vektorkunst/447228-eine-mauer-aus-stein'));
              },
              child: Text(
          'Stein',
          style: TextStyle(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
              ),
            ),
            GestureDetector(
              onTap: () {
          launchUrl(Uri.parse('https://de.vecteezy.com/vektorkunst/237970-abstrakter-realistischer-holzerner-beschaffenheitshintergrund'));
              },
              child: Text(
          'Holz',
          style: TextStyle(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
              ),
            ),
          ],
        ),
            ),
          Divider(color: Colors.white24),
          ListTile(
        leading: Icon(Icons.link, color: Colors.white),
        title: Text('Berge', style: TextStyle(color: Colors.white)),
        subtitle: Text('Bilder von Bergen sind nicht alle Lizenzfrei', style: TextStyle(color: Colors.white70)),
          ),
      ],
    ),
  );
  }
}