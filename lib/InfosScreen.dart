import 'package:flutter/material.dart';
import 'ScannerScreen.dart';


class InfosScreen extends StatefulWidget {

  @override
  _InfosScreenState createState() => _InfosScreenState();
}

class _InfosScreenState extends State<InfosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confidentialité des données"),
        backgroundColor: ScannerScreen.color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🔒 Aucune donnée collectée",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Cette application respecte votre vie privée.\n"
                  "Nous ne collectons, ne stockons et ne partageons **aucune donnée personnelle**.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "📌 Pas de suivi publicitaire",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Nous n'utilisons aucun suivi, aucun tracker et aucune publicité ciblée.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "📡 Pas d'accès à Internet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Cette application fonctionne **entièrement hors ligne** et n’accède pas à Internet.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
