import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
  
/// Firebase Auth servisine kolayca bağlanmak için bir değişkene atıyorum.
final FirebaseAuth auth = FirebaseAuth.instance;

class MyAuthService {

  /// E- mail ve şifre ile kayıt olma servisi dkckdcjwdokcjfejwf
  registerWithMail(
    {required String mail, required String password} // bu fonksiyona zorunlu 2 adet parametre tanımlıyoruz
    ) async {  // Firebase ile yapılan tüm işlemler asenkrondur.

    // bir problem oluştuğunda programımızın çalışmaya devam etmesi için try-catch yapısını kullanalım.
    try {
      // parametlerden gelen değişkenleri metodumuza atıyoruz. Eğer kayıt başarılı olursa bize UserCredential tipinde
      // bir kullanıcı kimliği dönecek, yani o anki kullanıcının kimliği ve bilgilerini tutan bir değişken.
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: mail, password: password);

      // Eğer await işlemin sonucu başarılı olursa, ekrana kullanıcının uid (kullanıcı bilgisi) yaz
      print("Kullanıcı kaydedildi. ${userCredential.user!.uid}");

    } on FirebaseAuthException catch (e) { // işlem başarısız olursa bize Firebase'den bir hata döner, bu hatayı e değişkenine atıyoruz
      if (e.code == 'weak-password') { // Firebase bize yaygın hata kodlarını String tipinde dönebilir, kontrol ediyoruz
        print('Girdiğiniz şifre zayıf');
      } else if (e.code == 'email-already-in-use') {
        print('Bu email zaten kullanılıyor.');
      }
    } catch (e) { // eğer yukarıdaki hatalardan farklı bir hata varsa
      print(e);
    }
  }

  /// E-mail ve şifre ile giriş yapma servisi
  Future<User?> signInWithMail( // Bu fonksiyonun sonunda Firebase bize <User> tipinde bir kullanıcı kimliği dönecek.
      {required String mail, required String password}) async { // zorunlu parametlerimiz
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: mail, password: password);
      print("Kullanıcı giriş yaptı. ${userCredential.user!.uid}"); // await sonucu başarılı olursa ekrana yazdıralım
      return userCredential.user; // ve userCredential kimliği içerisindeki user nesnesini döndürelim.
    } on FirebaseAuthException catch (e) { // Hata kontrollerimiz
      if (e.code == 'user-not-found') {
        print('Girdiğiniz bilgilerle eşleşen kullanıcı bulunamadı.');
      } else if (e.code == 'wrong-password') {
        print('Yanlış veya hatalı şifre.');
      }
    }
  }

/// E-mail ile parola sıfırlama servisi
passwordResetWithMail ({required String mail}) async {
    try {
    await auth.sendPasswordResetEmail(email: mail);
    print("Parola sıfırlama maili gönderildi");
    }catch (e) {
     print(e.toString());
    }
  }
 

  /// Google ile giriş servisi
  Future<UserCredential> signInWithGoogle() async {
    {// Öncelikle bir kullanıcı kimliği bilgisi edinmemiz lazım. 
    // Kullanıcı Google ile giriş butonuna bastığında ilk bu satır tetiklenir ve 
    // kullanıcıya bir pencere açarak erişim izni ister.
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Kullanıcı eğer izin verdiyse bilgilerini doğruluyoruz
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // ve yeni bir kimlik oluştulur. her kullanıcının kendisine ait acces ve idToken bilgileri vardır.
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Giriş yapılması sonrası kullanıcının durumlarını kontrol etmek için kimliğini döndürüyoruz.
    return await auth.signInWithCredential(credential);}
  }

  
  
}



