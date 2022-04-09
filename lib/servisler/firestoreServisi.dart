// @dart=2.9
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ogretmenim2/modeller/duyuru.dart';
import 'package:flutter_ogretmenim2/modeller/gonderi.dart';
import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:flutter_ogretmenim2/modeller/tartisma.dart';
import 'package:flutter_ogretmenim2/servisler/storageServisi.dart';
//burada hesap oluşturacak olan kullanıcıların
//nasıl firestore servisine kayıt yapacağımızı oluşturduk
//

class FirestoreServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime zaman = DateTime.now();
  //aşağıda ihityaç olmamasına reğmen kurum sicil no özelliği ekledim.
  //Gelecekte kullanımı yasak değilse kullanabiliriz.
  String kurumsicilNo = '';

  Future<void> kullaniciOlustur({
    id,
    email,
    kullaniciAdi,
    fotoUrl = '',
  }) async {
    await _firestore.collection('kullanicilar').doc(id).set({
      'kullaniciAdi': kullaniciAdi,
      'email': email,
      'fotoUrl': fotoUrl,
      'hakkinda': '',
      'olusturulmaZamani': zaman,
      'kurumSicilNo': kurumsicilNo,
    });
  }

//eğer kullanıc daha önceden giriş yaptıysa aynı kullanıcıyı tekrardan
//kullanıcılar verisine kayıt yaptırmamak gerekir bunun için
//kullanıcıları getir öethodu çağırılır
  Future<Kullanici> kullaniciGetir(id) async {
    DocumentSnapshot doc =
        await _firestore.collection('kullanicilar').doc(id).get();
    if (doc.exists) {
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
    }
    return null;
  }

  void kullaniciGuncelle(
      {String kullaniciId,
      String kullaniciAdi,
      String fotoUrl = '',
      String hakkinda}) {
    _firestore.collection('kullanicilar').doc(kullaniciId).update({
      'kullaniciAdi': kullaniciAdi,
      'hakkinda': hakkinda,
      'fotoUrl': fotoUrl,
    });
  }

  Future<List<Kullanici>> kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _firestore
        .collection('kullanicilar')
        .where('kullaniciAdi', isGreaterThanOrEqualTo: kelime)
        .get();
    List<Kullanici> kullanicilar =
        snapshot.docs.map((doc) => Kullanici.dokumandanUret(doc)).toList();
    return kullanicilar;
  }

  void takipEt({String aktifKullaniciId, String profilSahibiId}) {
    _firestore
        .collection('takipciler')
        .doc(profilSahibiId)
        .collection('kullanicininTakipcileri')
        .doc(aktifKullaniciId)
        .set({});
    _firestore
        .collection('takipEdilenler')
        .doc(aktifKullaniciId)
        .collection('kullanicininTakipleri')
        .doc(profilSahibiId)
        .set({});

    duyuruEkle(
        aktiviteTipi: 'takip',
        aktiviteYapanId: aktifKullaniciId,
        profilSahibiId: profilSahibiId);
  }

  void takiptenCik({String aktifKullaniciId, String profilSahibiId}) {
    _firestore
        .collection('takipciler')
        .doc(profilSahibiId)
        .collection('kullanicininTakipcileri')
        .doc(aktifKullaniciId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    _firestore
        .collection('takipEdilenler')
        .doc(aktifKullaniciId)
        .collection('kullanicininTakipleri')
        .doc(profilSahibiId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> takipKontrol(
      {String aktifKullaniciId, String profilSahibiId}) async {
    DocumentSnapshot doc = await _firestore
        .collection('takipEdilenler')
        .doc(aktifKullaniciId)
        .collection('kullanicininTakipleri')
        .doc(profilSahibiId)
        .get();
    if (doc.exists) {
      return true;
    }
    return false;
  }

  Future<int> takipciSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('takipciler')
        .doc(kullaniciId)
        .collection('kullanicininTakipcileri')
        .get();
    return snapshot.docs.length;
  }

  Future<int> takipEdilenSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('takipEdilenler')
        .doc(kullaniciId)
        .collection('kullanicininTakipleri')
        .get();
    return snapshot.docs.length;
  }

  void duyuruEkle(
      {String aktiviteYapanId,
      String profilSahibiId,
      String aktiviteTipi,
      String yorum,
      Gonderi gonderi}) {
    if (aktiviteYapanId == profilSahibiId) {
      return;
    }

    _firestore
        .collection('duyurular')
        .doc(profilSahibiId)
        .collection('kullanicininDuyurulari')
        .add({
      'aktiviteYapanId': aktiviteYapanId,
      'aktiviteTipi': aktiviteTipi,
      'gonderiId': gonderi?.id,
      'gonderiFoto': gonderi?.gonderiResimUrl,
      'yorum': yorum,
      'olusturulmaZamani': zaman
    });
  }

  Future<List<Duyuru>> duyurulariGetir(String profilSahibiId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('duyurular')
        .doc(profilSahibiId)
        .collection('kullanicininDuyurulari')
        .orderBy('olusturulmaZamani', descending: true)
        .limit(20)
        .get();

    List<Duyuru> duyurular = [];
    snapshot.docs.forEach((DocumentSnapshot doc) {
      Duyuru duyuru = Duyuru.dokumandanUret(doc);
      duyurular.add(duyuru);
    });
    return duyurular;
  }

  Future<void> gonderiOlustur(
      {gonderResmiUrl, aciklama, yayinlayaId, konum}) async {
    await _firestore
        .collection('gonderiler')
        .doc(yayinlayaId)
        .collection('kullaniciGonderileri')
        .add({
      'gonderiResmiUrl': gonderResmiUrl,
      'aciklama': aciklama,
      'yayinlayanId': yayinlayaId,
      'begeniSayisi': 0,
      'konum': konum,
      'olusturulmaZamani': zaman
    });
  }

  Future<List<Gonderi>> gonderileriGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('gonderiler')
        .doc(kullaniciId)
        .collection('kullaniciGonderileri')
        .orderBy('olusturulmaZamani', descending: true)
        .get();
    List<Gonderi> gonderiler =
        snapshot.docs.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<List<Gonderi>> akisGonderileriniGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('akislar')
        .doc(kullaniciId)
        .collection('kullaniciAkisGonderileri')
        .orderBy('olusturulmaZamani', descending: true)
        .get();
    List<Gonderi> gonderiler =
        snapshot.docs.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<void> gonderiSil({String aktifKullaniciId, Gonderi gonderi}) async {
    _firestore
        .collection('gonderiler')
        .doc(aktifKullaniciId)
        .collection('kullaniciGonderileri')
        .doc(gonderi.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //Gonderi silme işlemi tamam ama yorumlarını da silmek lazım
    QuerySnapshot yorumlarSnapShot = await _firestore
        .collection('yorumlar')
        .doc(gonderi.id)
        .collection('gonderiYorumlari')
        .get();

    yorumlarSnapShot.docs.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //gondri Duyurularını silmek için
    QuerySnapshot duyurularSnapShot = await _firestore
        .collection('duyurular')
        .doc(gonderi.yayinlayanId)
        .collection('kullanicininDuyurulari')
        .where('gonderiId', isEqualTo: gonderi.id)
        .get();

    duyurularSnapShot.docs.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //storage den de resimleri silmemiz gerekli
    StorageServisi().gonderiResmiSil(gonderi.gonderiResimUrl);
  }

  Future<Gonderi> tekliGonderiGetir(
      String gonderiId, String gonderiSahibiId) async {
    DocumentSnapshot doc = await _firestore
        .collection('gonderiler')
        .doc(gonderiSahibiId)
        .collection('kullaniciGonderileri')
        .doc(gonderiId)
        .get();
    Gonderi gonderi = Gonderi.dokumandanUret(doc);
    return gonderi;
  }

  gonderiBegen(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection('gonderiler')
        .doc(gonderi.yayinlayanId)
        .collection('kullaniciGonderileri')
        .doc(gonderi.id);
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi + 1;
      await docRef.update({'begeniSayisi': yeniBegeniSayisi});

      //Kulanıcı beğeni ilişkisini tutabilmek için
      //firestore da begeniler koleksiyonu oluşturdum
      _firestore
          .collection('begeniler')
          .doc(gonderi.id)
          .collection('gonderiBegenileri')
          .doc(aktifKullaniciId)
          .set({});
      //Begeni haberini sahibine yollamalıyız
      duyuruEkle(
        aktiviteTipi: 'begeni',
        aktiviteYapanId: aktifKullaniciId,
        gonderi: gonderi,
        profilSahibiId: gonderi.yayinlayanId,
      );
    }
  }

  gonderiBegeniKaldir(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection('gonderiler')
        .doc(gonderi.yayinlayanId)
        .collection('kullaniciGonderileri')
        .doc(gonderi.id);
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi - 1;
      await docRef.update({'begeniSayisi': yeniBegeniSayisi});

      //beğeniyi sileceğimiz kodlar burada çalışacak
      DocumentSnapshot docBegeni = await _firestore
          .collection('begeniler')
          .doc(gonderi.id)
          .collection('gonderiBegenileri')
          .doc(aktifKullaniciId)
          .get();
      if (docBegeni.exists) {
        docBegeni.reference.delete();
      }
    }
  }

  Future<bool> begenivarmi(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentSnapshot docBegeni = await _firestore
        .collection('begeniler')
        .doc(gonderi.id)
        .collection('gonderiBegenileri')
        .doc(aktifKullaniciId)
        .get();
    if (docBegeni.exists) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot> yorumlariGetir(String gonderiId) {
    return _firestore
        .collection('yorumlar')
        .doc(gonderiId)
        .collection('gonderiYorumlari')
        .orderBy('olusturulmaZamani', descending: true)
        .snapshots();
  }

  Future<void> tartismaOlustur(
      {dusunce, begeniSayisi, icerik, olusturulmaZamani, yayinlayanId}) async {
    var ref = await _firestore.collection('tartismalar').add({
      'dusunce': dusunce,
      'begeniSayisi': 0,
      'icerik': icerik,
      'olusturulmaZamani': zaman,
      'yayinlayanId': yayinlayanId
    });
  }

  Stream<QuerySnapshot> tartismalariGetir() {
    return _firestore
        .collection('tartismalar')
        .orderBy('olusturulmaZamani', descending: true)
        .snapshots();
  }
/*

  Future<List<Tartismalar>> tartismalariGetir(id) async {
    QuerySnapshot snapshot = await _firestore
        .collection('tartismalar')
        .doc(id)
        .collection('kullanicininTartismalari')
        .orderBy('olusturulmaZamani', descending: true)
        .get();

    List<Tartismalar> tartismalar =
        snapshot.docs.map((doc) => Tartismalar.dokumandanUret(doc)).toList();
    return tartismalar;
  }

  */

  Future<void> tartismaSil(String tartismaId) {
    var ref = _firestore.collection('tartismalar').doc(tartismaId).delete();
    return ref;
  }

  Void tartismaYorumlariEkle(
      {String icerik, String aktifKullaniciId, Tartismalar tartismalar}) {
    _firestore
        .collection('tartismalar')
        .doc(tartismalar.id)
        .collection('tartismalarinYorumlari')
        .add({
      'begeniSayisi': 0,
      'icerik': icerik,
      'olusturulmaZamani': zaman,
      'yayinlayanId': aktifKullaniciId
    });
  }

  Stream<QuerySnapshot> tartismaYorumlarinigetir(String tartismaId) {
    return _firestore
        .collection('tartismalar')
        .doc(tartismaId)
        .collection('tartismalarinYorumlari')
        .orderBy('olusturulmaZamani', descending: true)
        .snapshots();
  }

  Void yorumEkle({String aktifKullaniciId, Gonderi gonderi, String icerik}) {
    _firestore
        .collection('yorumlar')
        .doc(gonderi.id)
        .collection('gonderiYorumlari')
        .add({
      'icerik': icerik,
      'yayinlayanId': aktifKullaniciId,
      'olusturulmaZamani': zaman,
    });
    //yorum duyurusunu gonderi sahibine iletmeliyiz

    duyuruEkle(
        aktiviteTipi: 'yorum',
        aktiviteYapanId: aktifKullaniciId,
        gonderi: gonderi,
        profilSahibiId: gonderi.yayinlayanId,
        yorum: icerik);
  }
}
