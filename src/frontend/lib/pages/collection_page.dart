import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:hermes/components/bottom_nav_bar.dart';
import 'package:hermes/components/sammelkarteGUI.dart';
import 'package:hermes/sammelkarteCollection.dart';
import 'package:hermes/validierungsmanager.dart';
import 'package:hermes/components/globals.dart';
import 'package:hermes/userManager.dart';

/// Seite, die die Sammlung von Sammelkarten des Benutzers anzeigt.
///
/// Die Seite ermöglicht das Sortieren der Sammlung nach verschiedenen Kriterien,
/// sowie das Einlesen von NFC-Tags, um neue Sammelkarten hinzuzufügen.
class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  /// Status der NFC-Leseaktion
  /// 0: idle, 1: scanning, 2: erfolgreich, 3: Fehler
  int state = 0;

  /// Sammlung der Sammelkarten
  SammelkarteCollection collection = SammelkarteCollection();

  /// Ladezustand, true während Daten geladen werden
  bool isLoading = true;

  /// Liste der Sortierkriterien, nach denen die Sammlung sortiert werden kann
  final List<String> sortierKriterien = ['seltenheit', 'neueste', 'name', 'hoehe'];

  /// Icons passend zu den Sortierkriterien
  final List<IconData> sortierIcons = [
    Icons.star,          // Seltenheit
    Icons.schedule,      // Neueste
    Icons.sort_by_alpha, // Name
    Icons.straighten,    // Höhe
  ];

  /// Index des aktuell ausgewählten Sortierkriteriums
  int aktuellerSortIndex = 0;

  @override
  void initState() {
    super.initState();
    // Lade die Sammelkarten aus dem UserManager beim Start
    loadZiele();
  }

  /// Lädt die Sammelkarten des Benutzers und sortiert sie initial
  Future<void> loadZiele() async {
    final result = await UserManager.getZiele();
    setState(() {
      collection = result;
      collection.sortierenNach(sortierKriterien[aktuellerSortIndex]);
      isLoading = false;
    });
  }

  /// Wechselt das Sortierkriterium zyklisch durch und sortiert die Sammlung neu
  void wechsleSortierung() {
    setState(() {
      aktuellerSortIndex = (aktuellerSortIndex + 1) % sortierKriterien.length;
      collection.sortierenNach(sortierKriterien[aktuellerSortIndex]);
      logger.i('Ziele wurden nach ${sortierKriterien[aktuellerSortIndex]} sortiert');
    });
  }

  /// Liest einen NFC-Tag aus und fügt ggf. eine Sammelkarte hinzu
  Future<void> readNfcTag() async {
    try {
      var availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        logger.w('NFC wird auf diesem Gerät nicht unterstützt oder ist deaktiviert!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('NFC wird auf diesem Gerät nicht unterstützt oder ist deaktiviert.')),
        );
        return;
      }

      setState(() => state = 1); 
      NFCTag tag = await FlutterNfcKit.poll();

      List<List<int>> data = <List<int>>[];

      if (tag.ndefAvailable == true) {
        var ndef = await FlutterNfcKit.readNDEFRecords();
        for (var record in ndef) {
          if (record.payload != null) {
            data.add(record.payload!.toList());
            logger.i('NDEF Record: ${record.payload}');
          }
        }
      }

      List<int> cleaned = data[1].sublist(3);
      int? id = int.tryParse(String.fromCharCodes(cleaned));
      if (id == null) {
        logger.e('ID konnte nicht von NFC Chip extrahiert werden');
        throw Exception("ID konnte nicht extrahiert werden.");
      }

      logger.i('ID erfolgreich extrahiert: $id');
      await FlutterNfcKit.finish();

      setState(() => state = 2); 
      await Future.delayed(const Duration(seconds: 1));
      setState(() => state = 0); 

      await Validierungsmanager.AddSammelkarteNFCGPS(context, id);
      await loadZiele();
    } catch (e) {
      logger.w('Fehler beim Lesen des NFC Chips: $e');
      await FlutterNfcKit.finish();
      setState(() => state = 3); 
      await Future.delayed(const Duration(seconds: 1));
      setState(() => state = 0); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color.fromRGBO(30, 30, 30, 1),
            width: double.infinity,
            padding: const EdgeInsets.only(top: 45.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Deine Sammelkarten",
                      style: TextStyle(fontSize: 28, fontFamily: "Sans", color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: wechsleSortierung,
                      icon: Icon(
                        sortierIcons[aktuellerSortIndex],
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Sortieren nach: ${sortierKriterien[aktuellerSortIndex]}',
                    ),
                  ],
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: Wrap(
                              children: collection.sammelkarten
                                  .map((karte) => MySammelkarte(karte: karte))
                                  .toList(),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 200),
              ],
            ),
          ),

          Positioned(
            bottom: 130.0,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: readNfcTag,
                backgroundColor: state == 1
                    ? Colors.red.withOpacity(0.7)
                    : const Color.fromARGB(255, 178, 180, 16).withOpacity(0.5),
                child: Icon(
                  state == 0
                      ? Icons.add_rounded
                      : state == 1
                          ? Icons.document_scanner_rounded
                          : state == 2
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const Positioned(
            bottom: 10.0,
            left: 5,
            right: 5,
            child: MyBottomNavBar(
              currentIndex: 1,
            ),
          ),
        ],
      ),
    );
  }
}
