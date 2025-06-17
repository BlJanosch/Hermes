import 'package:flutter/material.dart';
import 'package:hermes/pages/change_userdata.dart';
import 'package:hermes/pages/settings.dart';


class MoreSettings extends StatefulWidget {
  const MoreSettings({super.key});

  @override
  State<MoreSettings> createState() => _MoreSettingsState();
}

class _MoreSettingsState extends State<MoreSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      
      appBar: AppBar(
        title: Text(
          'Mehr Einstellungen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Settings()),
            );
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.manage_accounts, color: Colors.white,),
            title: Text(
              "Benutzername",
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white,),
            onTap: () {
              Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ChangeUserdata(ChangeType: "Benutzername",)),
            );
            },
          ),
          ListTile(
            leading: Icon(Icons.password, color: Colors.white,),
            title: Text(
              "Passwort",
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white,),
            onTap: () {
              Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ChangeUserdata(ChangeType: "Passwort",)),
            );
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.white,),
            title: Text(
              "Info",
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white,),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}