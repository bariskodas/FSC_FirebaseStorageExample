import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_islemleri/pages/fsc_home.dart';
import 'package:firebase_auth_islemleri/pages/login_page.dart';
import 'package:firebase_auth_islemleri/services/auth_services.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // textfielddan alacağımız telefon numarası ve sms kod bilgisi
  String? phoneNumber;
  late String smsCode;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.white12,
        elevation: 0,
        centerTitle: true),
      body: SingleChildScrollView(
        child: Center(
          child: Padding( padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Kullanıcı iconu veya fotoğrafı
                Icon(Icons.person_pin, color: Colors.blue,size: 180),
      
                // Firebase'deki kayıtlı maili
                Text(auth.currentUser!.email!, style: TextStyle(color: Colors.blue, fontSize: 18),
                ),
                // Telefon numaram: doğrulama alanı
                SizedBox(height: 70),
                Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Telefon icon
                    Icon(Icons.phone, color: Colors.blue, size: 36),
                    // Kullanıcıdan numarasını alacağımız TextField. Boyutlandırmak için SizedBox ile sarmaladım.
                    SizedBox(width: 150, height: 60,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          decoration: InputDecoration(hintText: "numaranız"),
                          onChanged: (number) {
                            phoneNumber = number;
                          },
                        )),
                     // Doğrula butonumuz   
                    ElevatedButton( child: Text("Doğrula"),
                        onPressed: () async {
                          await auth.verifyPhoneNumber( // Servisi tetikliyoruz
                            timeout: Duration(seconds: 120), // Doğrulama süresi tanımlıyoruz
                            phoneNumber: '+90$phoneNumber', // Textfielddan aldığımız telefon numarasını başına ülke kodu ekleyerek veriyoruz
                            
                            // Doğrulama tamamlandığında bu kod bloğu çalışacak.
                            verificationCompleted: (PhoneAuthCredential credential) async { 
                              await auth.currentUser!.updatePhoneNumber(credential) // mevcut kullanıcının telefon numarasını doğruladığımız numarayla güncelliyoruz.
                              .then((value) { // güncelleme tamamlandıktan sonra ekranda bir doğrulama mesajı gösterelim.
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Telefon numarası doğrulandı."), duration: Duration(seconds: 5),));
                              });
                            },
      
                            // Doğrulama sırasında hata oluşursa debug console'a yazdıralım.
                            verificationFailed: (FirebaseAuthException e) {
                              print('Telefon doğrulanırken hata oluştu. $e');
                            },
      
                            // Eğer numara web üzerinden doğrulanamazsa mesajla kod gönderilecek ve bu blok tetiklenecek.
                            codeSent: (String verificationId, int? resendToken) async {
                              showModalBottomSheet( context: context, // Blok tetiklendiğinde kullanıcıdan sms kodunu almak için ekranda bir ModalBottomSheet çıkaralım
                                  builder: (context) => Container(
                                        child: Column(
                                          children: [
                                            Icon(Icons.sms_outlined, size: 140, color: Colors.blue), 
                                            SizedBox(width: 150,height: 60,
                                                child: TextField( // bir textfield tanımlayalım
                                                  keyboardType:TextInputType.number,
                                                  decoration: InputDecoration(
                                                    hintText: "Doğrulama kodu"),
                                                  onChanged: (number) { // textfielddaki değişiklikleri yakalayıp sayfanın yukarısında tanımladığımız smsCode değişkenine aktaralım
                                                    smsCode = number; 
                                                    })),
                                            ElevatedButton( child: Text("Kodu Doğrula"), // Kullanıcı kodu girdikten sonra bu butona basacak ve fonksiyonumuz tetiklenecek.
                                              onPressed: () async {
                                              // PhoneAuthProvider.credential() komutu ile bir telefon kimlik doğrulama nesnesi <PhoneAuthCredential> oluşturup bizden istediği parametleri 
                                              // verip credential değişkenine aktarıyoruz. NOT: bizim için önemli olan smsCode parametresi.
                                              PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId:verificationId, smsCode: smsCode);
                                                await auth.currentUser!.updatePhoneNumber(credential)
                                                    .then((value) => print("telefon güncellendi"));
                                              })])));},
                                              
                            // Doğrulama süresi dolduğunda bu blok tetiklecek
                            codeAutoRetrievalTimeout:(String verificationId) {
                              print("Kod doğrulama süresi doldu.");
                            },);}),
                  ],
                ),
                
                SizedBox(height: 20),
                // Çıkış yap butonumuz
                TextButton( child: Text("Çıkış yap", style: TextStyle(color: Colors.red, fontSize: 24)),
                    onPressed: () async {
                      await auth.signOut() // çıkış yapmak için yapmamız gereken tek şey auth servisimizin signOut() metodunu çağırmak.
                      .then((value) {  // daha sonrasında ise giriş sayfamıza yönlendiriyoruz.
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
                      });
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
