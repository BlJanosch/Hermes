import 'package:flutter/material.dart';
import 'package:hermes/components/bottom_nav_bar.dart';
import 'package:hermes/components/erfolgcircle.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.7),
      appBar: AppBar(
        title: Text('Einstellungen'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.menu), 
            onPressed: () {},
          ),
        ],
      ),
      // KI: Erstelle mir die UI gemäß der Skizze.
      body: Stack(
        children: [
          Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
            // Top card with info and profile icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Zentriert vertikal
              children: [
              // Info card
              Container(
                width: 180,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                  ),
                ],
                ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                  'Name:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 2),
                  Text(
                  'km: 121 km',
                  style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 2),
                  Text(
                  'Berge: 7',
                  style: TextStyle(fontSize: 13),
                  ),
                ],
                ),
              ),
              Spacer(),
              // Profile icon
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue,
                child: Text('A'),
              ),
              ],
            ),
            SizedBox(height: 32),
            // Achievements grid
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
              "Erfolge",
              style: TextStyle(fontSize: 24,),
              textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 16),
            Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Unlocked achievement (shaded)
              Erfolgcircle(icon: Icons.check, text: 'Erfolg 1'),
              // Unlocked achievement (shaded)
              Erfolgcircle(icon: Icons.lock, text: 'Erfolg 2'),
              // Locked achievement
              Erfolgcircle(icon: Icons.check, text: 'Erfolg 3'),
              // Locked achievement
            ],
              ),
              SizedBox(height: 16),
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (index) => Erfolgcircle(icon: Icons.check, text: 'Erfolg ${index + 4}'),
            ),
              ),
            SizedBox(height: 16),
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (index) => Erfolgcircle(icon: Icons.check, text: 'Erfolg ${index + 7}'),
            ),
              ),
            ],
          ),
            ),
          ],
        ),
          ),
          // Bottom navigation bar
          Positioned(
        bottom: 10.0,
        left: 5,
        right: 5,
        child: MyBottomNavBar(currentIndex: 3),
          ),
        ],
      ),
    );
  }
}