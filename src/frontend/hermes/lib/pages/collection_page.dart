import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:hermes/components/bottom_nav_bar.dart';
import 'package:hermes/components/sammelkarte.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  int state = 0; // 0 = idle, 1 = reading, 2 = success, 3 = error

  Future<void> readNfcTag() async {
    try {
      setState(() => state = 1); // reading
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
      int? ID = int.tryParse(String.fromCharCodes(cleaned));
      if (ID == null) {
        throw Exception("ID konnte nicht extrahiert werden.");
      }

      print("ID: $ID");
      await FlutterNfcKit.finish();
      setState(() => state = 2); // success
      await Future.delayed(Duration(seconds: 1));
      setState(() => state = 0); // reset
    } catch (e) {
      print("Fehler beim Lesen: $e");
      await FlutterNfcKit.finish();
      setState(() => state = 3); // error
      await Future.delayed(Duration(seconds: 1));
      setState(() => state = 0); // reset
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color.fromRGBO(187, 164, 48, 1.00),
            width: double.infinity,
            padding: const EdgeInsets.only(top: 45.0),
            child: Column(
              children: [
                const Text(
                  "Deine Sammelkarten",
                  style: TextStyle(fontSize: 35, fontFamily: "Sans"),
                ),
                Wrap(
                  children: const [
                    MySammelkarte(),
                    MySammelkarte(),
                    MySammelkarte(),
                    MySammelkarte(),
                    MySammelkarte(),
                    MySammelkarte(),
                    MySammelkarte(),
                  ],
                )
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
                    : Colors.black.withOpacity(0.5),
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
