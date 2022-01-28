import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';


// Bağlantı kuralım
FirebaseStorage storage = FirebaseStorage.instance;


/// Referans yapısı
// storage'ın kök dizinindeki bir dosyaya doğrudan referans verelim. (Storage/read_me.text)
Reference ref = storage.ref("read_me.txt"); 

// Storage içindeki bir klasör içindeki dosyaya referans verelim. (Storage/images/profilePhoto.png)
Reference fileReference = storage.ref() // Storage'ın kök dizininin referansına git
                                 .child("images") // images klasörünü seç
                                 .child("profilePhoto.png"); // images klasöründeki profilePhoto.png 'yi seç.


class StorageServices {
  /// Listeleme işlemleri

  // Veritabanındaki belirli bir dizinin içindeki tüm dosyaları listeleme
  Future<void> listExample() async {
  // Listeleme sonuçları bize ListResult tipinde döner.  
  ListResult result = await storage.ref().listAll(); // Kök dizindeki tüm dosyaları listele
  ListResult usersResult = await storage.ref().child("users").listAll(); // Kök dizin/users klasörünün tüm dosyalarını listele
  
  // ListResult tipindeki verinin içinde Reference tipinde dosya referansları vardır, forEach ile dönelim
  result.items.forEach((Reference ref) {
    print('Found file: $ref'); 
  });

// dosyanın dizinini yazdır
  result.prefixes.forEach((Reference ref) {
    print('Found directory: $ref');
  });
}

/// Belirli sayıda dosyayı listele gibi opsiyonlar ekleyebiliriz.
// NOT: Bu yöntem genelde Pagination için tercih edilir.
Future<void> listExampleWithLimit() async {
  ListResult result = await storage.ref() // kök dizine git 
                                   .list(ListOptions(maxResults: 10)); // 10 dosyalık liste hazırla
}


/// Dosya yükleme işlemleri

// Örnek upload fonksiyonu
Future<void> uploadFile(String filePath) async {
  File file = File(filePath); // yüklenecek dosya

  try {
    await storage.ref('uploads/file-to-upload.png') // dosyanın yükleneceği dizin
                 .putFile(file);  // dosyayı yükle-yerine koy 
  } on FirebaseException catch (e) { // hata çıkarsa yakala
    print(e.toString()); 
  }
}
  
/// Dosya indirme işlemleri

// Örnek download fonksiyonu
Future<void> downloadFileExample() async {
  // bir dosya ve dizin referansını oluşturalım
  Directory appDocDir = await getApplicationDocumentsDirectory();
  File downloadToFile = File('${appDocDir.path}/download-logo.png');

  try {
    await storage.ref('uploads/logo.png') // Storage'da bulunan dosyaya git
                 .writeToFile(downloadToFile); // benim oluşturduğum yerel dosyaya yaz
  } on FirebaseException catch (e) {
    print(e.toString());
  }
}

/// Silme işlemi

// Örnek fonksiyon
Future<void> deleteFile() async{
try {
  // kök dizinden bir dosya silelim. (Storage/bariskodas.png)
  await storage.ref("bariskodas.png").delete();
  // users klasöründen bir dosya silelim. (Storage/users/bariskodas.png)
  await storage.ref().child("users").child("bariskodas.png").delete();
} on FirebaseException catch (e) {
  print(e.toString());
}}


/// Dosya yüklerken duraklatma, devam etme ve iptal işlemleri (Pause, resume, cancel)

Future<void> handleTaskExample3(String filePath) async {
  File largeFile = File(filePath); 

// Bu işlemler için bir UploadTask nesnesi tanımlarız
  UploadTask task = storage.ref('uploads/hello-world.txt')
                           .putFile(largeFile);

  // Yüklemeyi duraklat.
  bool paused = await task.pause();
  print('paused, $paused');

  // Yüklemeyi devam ettir.
  bool resumed = await task.resume();
  print('resumed, $resumed');

  // Yüklemeyi iptal et.
  bool canceled = await task.cancel();
  print('canceled, $canceled');
}
}