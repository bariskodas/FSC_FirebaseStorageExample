import 'package:firebase_auth_islemleri/services/auth_services.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
// textfielddan alacağım verilerle eşitleyeceğim email ve password değişkenleri
    String? email;
    String? password;
    return Scaffold(
      appBar: AppBar(
        title: Text("Kaydol", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white12,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding( padding: EdgeInsets.all(16),
        child: Column(
          children: [
        // kaydol ikonu
        Icon(Icons.person_add, color: Colors.blue, size: 150),

        // e-mail textfield
        TextFormField(
          decoration: InputDecoration(
            hintText: "e-mail adresi",
            prefixIcon: Icon(Icons.mail_outline)),
          onChanged: (mail) {
            email = mail;
          }),

        // parola textfield
        SizedBox(height: 10),
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: "parola",
            prefixIcon: Icon(Icons.lock),
          ),
          onChanged: (parola) {
            password = parola;
          },
        ),
        // kaydol butonu
        SizedBox(height: 10),
        Container( width: double.infinity,
          child: RawMaterialButton(
              child: Text("Kaydol",style: TextStyle(color: Colors.white, fontSize: 18)),
              fillColor: Colors.blue,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onPressed: (){
                // TextFielddan gelen bilgilerin null durumunu kontrol ediyorum.
                // eğer null değer gelmemişse metodumu tetikliyorum
                if (email != null && password != null) {
                MyAuthService().registerWithMail(mail: email!, password: password!);
                } else {
                  print("Bir hata oluştu. email: $email password: $password");
                }
              },),
        ),
          ],
        ),
      ),
    );
  }
}
