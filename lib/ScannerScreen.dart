import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reorderables/reorderables.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'PDFPreviewScreen.dart';
import 'Utils.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  List<String> _pictures = [];
  List<String> _selectedPictures = [];
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de Documents'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          if (_pictures.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.info_outlined),
              onPressed: _selectedPictures.isNotEmpty ? null : null,
              tooltip: "Exporter en PDF",
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _isScanning ? null : onPressed,
              icon: const Icon(Icons.camera),
              label: const Text("Scanner un Document"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isScanning)
              const CircularProgressIndicator()
            else if (_pictures.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Aucune image scannée",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ReorderableWrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  padding: const EdgeInsets.all(8),
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      final item = _pictures.removeAt(oldIndex);
                      _pictures.insert(newIndex, item);

                      // Met à jour l'ordre des éléments dans _selectedPictures
                      _selectedPictures.sort((a, b) {
                        // Trouve l'index de chaque élément dans _pictures et compare-les
                        int indexA = _pictures.indexOf(a);
                        int indexB = _pictures.indexOf(b);
                        return indexA.compareTo(indexB);
                      });
                    });
                  },
                  children: _pictures.map((imagePath) {
                    bool isSelected = _selectedPictures.contains(imagePath);
                    return GestureDetector(
                      key: ValueKey(imagePath),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedPictures.remove(imagePath);
                          } else {
                            _selectedPictures.add(imagePath);
                            _selectedPictures.sort((a, b) {
                              int indexA = _pictures.indexOf(a);
                              int indexB = _pictures.indexOf(b);
                              return indexA.compareTo(indexB);
                            });
                          }
                        });
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 16),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _selectedPictures.isNotEmpty
          ? FloatingActionButton(
        onPressed: () async {
          if (_selectedPictures.isNotEmpty) {
            Uint8List pdfBytes = await Utils.genererPDF(_selectedPictures);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFPreviewScreen(pdfBytes: pdfBytes),
              ),
            );
          }
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.picture_as_pdf),
        tooltip: 'Exporter',
      )
          : null,
    );
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permission caméra refusée"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> onPressed() async {
    await requestCameraPermission();

    setState(() {
      _isScanning = true;
    });

    try {
      List<String>? pictures = await CunningDocumentScanner.getPictures();
      if (pictures == null || pictures.isEmpty) {
        setState(() {
          _isScanning = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _pictures.addAll(pictures);
      });
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors du scan : $exception"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
      });
    }
  }
}
