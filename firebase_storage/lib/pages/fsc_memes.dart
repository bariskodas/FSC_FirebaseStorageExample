import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_islemleri/pages/fsc_memes_new.dart';
import 'package:firebase_auth_islemleri/services/auth_services.dart';
import 'package:firebase_auth_islemleri/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class FSCMemes extends StatefulWidget {
  FSCMemes({Key? key}) : super(key: key);

  @override
  _FSCMemesState createState() => _FSCMemesState();
}

class _FSCMemesState extends State<FSCMemes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FSC Memes", style: TextStyle(color: Colors.lightBlue)),
      // Çıkış yap butonumuz
      leading: IconButton(icon: Icon(Icons.logout, color: Colors.red), onPressed: () {
        auth.signOut().whenComplete((){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>LoginPage()), (route) => false);
        });
      }),
      actions: [  // Yeni gönderi ekle sayfasına yönlendir
        IconButton(icon: Icon(Icons.add), onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>NewMeme()));
      },)],
      ),
      body: SafeArea(child: StreamBuilder(
              stream: firestore.collection("memes").snapshots(), // Dinlenip bize akıtılacak veri kaynağı memes koleksiyonu
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) { 
                try { if (asyncSnapshot.hasError) { // hata kontrolü
                    return Text("Bir şeyler ters gitti");
                  } else if (asyncSnapshot.connectionState == ConnectionState.waiting) { // veri akışı kontrolü
                   return Center(child: CircularProgressIndicator()); 
                  }
                  final post = asyncSnapshot.requireData; // gelen paketin içindeki datayı bir değişkene aktaralım
                  
                  // Listview ile ekrana yazdıralım.
                  return ListView.builder(
                      itemCount: post.size, // gelen verinin uzunluğunu verelim
                      itemBuilder: (context, index) {
                        // Firestoredan gelen tarih verisini bir değişkene alalım
                        DateTime addedTime = post.docs[index]["added_time"].toDate(); 
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey), 
                              borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.all(4),
                            child: Column( 
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Container(
                              height: 300,
                              width: double.infinity,
                              child: Image.network(post.docs[index]["mediaURL"])), // Resmi görüntüle
                            Text(post.docs[index]["postText"].toString()), // Gönderi metni
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [ // Gönderi sahibi ve tarihi
                              Text(post.docs[index]["author"], style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("${addedTime.hour}:${addedTime.second}, ${addedTime.day}/${addedTime.month}/${addedTime.year}")
                            ],),
                          ],)),
                        );
                      });
                } catch (e) {
                  return Text(e.toString());
                }
              })),
      );
  }
}


