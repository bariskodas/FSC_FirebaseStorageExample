import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_islemleri/pages/fsc_topic_page.dart';
import 'package:firebase_auth_islemleri/pages/login_page.dart';
import 'package:firebase_auth_islemleri/services/auth_services.dart';
import '../services/firestore_services.dart';
import 'fsc_add_page.dart';
import 'package:flutter/material.dart';

class FSCHome extends StatefulWidget {
  const FSCHome({Key? key}) : super(key: key);

  @override
  _FSCHomeState createState() => _FSCHomeState();
}

class _FSCHomeState extends State<FSCHome> {
Stream<QuerySnapshot> topicsSnapshot = firestore.collection("topics").snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: TextButton(child: Text("Çıkış", style: TextStyle(color: Colors.red)), // Çıkış butonu
        onPressed: () { auth.signOut().whenComplete((){ // Kullanıcıya çıkış yaptır ve Giriş sayfasına yönlendir.
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=> LoginPage()), (route) => false); }); }),
        title: Text("FSC Sözlük", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.add, color: Colors.blue), // Konu Ekle butonu
              onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AddPage())); }),
          /// SIRALA - FİLTRELE Butonu    
          IconButton(icon: Icon(Icons.sort,color: Colors.blue), onPressed: (){ 
                showDialog(context: context, builder: (context)=>SimpleDialog(
                  children: [
                    TextButton(child: Text("Varsayılan"), onPressed: () {
                      setState(() {
                      topicsSnapshot = firestore.collection("topics").snapshots();
                      });
                      Navigator.pop(context);
                    }),
                    TextButton(child: Text("Zamana göre - Eskiden yeniye"), onPressed: () {
                      setState(() {
                       topicsSnapshot = firestore.collection("topics").orderBy("added_time").snapshots();
                      });
                      Navigator.pop(context);
                    }),
                    TextButton(child: Text("Zamana göre - Yeniden eskiye"), onPressed: () {
                      setState(() { // descending: azalan
                       topicsSnapshot = firestore.collection("topics").orderBy("added_time", descending: true).snapshots();
                      });
                      Navigator.pop(context);
                    }),
                  ]
                ));
              }),
        ],
      ),
      body: SafeArea(
          child: StreamBuilder(
              stream: topicsSnapshot, // Dinlenip bize akıtılacak veri kaynağı ## topics koleksiyonu
          /// Dinlenen verileri çekip daha sonra lokal bir değişkene almalıyız, ki kullanabilelim. bunun için builder parametresine
          /// bir fonksiyon tanımlıyoruz. builder'a tanımladığımız fonksiyon topics koleksiyonunu gezip içindeki verileri asyncSnapshot'a aktaracak.
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) { 
                try { if (asyncSnapshot.hasError) { // hata kontrolü
                    return Text("Bir şeyler ters gitti");
                  } else if (asyncSnapshot.connectionState == ConnectionState.waiting) { // veri akışı kontrolü
                   return Center(child: CircularProgressIndicator()); 
                  }
                  final topic = asyncSnapshot.requireData; // gelen paketin içindeki datayı bir değişkene aktaralım
                  // Listview ile ekrana yazdıralım.
                  return ListView.builder(
                      itemCount: topic.size, // gelen verinin uzunluğunu verelim
                      itemBuilder: (context, index) {
                        return ListTile(
                          textColor: Colors.blue,
                          iconColor: Colors.blue,
                          title: Text(topic.docs[index]["topic_name"]), //topic'in içindeki o anki dokümanın "topic_name" alanını yazdıralım.
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push( context, MaterialPageRoute(
                                    builder: (context) => TopicPage( // Konu sayfasına yönlendirme
                                    // TopicPage da tanımladığımız zorunlu parametleri verelim
                                        documentID: topic.docs[index].id, 
                                        documentName: topic.docs[index]["topic_name"], 
                                        documentContent: topic.docs[index]["topic_content"], 
                                        documentAddedTime: (topic.docs[index]["added_time"].toDate()), // gelen zaman verisini döbüştürelim
                                        documentAuthor: topic.docs[index]["author"],
                                        )));
                          },
                        );
                      });
                } catch (e) {
                  return Text(e.toString());
                }
              })),
    );
  }
}
