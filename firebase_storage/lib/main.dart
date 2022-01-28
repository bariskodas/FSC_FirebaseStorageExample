import 'package:firebase_auth_islemleri/pages/fsc_memes.dart';
import 'package:firebase_auth_islemleri/pages/login_page.dart';
import 'package:firebase_auth_islemleri/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Auth servisimizden mevcut kullanıcı bilgisini alalım ve bir değişkene aktaralım
  var isUserNull = auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      // tema ayarları
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white12,
            elevation: 0),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(width: 1)),
        ),
      ),
      title: 'Firebase Auth İşlemleri',
      // eğer mevcut kullanıcı null ise giriş sayfasına, değilse anasayfaya yönlendirelim.
      home: isUserNull == null ? LoginPage() : FSCMemes(),
    );
  }
}
