import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reorderables/reorderables.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'InfosScreen.dart';
import 'PDFPreviewScreen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'Utils.dart';

class ScannerScreen extends StatefulWidget {
  static Color color = Colors.green;

  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  List<String> _pictures = [];
  List<String> _selectedPictures = [];
  bool _isScanning = false;
  bool _isInAsyncCall = false;
  double bur = 0;
  DateTime? lastPressed; // Stocke le moment du dernier appui

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await loadSavedPictures();
    });
  }
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Empêche la fermeture automatique
      onPopInvoked: (didPop) {
        final now = DateTime.now();

        if (lastPressed == null || now.difference(lastPressed!) > Duration(seconds: 2)) {
          // Premier appui -> Affiche un message
          lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Appuyez à nouveau pour quitter"),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Deuxième appui rapide -> Quitte l'application
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de Documents'),
        centerTitle: true,
        backgroundColor: ScannerScreen.color,
        actions: [
            IconButton(
              icon: const Icon(Icons.info_outlined),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfosScreen(),
                  ),
                );
              },
              tooltip: "Infos",
            ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isInAsyncCall,
        // demo of some additional parameters
        opacity: 0.5,
        blur: bur,
        progressIndicator: const CircularProgressIndicator(),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _isScanning ? null : onPressed,
              icon: const Icon(Icons.camera),
              label: const Text("Scanner un Document"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ScannerScreen.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            _selectedPictures.isNotEmpty
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      if (_selectedPictures.isNotEmpty) {
                        Uint8List pdfBytes = await Utils.genererPDF(_selectedPictures);
                        setState(() {
                          _isInAsyncCall = true;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFPreviewScreen(pdfBytes: pdfBytes),
                          ),
                        );
                        setState(() {
                          _isInAsyncCall = false;
                        });
                      }
                    },
                    child: const Icon(Icons.picture_as_pdf)
                ),
                ElevatedButton(
                    onPressed:  confirmDeletion,
                    child: const Icon(Icons.delete)
                ),
              ],
            ): Row(),
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
                child: SingleChildScrollView(
                  child: ReorderableWrap(
                   spacing: 10.0,
                   runSpacing: 10.0,
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
              ),
          ],
        ),
      ),
      ),
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

    if (await Permission.manageExternalStorage.isDenied) {
      // Demander l'autorisation
      await Permission.manageExternalStorage.request();
    }
    if (await Permission.manageExternalStorage.isGranted) {
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
        await Utils.savePicturesLocally(pictures);
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


  Future<void> loadSavedPictures() async {

    if (await Permission.manageExternalStorage.isDenied) {
      // Demander l'autorisation
      await Permission.manageExternalStorage.request();
    }
    if (await Permission.manageExternalStorage.isGranted) {
      Directory savedDir = Directory(
          '/storage/emulated/0/Download/scans/scanned_docs');

      if (await savedDir.exists()) {
        final List<FileSystemEntity> files = savedDir.listSync();
        final List<String> paths = files
            .where((entity) => entity is File)
            .map((file) => file.path)
            .toList();

        setState(() {
          _pictures = paths;
        });
      }
    }
  }

  Future<void> deleteSelectedPicturesFromStorage() async {
    for (String path in _selectedPictures) {
      final file = File(path);

      // Vérifie que le fichier existe avant de le supprimer
      if (await file.exists()) {
        await file.delete();
      }

      // Retire aussi le chemin de la liste principale des images
      _pictures.remove(path);
    }

    setState(() {
      _selectedPictures.clear(); // Vide la sélection après suppression
    });
  }

  void confirmDeletion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmation"),
        content: Text("Voulez-vous vraiment supprimer ces images ?"),
        actions: [
          TextButton(
            child: Text("Annuler"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text("Supprimer"),
            onPressed: () async {
              Navigator.of(context).pop();
              await deleteSelectedPicturesFromStorage();
            },
          ),
        ],
      ),
    );
  }


}
