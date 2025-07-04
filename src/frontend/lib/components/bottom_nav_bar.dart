import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hermes/pages/home.dart';
import 'package:hermes/pages/collection_page.dart';
import 'package:hermes/pages/leaderboard.dart';
import 'package:hermes/pages/settings.dart';

/// Ein Bottom Navigation Bar Widget mit 4 Tabs für die Navigation zwischen den Hauptseiten.
///
/// Verwendet das Paket `google_nav_bar` für eine moderne und anpassbare Navigation.
///
/// Die Tabs sind:
/// 0. Home
/// 1. CollectionPage
/// 2. LeaderboardPage
/// 3. Settings
///
/// Navigiert per `Navigator.pushReplacement`, um den aktuellen Screen zu ersetzen.
///
/// [currentIndex] gibt den aktuell aktiven Tab an.
class MyBottomNavBar extends StatelessWidget {
  /// Der aktuell ausgewählte Tab-Index.
  final int currentIndex;

  /// Erzeugt eine neue Bottom Navigation Bar mit dem aktuellen Index.
  const MyBottomNavBar({super.key, required this.currentIndex});

  /// Behandelt Tab-Wechsel, navigiert zur entsprechenden Seite,
  /// wenn der neue Index sich vom aktuellen unterscheidet.
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LeaderboardPage()),
        );
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
    final double navBarHeight = MediaQuery.of(context).size.height * 0.10;
    final double horizontalMargin = MediaQuery.of(context).size.width * 0.02;

    return SizedBox(
      height: navBarHeight.clamp(60, 100),
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
          tabMargin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 5),
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
