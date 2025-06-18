import 'package:flutter/material.dart';
import 'package:hermes/components/bottom_nav_bar.dart';
import 'package:hermes/components/leaderboardsingle.dart'; // deine Navbar importieren

/// Seite, die eine mehrseitige Bestenliste mit einer Bottom Navigation anzeigt.
///
/// Die Seite beinhaltet drei verschiedene Kategorien (km gelaufen, Höhenmeter, Berge),
/// die per PageView horizontal geswiped werden können. Eine kleine Indikatorleiste zeigt
/// an, auf welcher Seite man sich befindet.
///
/// Die untere Navigation (`MyBottomNavBar`) ist fest am unteren Bildschirmrand positioniert.
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  /// Controller zur Steuerung und Überwachung der PageView.
  final PageController _controller = PageController();

  /// Index der aktuell aktiven Seite im PageView.
  int _currentPage = 0;

  /// Liste der Seiten (Widgets) mit unterschiedlichen Kategorien für die Bestenliste.
  final List<Widget> _pages = [
    Center(child: BestenlistePage(category: "kmgelaufen")),
    Center(child: BestenlistePage(category: "hoehenmeter")),
    Center(child: BestenlistePage(category: "berge")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
      body: Stack(
        children: [
          Column(
            children: [
              /// Der Hauptbereich: Ein PageView, das durch verschiedene Kategorien der Bestenliste swiped.
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,

                  /// Aktualisiert den aktuellen Seitenindex, wenn der Nutzer swiped.
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },

                  /// Baut die aktuelle Seite im PageView.
                  itemBuilder: (context, index) => _pages[index],
                ),
              ),

              const SizedBox(height: 16),

              /// Die Indikatorleiste, die anzeigt, welche Seite aktuell aktiv ist.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFFBBA430)
                          : Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 130),
            ],
          ),

          /// Die Bottom Navigation Bar, fest am unteren Bildschirmrand positioniert.
          Positioned(
            bottom: 10.0,
            left: 5,
            right: 5,
            child: MyBottomNavBar(currentIndex: 2),
          ),
        ],
      ),
    );
  }
}
