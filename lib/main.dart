import 'package:flutter/material.dart';
import 'ScannerScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Important pour charger les plugins
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const ScannerScreen(), // Charge l'écran principal
    );
  }
}