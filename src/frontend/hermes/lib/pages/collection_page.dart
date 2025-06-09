import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:hermes/components/bottom_nav_bar.dart';
import 'package:hermes/components/sammelkarteGUI.dart';
import 'package:hermes/sammelkarteCollection.dart';
import 'package:hermes/validierungsmanager.dart';
import 'package:hermes/components/globals.dart';
import 'package:hermes/userManager.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  int state = 0;
  SammelkarteCollection collection = SammelkarteCollection();
  bool isLoading = true;

  final List<String> sortierKriterien = ['seltenheit', 'neueste', 'name', 'hoehe'];
  final List<IconData> sortierIcons = [
    Icons.star,          // Seltenheit
    Icons.schedule,      // Neueste
    Icons.sort_by_alpha, // Name
    Icons.straighten,    // Höhe
  ];
  int aktuellerSortIndex = 0;

  @override
  void initState() {
    super.initState();
    loadZiele();
  }

  Future<void> loadZiele() async {
    final result = await UserManager.getZiele();
    setState(() {
      collection = result;
      collection.sortierenNach(sortierKriterien[aktuellerSortIndex]); // Sortiere initial
      isLoading = false;
    });
  }

  void wechsleSortierung() {
    setState(() {
      aktuellerSortIndex = (aktuellerSortIndex + 1) % sortierKriterien.length;
      collection.sortierenNach(sortierKriterien[aktuellerSortIndex]);
    });
  }

  Future<void> readNfcTag() async {
    try {
      var availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
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
            print('NDEF Record: ${record.payload}');
          }
        }
      }

      List<int> cleaned = data[1].sublist(3);
      int? id = int.tryParse(String.fromCharCodes(cleaned));
      if (id == null) {
        throw Exception("ID konnte nicht extrahiert werden.");
      }

      print("ID: $id");
      await FlutterNfcKit.finish();
      setState(() => state = 2);
      await Future.delayed(Duration(seconds: 1));
      setState(() => state = 0);

      await Validierungsmanager.AddSammelkarteNFCGPS(context, id);
      await loadZiele();
    } catch (e) {
      print("Fehler beim Lesen: $e");
      await FlutterNfcKit.finish();
      setState(() => state = 3);
      await Future.delayed(Duration(seconds: 1));
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
                      ? Center(child: CircularProgressIndicator())
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
