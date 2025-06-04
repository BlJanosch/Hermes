import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

int state = 0; // 0 = initial, 1 = reading, 2 = success, 3 = error

Future<int> readNfcTag() async {
  try {
    state = 1; // Set state to reading
    NFCTag tag = await FlutterNfcKit.poll();

    List<List<int>> data = <List<int>>[];

    state = 2; // Set state to success
    print("NFC-Tag erkannt:");
    print("ID: ${tag.id}");
    print("Standard: ${tag.standard}");
    print("Typ: ${tag.type}");
    print("NDEF vorhanden: ${tag.ndefAvailable}");

    if (tag.ndefAvailable == true) {
      var ndef = await FlutterNfcKit.readNDEFRecords();
      for (var record in ndef) {
        if (record.payload != null) {
          data.add(record.payload!.toList());
          print('NDEF Record: ${record.payload}');
        }
      }
    }
    // en entfernen
    List<int> cleaned = data[1].sublist(3);
    print("test $cleaned");
    int? ID = int.tryParse(String.fromCharCodes(cleaned));
    if (ID == null) {
      throw Exception("ID konnte nicht aus den Daten extrahiert werden.");
    }
    print("ID: $ID");

    await FlutterNfcKit.finish();
    state = 0; // Reset state to initial
    return ID;
  } catch (e) {
    print("Fehler beim Lesen: $e");
    state = 3; // Set state to error
    await FlutterNfcKit.finish();
    state = 0; // Reset state to initial
    return -1; // Rückgabe -1 im Fehlerfall
  }
}
