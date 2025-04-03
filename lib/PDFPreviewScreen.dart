
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';

import 'Utils.dart';

class PDFPreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  const PDFPreviewScreen({Key? key, required this.pdfBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aperçu du PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              File pdfFile =  await Utils.exportToPDF(pdfBytes, '', '');
              Share.shareXFiles([XFile(pdfFile.path)], text: "Votre document PDF !");
            },
          ),
        ],
      ),
      body: SfPdfViewer.memory(pdfBytes),
      floatingActionButton: pdfBytes != null
          ?FloatingActionButton(
        // onPressed:  pdfBytes.isNotEmpty ? exportToPDF(pdfBytes) : null, // Lance la fonction de scan
        onPressed: null,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.picture_as_pdf),
        tooltip: 'Exporter',  // Tooltip qui s'affiche en survolant
      )
          : null,
    );
  }
}