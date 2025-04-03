import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Utils{
  static Future<Uint8List> genererPDF(List<String> selectedPictures) async {

    final pdf = pw.Document();

    for (String path in selectedPictures) {
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
    final pdfBytes = await pdf.save();
    return pdfBytes;
  }


  static Future<File> exportToPDF(Uint8List pdfBytes,String path, String name) async {
    // Utilisation d'un répertoire accessible
    final downloadsDirectory = Directory('/storage/emulated/0/Download/scans');
    String filePath;
    if (!await downloadsDirectory.exists()) {
      await downloadsDirectory.create(recursive: true);
    }
    if (path.isEmpty) {
      path = '${downloadsDirectory.path}';  // Utiliser name au lieu de filePath
    }

    if (name.isNotEmpty) {
      filePath = '$path/$name.pdf';  // Utiliser name au lieu de filePath
    } else {
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      filePath = '$path/document_scanne_$timestamp.pdf';
    }

    final pdfFile = File(filePath);

    await pdfFile.writeAsBytes(pdfBytes);
    return pdfFile;
  }


  static Future<bool> checkExistingFile(String filePath) async {
    File file = File(filePath);
    if (await file.exists()) {
     return true;
    }
    else{
      return false;
    }
  }
}