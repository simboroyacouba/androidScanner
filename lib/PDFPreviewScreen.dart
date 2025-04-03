import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import 'FileNameDialog.dart';
import 'Utils.dart';

class PDFPreviewScreen extends StatefulWidget {
  final Uint8List pdfBytes;
  const PDFPreviewScreen({Key? key, required this.pdfBytes}) : super(key: key);

  @override
  _PDFPreviewScreenState createState() => _PDFPreviewScreenState();
}

class _PDFPreviewScreenState extends State<PDFPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aperçu du PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              File pdfFile = await Utils.exportToPDF(widget.pdfBytes, '', '');
              Share.shareXFiles([XFile(pdfFile.path)], text: "Votre document PDF !");
            },
          ),
        ],
      ),
      body: SfPdfViewer.memory(widget.pdfBytes),
      floatingActionButton: widget.pdfBytes.isNotEmpty
          ? FloatingActionButton(
        onPressed: () async {
          if (await Permission.manageExternalStorage.isDenied) {
            // Demander l'autorisation
            await Permission.manageExternalStorage.request();
          }
          if (await Permission.manageExternalStorage.isGranted) {
            String? directoryPath = await FilePicker.platform.getDirectoryPath();

            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return FileNameDialog(
                    onFileNameChosen: (fileName) async {
                      Utils.exportToPDF(widget.pdfBytes, directoryPath!, fileName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("PDF généré avec succès dans : $directoryPath"),
                            backgroundColor: Colors.green,  // Set background color to green
                            duration: const Duration(seconds: 5),
                        ),
                      );
                    }, selectedFolder: directoryPath,
                );
              }
            );

          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Permission refusée")),
            );
            print("Permission d'accès au stockage refusée");
          }
        },
        backgroundColor: Colors.tealAccent,
        child: const Icon(Icons.get_app),
        tooltip: 'Exporter',  // Tooltip qui s'affiche en survolant
      )
          : null,
    );
  }
}
