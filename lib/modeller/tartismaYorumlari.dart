// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

//kazanımlar içinde bu yapıyı oluşturmam gerekli
class TartismaYorumlari {
  final String id;
  final String icerik;
  final String yayinlayanId;
  final int begeniSayisi;
  final Timestamp olusturulmaZamani;

  TartismaYorumlari(
      {this.id,
      this.icerik,
      this.yayinlayanId,
      this.begeniSayisi,
      this.olusturulmaZamani});
  factory TartismaYorumlari.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return TartismaYorumlari(
      id: doc.id,
      icerik: doc['icerik'],
      yayinlayanId: doc['yayinlayanId'],
      begeniSayisi: doc['begeniSayisi'],
      olusturulmaZamani: doc['olusturulmaZamani'],
    );
  }
}
