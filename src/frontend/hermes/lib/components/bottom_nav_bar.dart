import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  const MyBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GNav(
        tabs: [
          GButton(
            icon: Icons.home,
            text: "Home",
          ),
          GButton(
            icon: Icons.card_membership,
            text: "Sammelkarten",
          ),
          GButton(icon: Icons.leaderboard, text: "Leaderboard",),
          GButton(icon: Icons.settings, text: "User",),
        ],
      ),
    );
  }
}