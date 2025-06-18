import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hermes/components/globals.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Zeigt die Bestenliste für eine bestimmte Kategorie an.
/// 
/// Die Kategorie bestimmt, nach welchem Wert die Liste sortiert und gefiltert wird.
/// Mögliche Kategorien sind z.B. 'kmgelaufen', 'hoehenmeter' oder 'berge'.
class BestenlistePage extends StatelessWidget {
  /// Die Kategorie für die Bestenliste.
  final String category;

  /// Erstellt eine [BestenlistePage] mit der angegebenen [category].
  const BestenlistePage({super.key, required this.category});

  /// Lädt die aktuell gespeicherte Benutzer-ID aus den SharedPreferences.
  /// 
  /// Gibt die User-ID zurück oder `null`, falls keine ID gespeichert ist.
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  /// Lädt die Bestenliste vom Server.
  /// 
  /// Nutzt die aktuell gespeicherte User-ID und die angegebene Kategorie als Filter.
  /// Gibt eine Liste von Maps zurück, die die Einträge der Bestenliste darstellen.
  Future<List<Map<String, dynamic>>> loadleaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://$serverIP:8080/user/bestenliste?userID=$id&filterDB=$category');
    final response = await http.get(url);
    final result = json.decode(response.body);
    print(result);

    return List<Map<String, dynamic>>.from(result);
  }

  /// Bestimmt die Farbe der Medaille für die angegebene [place] und [entry].
  /// 
  /// Platz 1 bekommt Gold, Platz 2 Silber, Platz 3 Bronze.
  /// Falls der Eintrag zum aktuellen Benutzer gehört, wird eine grüne Hervorhebung verwendet.
  /// Für alle anderen wird Weiß zurückgegeben.
  Future<Color> getMedalColor(int place, Map<String, dynamic> entry) async {
    int? userID = await getUserId();
    switch (place) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silber
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      case _ when entry['ID'] == userID:
        return const Color(0xFF4A742F); // Aktueller User hervorheben
      default:
        return Colors.white;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /// Titel abhängig von der Kategorie
        title: Text(
          category == 'kmgelaufen' 
            ? 'Bestenliste - Gelaufene km' 
            : category == 'hoehenmeter' 
              ? 'Bestenliste - Höhenmeter' 
              : category == 'berge' 
                ? 'Bestenliste - Berge' 
                : 'Unbekannt',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      backgroundColor: const Color(0xFF1E1E1E),

      /// Baut die Bestenliste asynchron auf
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadleaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            /// Lade-Indikator anzeigen während der Datenabfrage
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            /// Fehleranzeige bei Problemen mit der Datenabfrage
            return Center(child: Text('Fehler beim Laden der Bestenliste', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            /// Nachricht, wenn keine Daten vorhanden sind
            return const Center(child: Text('Keine Daten verfügbar', style: TextStyle(color: Colors.white)));
          }

          final leaderboardData = snapshot.data!;

          /// Weitere FutureBuilder um die User-ID zu laden
          return FutureBuilder<int?>(
            future: getUserId(),
            builder: (context, userSnapshot) {
              final userId = userSnapshot.data;
              
              /// ListView für die Anzeige der Bestenliste
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: leaderboardData.length,
                itemBuilder: (context, index) {
                  final place = index != leaderboardData.length - 1 
                    ? index + 1 
                    : leaderboardData[index]["Platzierung"];

                  final entry = leaderboardData[index];

                  /// FutureBuilder zur Bestimmung der Medaillenfarbe
                  return FutureBuilder<Color>(
                    future: getMedalColor(place, entry),
                    builder: (context, colorSnapshot) {
                      final medalColor = colorSnapshot.data ?? Colors.white70;

                      return Card(
                        color: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),

                        /// Einzelner Listeneintrag
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: medalColor,
                            child: Text(
                              '$place',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          title: Text(
                            entry['Benutzername'] ?? 'Unbekannt',
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),

                          /// Anzeige des Wertes je nach Kategorie mit Einheit
                          trailing: Text(
                            category == 'kmgelaufen' 
                              ? '${(entry['kmgelaufen'] ?? 0).toStringAsFixed(1)} km' 
                              : category == 'hoehenmeter' 
                                ? '${(entry['hoehenmeter'] ?? 0).toStringAsFixed(1)} m' 
                                : '${(entry['anzahlBerge'] ?? 0).toString()} Berge',
                            style: TextStyle(color: medalColor, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
