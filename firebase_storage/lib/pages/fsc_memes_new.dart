
import 'package:firebase_auth_islemleri/pages/fsc_memes.dart';
import 'package:firebase_auth_islemleri/services/auth_services.dart';
import 'package:firebase_auth_islemleri/services/firestore_services.dart';
import 'package:firebase_auth_islemleri/services/storage_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class NewMeme extends StatefulWidget {
  NewMeme({Key? key}) : super(key: key);

  @override
  _NewMemeState createState() => _NewMemeState();
}

class _NewMemeState extends State<NewMeme> {
  PickedFile? selectedPhoto; // Kullanıcıdan gelen fotoğraf
  String? postText; // gönderi metni

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yeni gönderi"), 
      ),
      body: Column(
          children: [ 
            // Resim seç butonu
            Container(
              height: 300,
              width: double.infinity,
              child: selectedPhoto == null // Eğer resim seçilmemişse
              ? IconButton(icon: Icon(Icons.camera_alt, size: 128), // Seçmek için buton göster 
              onPressed: () async{ // ImagePicker ile kullanıcıdan resim al
                var pickedPhoto = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
                setState(() { // seçilen fotoyu global değişkene ata ve sayfayı yenile
                  selectedPhoto = pickedPhoto; 
                });
              })
              : Container(child: Image.file(File(selectedPhoto!.path)),), // seçilen resmi göster
            ),
            // Kullanıcının metin yazacağı alan
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                maxLines: 4,
                decoration: InputDecoration(hintText: "Bir şeyler yazın..."),
                onChanged: (value) {
                  postText = value; // değişikliği yakala global değişkene ata
                },
              ),
            ),

            // Ekle Butonu
            TextButton(
            child: Text("Ekle", style: TextStyle(fontSize: 36),), 
            onPressed: () async{
              try {
                if (selectedPhoto != null && postText != null) { // Eğer foto ve metin boş değilse
                 // yüklenecek dosya için kurallı bir ad oluşturuyorum
                  DateTime now = DateTime.now();
  String fileName = "${auth.currentUser!.uid}${now.year}${now.month}${now.day}${now.hour}${now.second}${now.millisecondsSinceEpoch}";
              // Seçilen resim dosyasını storage'a yükle
              var uploadStorage = await storage.ref() // Storage kök dizinine git
              .child(auth.currentUser!.uid) // kullanıcı UID'siyle aynı isimde bir klasör aç
              .child(fileName) // seçien resim dosyasını koy
              .putFile(File(selectedPhoto!.path));
              // Dosya yüklenmesi bittikten sonra indirme linkini al
              var uploadedPhotoURL = await (await uploadStorage.ref.getDownloadURL()).toString();
               print(uploadedPhotoURL);
              // Daha sonra Firestore'a yazalım
               firestore.collection("memes").add({ 
               "author":auth.currentUser!.email, 
               "postText":postText,
               "added_time":now,
               "mediaURL":uploadedPhotoURL
               }).whenComplete((){ // İşlem tamamlanınca anasayfaya yönlendir
                 Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>FSCMemes()), (route) => false);
               });
              } else {
                print("dosya seçilmedi.");
              }
              } catch (e) {
                print(e.toString());
              }
              
            })
          ],
        ));
  }
}