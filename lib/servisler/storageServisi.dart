// @dart=2.9

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServisi {
  Reference _storage = FirebaseStorage.instanceFor().ref();
  String resimId;

  Future<String> gonderiResmiYukle(File resimDosyasi) async {
    //aşağıdaki Uuid() benzersiz birisim oluştırırı
    //bu sayede resimler aynı isimle kayıt edilmez
    resimId = Uuid().v4();
    //çekilen veya seçilen resim dosyası buraya parametre olarak gelecek
    UploadTask uploadTask = _storage
        .child("resimler/gonderiler/gonderi_$resimId.jpg")
        .putFile(resimDosyasi);
    TaskSnapshot snapshot = await uploadTask;
    String yuklenenResimurl = await snapshot.ref.getDownloadURL();
    return yuklenenResimurl;
  }

  Future<String> profilResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4();

    UploadTask uploadTask = _storage
        .child("resimler/profil/profil_$resimId.jpg")
        .putFile(resimDosyasi);
    TaskSnapshot snapshot = await uploadTask;
    String yuklenenResimurl = await snapshot.ref.getDownloadURL();
    return yuklenenResimurl;
  }

  void gonderiResmiSil(String gonderiResmiUrl) {
    //regExp arama kuralını kazanım çağırmak için de kullaniliriz
    RegExp arama = RegExp(r'gonderi_.+\.jpg');
    var eslesme = arama.firstMatch(gonderiResmiUrl);
    String dosyaAdi = eslesme[0];
    if (dosyaAdi != null) {
      _storage.child('resimler/gonderiler/$dosyaAdi').delete();
    }
  }
}
