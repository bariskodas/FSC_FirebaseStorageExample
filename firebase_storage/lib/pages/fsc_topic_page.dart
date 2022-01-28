import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_islemleri/pages/fsc_home.dart';
import 'package:firebase_auth_islemleri/services/auth_services.dart';
import 'package:firebase_auth_islemleri/services/firestore_services.dart';
import 'package:flutter/material.dart';

class TopicPage extends StatefulWidget {
  String documentID;
  String documentName;
  String documentContent;
  String documentAuthor;
  DateTime documentAddedTime;
  TopicPage(
      {required this.documentID,
      required this.documentName,
      required this.documentContent,
      required this.documentAddedTime,
      required this.documentAuthor,
      Key? key})
      : super(key: key);

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentName), // Konu başlığı
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column( verticalDirection: VerticalDirection.down,
            children: [
              Column( crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.documentContent, style: TextStyle(color: Colors.black87)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.documentAuthor, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                      Row(children: [
                          Text("${widget.documentAddedTime.hour}:${widget.documentAddedTime.minute} ${widget.documentAddedTime.day}/${widget.documentAddedTime.month}/${widget.documentAddedTime.year}"),
                          IconButton(icon: Icon(Icons.edit), // Düzenle butonu
                              onPressed: () { // Konuyu oluşturan kullanıcı ve mevcut kullanıcı aynı kişi mi? kontrol ediyorum
                                if (widget.documentAuthor == auth.currentUser!.email) { 
                                  TextEditingController textEditingController = TextEditingController(); // TextField controller
                                  // Kolaylık oluşturması için textfielda konu içeriğini aktarıyorum
                                  textEditingController.text = widget.documentContent; 
                                  showModalBottomSheet(context: context,
                                      builder: (context) => Container(
                                            child: Column(
                                              children: [
                                                TextField(maxLines: 8,
                                                  controller: textEditingController, // oluşturduğumuz controllerı atadık
                                                ),
                                                TextButton(child: Text("Güncelle"), // Güncelle butonu
                                                    onPressed: () {
                                                      firestore.collection("topics") //topics koleksiyonuna git
                                                          .doc(widget.documentID) // dokümana git
                                                          .update({ // "topic_content" alanını TextFielddaki yazıyla güncelle
                                                        "topic_content": textEditingController.text
                                                      }).then((value) { // sonrasında ekranı yeniden çiz
                                                        setState(() { // ve mevcut içeriği yeni içerikle değiştir
                                                          widget.documentContent = textEditingController.text;
                                                          Navigator.pop(context); // BottomSheeti kapat
                                                        }); }); }),],),));
                              } else { showDialog( // eğer mevcut kullanıcı ve konuyu oluşturan kullanıcı eşleşmediyse
                                      context: context, builder: (_) => SimpleDialog(
                                            children: [
                                              Text("Bunun için yetkiniz yok."),
                                              TextButton(child: Text("Geri"), onPressed: () {Navigator.pop(context);},)],));}
                              }),
                          IconButton(icon: Icon(Icons.delete), // Sil Butonu
                              onPressed: () {
                                if (widget.documentAuthor == auth.currentUser!.email) { // Konuyu oluşturan kullanıcı ve mevcut kullanıcı aynı kişi mi? kontrol ediyorum
                                  firestore.collection("topics") // topics koleksiyonuna git
                                      .doc(widget.documentID) // dokümana git
                                      .delete();  // sil
                                      Navigator.pushAndRemoveUntil(context,  // Anasayfaya yönlendir
                                      MaterialPageRoute(builder: (_) => FSCHome()), (route) => false);
                              } else { // eğer mevcut kullanıcı ve konuyu oluşturan kullanıcı eşleşmediyse
                                  showDialog(context: context,
                                      builder: (_) => SimpleDialog(
                                            children: [
                                              Text("Bunun için yetkiniz yok."),
                                              TextButton(child: Text("Geri"),
                                                onPressed: () { Navigator.pop(context); },)
                                            ],
                                          ));}})
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Expanded( // YANITLAR
                child: StreamBuilder(
                  // Dinlenecek kaynak
                    stream: firestore.collection(
                      "topics/${widget.documentID}/replies" // her dokümanın kendi replies koleksiyonu
                      ).snapshots(),
                    builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> asyncSnapshot) { // verileri gez ve lokal değişkene al
                      try { 
                        if (asyncSnapshot.hasError) { // Hata Kontrolü
                          return Text("Bir şeyler ters gitti");
                        } else if (asyncSnapshot.connectionState == ConnectionState.waiting) { // Akış kontrolü
                          Center(child: CircularProgressIndicator());
                        }
                        final replies = asyncSnapshot.requireData; // Verileri ayıkla ve replies değişkenine al
                        return ListView.builder(
                            itemCount: replies.size, // replies koleksiyonunun uzunluğu kadar item üret
                            itemBuilder: (context, index) {
                              return Column( crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(thickness: 1), 
                                  Text(replies.docs[index]["reply"], style: TextStyle(color: Colors.black87)), // yanıtı yaz
                                  Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(replies.docs[index]["email"], style: TextStyle( // Yanıt sahibini yaz
                                              color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                                      Row(children: [
                                          Text("09:41 12/01/2022"), // Yanıt saat ve tarihi - şimdilik statik tanımlıyorum.
                                          IconButton(icon: Icon(Icons.edit), onPressed: () {}), // Yanıt düzenleme butonu
                                          IconButton(icon: Icon(Icons.delete), onPressed: () {}) // Yanıt silme butonu
                                        ],),],),
                                ],
                              );
                            });
                      } catch (e) {
                        return Text(e.toString());
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
