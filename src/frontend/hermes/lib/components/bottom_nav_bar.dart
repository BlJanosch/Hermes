import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hermes/pages/home.dart';
import 'package:hermes/pages/collection_page.dart';
import 'package:hermes/pages/settings.dart';

class MyBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const MyBottomNavBar({super.key, required this.currentIndex});

  void _onTabChange(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CollectionPage()),
        );
        break;
      case 2:
        // Hier ggf. Leaderboard-Seite einfügen
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Settings()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GNav(
          selectedIndex: currentIndex,
          onTabChange: (index) => _onTabChange(context, index),
          backgroundColor: Colors.black.withOpacity(0.5),
          color: Colors.grey[400],
          activeColor: Colors.grey.shade700,
          tabActiveBorder: Border.all(color: Colors.white),
          tabBackgroundColor: Colors.grey.shade100,
          mainAxisAlignment: MainAxisAlignment.center,
          tabBorderRadius: 10,
          tabMargin: EdgeInsets.symmetric(horizontal: 10),
          tabs: const [
            GButton(icon: Icons.home),
            GButton(icon: Icons.collections),
            GButton(icon: Icons.leaderboard),
            GButton(icon: Icons.settings),
          ],
        ),
      ),
    );
  }
}