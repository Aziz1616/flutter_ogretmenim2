import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Kullanici {
  final String id;
  String? kullaniciAdi;
  String? fotoUrl;
  String? email;
  String? hakkinda;

  Kullanici(
      {required this.id,
      required this.kullaniciAdi,
      required this.fotoUrl,
      required this.email,
      required this.hakkinda});

  factory Kullanici.firebasedenUret(User kullanici) {
    return Kullanici(
      id: kullanici.uid,
      kullaniciAdi: kullanici.displayName,
      fotoUrl: kullanici.photoURL,
      email: kullanici.email,
      hakkinda: '',
    );
  }

  factory Kullanici.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Kullanici(
      id: doc.id,
      kullaniciAdi: doc['kullaniciAdi'],
      email: doc['email'],
      fotoUrl: doc['fotoUrl'],
      hakkinda: doc['hakkinda'],
    );
  }
}
