import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  const MyBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GNav(
          backgroundColor: Colors.black.withOpacity(0.5),
          color: Colors.grey[400],
          activeColor: Colors.grey.shade700,
          tabActiveBorder: Border.all(color: Colors.white),
          tabBackgroundColor: Colors.grey.shade100,
          mainAxisAlignment: MainAxisAlignment.center,
          tabBorderRadius: 10,
          tabMargin: EdgeInsets.symmetric(horizontal: 10),
          tabs: const [
            GButton(
              icon: Icons.home,
            ),
            GButton(
              icon: Icons.collections,
            ),
            GButton(icon: Icons.leaderboard),
            GButton(icon: Icons.settings),
          ],
        ),
      ),
    );
  }
}