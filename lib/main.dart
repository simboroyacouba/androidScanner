
import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:reorderables/reorderables.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:flutter_sortable_wrap/flutter_sortable_wrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();  // Important pour charger les plugins
  FilePicker.platform.clearTemporaryFiles();  // Force l'initialisation
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
      home: const ScannerScreen(),
    );
  }
}

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
              onPressed: _selectedPictures.isNotEmpty ? exportToPDF : null,
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
                      final item = _selectedPictures.removeAt(oldIndex);
                      _selectedPictures.insert(newIndex, item);
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
        ?FloatingActionButton(
          onPressed:  _selectedPictures.isNotEmpty ? exportToPDF : null, // Lance la fonction de scan
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.picture_as_pdf),  // Icône de l'appareil photo
          tooltip: 'Exporter',  // Tooltip qui s'affiche en survolant
        )
        : null,
    );
  }

  // Fonction pour demander la permission de la caméra
  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permission caméra refusée"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }

  // Fonction pour demander la permission de stockage
  Future<void> requestStoragePermission() async {

    if (await Permission.manageExternalStorage.request().isGranted) {
      // Permission accordée, tu peux maintenant accéder aux fichiers
    } else {
      // Demander à l'utilisateur de l'activer dans les paramètres
      openAppSettings();
    }
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission d\'accès au stockage refusée')),
      );
      return;
    }
  }

  Future<void> onPressed() async {
    // Demande d'abord la permission de la caméra
    await requestCameraPermission();

    setState(() {
      _isScanning = true;
    });

    try {
      List<String> pictures = await CunningDocumentScanner.getPictures() ?? [];

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

  Future<void> exportToPDF() async {
    // Avant d'exporter, on demande la permission de stockage
    await requestStoragePermission();

    final pdf = pw.Document();

    // Ajoute des pages PDF ici...

    // Utilisation d'un répertoire accessible
    final downloadsDirectory = Directory('/storage/emulated/0/Download/scans');
    if (!await downloadsDirectory.exists()) {
      await downloadsDirectory.create(recursive: true);
    }

    for (String path in _selectedPictures) {
      final imageFile = File(path);
      if (await imageFile.exists()) {
        final imageBytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }
    }


    final filePath = '${downloadsDirectory.path}/document_scanne.pdf';
    final pdfFile = File(filePath);

    final pdfBytes = await pdf.save();
    await pdfFile.writeAsBytes(pdfBytes);

    print("PDF enregistré avec succès : $filePath");


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PDF généré avec succès")),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFPreviewScreen(pdfFile: pdfFile),
      ),
    );

    // Partage ou autres actions...
    Share.shareXFiles([XFile(pdfFile.path)], text: "Voici votre document PDF scanné !");
  }
}


class PDFPreviewScreen extends StatelessWidget {
  final File pdfFile;
  const PDFPreviewScreen({Key? key, required this.pdfFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aperçu du PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share.shareFiles([pdfFile.path], text: 'Voici votre document scanné');
              Share.shareXFiles([XFile(pdfFile.path)], text: "Voici votre document PDF scanné !");
            },
          ),
        ],
      ),
      body: PDFView(
        filePath: pdfFile.path,
      ),
    );
  }
}



//
//
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
//
// import 'cunning_document_scanner.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//       ),
//       home: const ScannerScreen(),
//     );
//   }
// }
//
// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }
//
// class _ScannerScreenState extends State<ScannerScreen> {
//   List<String> _pictures = [];
//   List<String> _selectedPictures = [];
//   bool _isScanning = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scanner de Documents'),
//         centerTitle: true,
//         backgroundColor: Colors.deepPurple,
//         actions: [
//           if (_pictures.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.picture_as_pdf),
//               onPressed: _selectedPictures.isNotEmpty ? exportToPDF : null,
//               tooltip: "Exporter en PDF",
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             ElevatedButton.icon(
//               onPressed: _isScanning ? null : onPressed,
//               icon: const Icon(Icons.camera),
//               label: const Text("Scanner un Document"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                 textStyle: const TextStyle(fontSize: 18),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (_isScanning)
//               const CircularProgressIndicator()
//             else if (_pictures.isEmpty)
//               const Expanded(
//                 child: Center(
//                   child: Text(
//                     "Aucune image scannée",
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                 ),
//               )
//             else
//               Expanded(
//                 child: ListView(
//                   children: _pictures.map((imagePath) {
//                     return Image.file(
//                       File(imagePath),
//                       fit: BoxFit.cover,
//                       height: 100,
//                     );
//                   }).toList(),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> onPressed() async {
//     var status = await Permission.camera.request();
//     if (status != PermissionStatus.granted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Permission caméra refusée"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       _isScanning = true;
//     });
//
//     try {
//       List<String> pictures = await CunningDocumentScanner.getPictures() ?? [];
//       setState(() {
//         _pictures.addAll(pictures);
//       });
//     } catch (exception) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Erreur lors du scan : $exception"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isScanning = false;
//       });
//     }
//   }
//
//   Future<void> exportToPDF() async {
//     final pdf = pw.Document();
//
//     for (String imagePath in _selectedPictures) {
//       final image = pw.MemoryImage(File(imagePath).readAsBytesSync());
//       pdf.addPage(pw.Page(build: (pw.Context context) {
//         return pw.Image(image); // Ajoute l'image scannée à chaque page
//       }));
//     }
//
//     final directory = await getTemporaryDirectory();
//     final pdfFile = File('${directory.path}/document_scanné.pdf');
//     await pdfFile.writeAsBytes(await pdf.save());
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PDFPreviewScreen(pdfFile: pdfFile),
//       ),
//     );
//   }
// }
//
// class PDFPreviewScreen extends StatelessWidget {
//   final File pdfFile;
//   const PDFPreviewScreen({Key? key, required this.pdfFile}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Aperçu du PDF'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () {
//               // Share.shareFiles([pdfFile.path], text: 'Voici votre document scanné');
//               Share.shareXFiles([XFile(pdfFile.path)], text: "Voici votre document PDF scanné !");
//             },
//           ),
//         ],
//       ),
//       body: PDFView(
//         filePath: pdfFile.path,
//       ),
//     );
//   }
// }
