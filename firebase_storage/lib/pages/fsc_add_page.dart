import 'package:flutter/material.dart';
import 'package:firebase_auth_islemleri/services/auth_services.dart';
import 'package:firebase_auth_islemleri/services/firestore_services.dart';

class AddPage extends StatelessWidget {
   AddPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  // TextFieldlardan alacağımız verilere eşitleyeceğimiz değişkenler
  String? topicName;
  String? topicContent;
  // Başlığın oluşturulduğu tarih için DateTime nesnesi
  DateTime addedTime = DateTime.now();   
    return Scaffold(
      appBar: AppBar(title: Text("Başlık Ekle"),
      actions: [ Padding(
          padding: EdgeInsets.only(right: 10),
          // Gönder Butonu
          child: TextButton(child: Text("Gönder"), onPressed: () { 
            if (topicName !=null && topicContent != null) {
              firestore.collection("topics") // topics koleksiyonunu seç
            .add(         // şu map nesnesini ekle
              {"topic_name":topicName, 
              "topic_content":topicContent, 
              "author":auth.currentUser!.email,  // Auth servisinden aldığımız kullanıcı mail bilgisi
              "added_time":addedTime}
              ).then((value){
              print(value);
              Navigator.pop(context);
            });
            } else {
              print("hata oluştu");
            }
            
          })),
      ]),
      body: SingleChildScrollView(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), 
      child: Column(
        children: [
          TextField(decoration: InputDecoration(hintText: "Başlık"),
           onChanged: (name) {
              topicName = name;
            },
          ),
          SizedBox(height: 10),
          TextField(
            maxLines: 16,
            decoration: InputDecoration(hintText: "İçerik"),
            onChanged: (content) {
              topicContent = content;
            },
            ),
            
        ],
      ),)),
    );
  }
}