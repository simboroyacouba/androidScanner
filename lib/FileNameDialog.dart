import 'dart:io';

import 'package:flutter/material.dart';

import 'Utils.dart';

class FileNameDialog extends StatefulWidget {
  final Function(String fileName) onFileNameChosen; // Callback pour renvoyer le nom du fichier
  final String? selectedFolder;
  const FileNameDialog({
    super.key,
    required this.onFileNameChosen,
    required this.selectedFolder});

  @override
  _FileNameDialogState createState() => _FileNameDialogState();
}

class _FileNameDialogState extends State<FileNameDialog> {

  TextEditingController fileNameController = TextEditingController();
  bool isValid = false; // Variable pour valider si le champ est vide
  String messageErreur = "Le nom du fichier ne peut pas être vide";

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text("Nom du fichier"),
      content: TextField(
        controller: fileNameController,
        decoration: InputDecoration(
          hintText: "Nom du fichier",
          errorText: isValid ? null : messageErreur,
        ),
        onChanged: (text) async {
          String filePath = '${widget.selectedFolder}/${fileNameController.text}.pdf';

          bool fileExist = await Utils.checkExistingFile(filePath);

          setState(()  {
            isValid = text.isNotEmpty && !fileExist;
            if (fileExist) {
              messageErreur = "Un fichier avec le même nom existe déja !";
            }
            if(!isValid && !fileExist){
              messageErreur = "Le nom du fichier ne peut pas être vide";
            }
          });
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Annuler"),
        ),
        TextButton(
          onPressed: isValid
              ? () {
            // Vérifier si le nom du fichier est valide
            if (isValid) {
              widget.onFileNameChosen(fileNameController.text);
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          }
              : null,
          child: Text("OK"),
        ),
      ],
    );
  }
}