import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:google_sign_in/google_sign_in.dart';

class YetkilendirmeServisi {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late String aktifKulaniciId;

  Kullanici _kullaniciOlustur(User kullanici) {
    return Kullanici.firebasedenUret(kullanici);
  }

  Stream<Kullanici> get durumTakipcisi {
    return _firebaseAuth
        .authStateChanges()
        .map((kullanici) => Kullanici.firebasedenUret(kullanici!));
  }

  Future<Kullanici> mailIleKayit(String eposta, String sifre) async {
    var girisKarti = await _firebaseAuth.createUserWithEmailAndPassword(
        email: eposta, password: sifre);
    return _kullaniciOlustur(girisKarti.user!);
  }

  Future<Kullanici> mailIleGiris(String eposta, String sifre) async {
    var girisKarti = await _firebaseAuth.signInWithEmailAndPassword(
        email: eposta, password: sifre);
    return _kullaniciOlustur(girisKarti.user!);
  }

  Future<void> cikisYap() {
    return _firebaseAuth.signOut();
  }

  Future<void> sifremiSifirla(String eposta) async {
    await _firebaseAuth.sendPasswordResetEmail(email: eposta);
  }

  Future<Kullanici> googleIleGiris() async {
    GoogleSignInAccount? googleHesabi = await GoogleSignIn().signIn();
    GoogleSignInAuthentication GoogleYetkiKartim =
        await googleHesabi!.authentication;
    OAuthCredential sifresizGirisBelgesi = GoogleAuthProvider?.credential(
        idToken: GoogleYetkiKartim.idToken,
        accessToken: GoogleYetkiKartim.accessToken);
    UserCredential girisKarti =
        await _firebaseAuth.signInWithCredential(sifresizGirisBelgesi);
    return _kullaniciOlustur(girisKarti.user!);
    // print(girisKarti.user?.displayName);
    //print(girisKarti.user?.photoURL);
    //print(girisKarti.user?.uid);
    //print(girisKarti.user?.email);

    //print(googleHesabi?.id);
    // print(googleHesabi?.displayName);
  }
}
