import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';



class InfosScreen extends StatefulWidget {

  @override
  _InfosScreenState createState() => _InfosScreenState();
}

class _InfosScreenState extends State<InfosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("À propos"),
          actions: [
            IconButton(
              icon: Icon(Icons.share),
              tooltip: 'Partager',
              onPressed: () {
                Share.share(
                  '📲 Découvrez l\'application CamScan pour scanner vos documents facilement !\n\nTéléchargez-la maintenant !'
                      + "\nhttps://play.google.com/store/apps/details?id=com.cti.scanner",
                );
              },
            ),
          ],
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CamScan v1.0.0",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("🔒 Guide d’utilisation",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                "Cette application permet de scanner des documents rapidement à l'aide de la caméra de votre smartphone ou de votre galerie.",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "Cette application ne collecte, ne stocke et ne partage aucune donnée personnelle. "
                    "Aucune information n'est envoyée à des serveurs externes.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                "🟢 1. Lancer le scan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "• Ouvrez l'application.",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "• Autorisez l’accès au stockage de l’appareil pour permettre à l’application d’enregistrer et de lire les fichiers scannés.",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "• Appuyez sur le bouton \"Scanner un document\".",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "• Acceptez la permission d’accès à la caméra (lors de la première utilisation).",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "• Prenez des photos des documents à scanner ou importez-les depuis la galerie.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                "🖼️ 2. Gestion des documents scannés",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "• Tous les documents scannés sont affichés dans la page principale.",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "• Chaque vignette représente une image scannée.",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "• Touchez une image pour la sélectionner, ou maintenez pour activer le mode réorganisation par glisser-déposer.",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "• Apres sélection eet réorganisation vous pouvez exporter en PDF en cliquant sur l'icone en haut a droite.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                "🗑️ 3. Supprimer des documents",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "• Sélectionnez les documents que vous souhaitez supprimer.",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "• Appuyez sur l’icône 🗑️ située en haut à droite.",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "• Confirmez la suppression via la boîte de dialogue.",
                style: TextStyle(fontSize: 16),
              ),

            ],
          ),
        )
      ),
    );
  }
}
