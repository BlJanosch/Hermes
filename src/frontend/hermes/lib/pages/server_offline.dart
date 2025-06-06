import 'package:flutter/material.dart';
import 'package:hermes/components/globals.dart';
import 'package:hermes/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServerOfflinePage extends StatelessWidget {
  const ServerOfflinePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                color: const Color(0xFF4A742F),
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Server Offline',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF4A742F),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Die Verbindung zum Server konnte nicht hergestellt werden.\n'
                'Bitte überprüfe deine Internetverbindung oder versuche es später erneut.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBBA430),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFBBA430),
                      ),
                    ),
                  );

                  final online = await isServerOnline('http://$serverIP:8080/ui');

                  Navigator.of(context, rootNavigator: true).pop();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          MyApp(isLoggedIn: isLoggedIn, online: online),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Erneut versuchen',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> isServerOnline(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
