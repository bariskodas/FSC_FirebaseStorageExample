import 'package:firebase_auth_islemleri/pages/fsc_home.dart';
import 'package:firebase_auth_islemleri/pages/fsc_memes.dart';
import 'package:firebase_auth_islemleri/pages/home_page.dart';
import 'package:firebase_auth_islemleri/pages/register_page.dart';
import 'package:firebase_auth_islemleri/services/auth_services.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  String googleLogoPngUrl =
      "https://img1.pngindir.com/20180324/ziw/kisspng-google-logo-g-suite-google-5ab6f1f0b9e059.9680510615219389287614.jpg";

  @override
  Widget build(BuildContext context) {
    // TextFielddan alacağımız mail ve password bilgileri
    String? email;
    String? password;
    String? emailReset;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Uygulama İkonu
                FlutterLogo(
                  size: 200,
                  style: FlutterLogoStyle.stacked,
                  textColor: Colors.blue,
                ),

                // E-mail, şifre TexFieldlar
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: "e-mail adresi",
                    prefixIcon: Icon(Icons.mail_outline),
                  ),       
                  onChanged: (value) { // TextFieldda olan değişiklikleri yakalayıp 
                    email = value;    // global bir değişkene aktaralım.
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "parola",
                    prefixIcon: Icon(Icons.lock),
                  ),
                  onChanged: (parola) {
                    password = parola;
                  },
                ),
                SizedBox(height: 10),
                /// Giriş Butonu
                Container( // Raw butonumuzun tüm alana yayılması için bir Container parent veriyoruz.
                  width: double.infinity, 
                  child: RawMaterialButton(
                    child: Text("Giriş", style: TextStyle(color: Colors.white, fontSize: 18)),
                    fillColor: Colors.blue,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onPressed: () {
                      // textfielddan gelen verilerin kontrolü
                      if (email != null && password != null) {
                        MyAuthService()
                            .signInWithMail(mail: email!, password: password!) // metodumuzu tetikleyelim
                            .then((user) {  // işlem tamamlandıktan sonraki verileri user değişkenine atayalım
                          try {
                            print(user!.uid.toString()); //kullanıcı bilgisini debug console'a yazdıralım
                            Navigator.pushAndRemoveUntil( // ve kullanıcıyı anasayfaya yönlendirelim
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FSCMemes()),
                                (route) => false);
                          } catch (e) { // firebase hata kontrolü ve yakalama
                            print(e); 
                          }
                        });
                      } else { // kullanıcıdan gelen verilerin hata kontrolü 
                        print("email: $email password: $password");
                      }
                    },
                  ),
                ),
                // Veya widget
                SizedBox(height: 10),
                Row( 
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(height: 1, width: 100, color: Colors.grey),
                    Text("veya", style: TextStyle(color: Colors.grey, fontSize: 24)),
                    Container(height: 1, width: 100, color: Colors.grey),
                  ],
                ),
                // Google ile giriş yap butonu
                SizedBox(height: 20),
                Container( width: double.infinity,
                  child: RawMaterialButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container( height: 30, width: 30,
                            child: Image.network(googleLogoPngUrl)),
                          SizedBox(width: 20),
                          Text("Google ile giriş", style: TextStyle(fontSize: 18))]),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(width: 1)),
                      onPressed: () {
                        MyAuthService().signInWithGoogle() // servisimizi çağırdık
                        .then((value){ 
                        if(value != null){ // işlem sonrası null değer yok ise anasayfaya yönlendirdik.
                          Navigator.pushAndRemoveUntil(context, // 
                         MaterialPageRoute(builder: (_)=> HomePage()), (route) => false);}
                         });
                      })),
                       SizedBox(height: 10),
                // Şifremi unuttum butonu
                TextButton(
                  child: Text("Şifremi Unuttum", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () { 
                  showModalBottomSheet(context: context, 
                  builder: (context) => Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextField(
                                    decoration: InputDecoration(
                                        hintText: "e-mail adresi"),
                                    onChanged: (mail) {
                                      emailReset = mail;
                                    })),
                                ElevatedButton(
                                    child: Text("Sıfırla"),
                                    onPressed: () {
                                      if (emailReset != null) {
                                        MyAuthService().passwordResetWithMail(
                                            mail: emailReset!);
                                      } else {
                                        print("email: $emailReset");
                                      }
                                    }),
                              ],
                            ));}),
/// Hesabın yok mu? Kaydol butonu
                Row( mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Hesabın yok mu?", style: TextStyle(fontSize: 18)),
                    TextButton( 
                      child: Text("Kaydol", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()));
                        },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
