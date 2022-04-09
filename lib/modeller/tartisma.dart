// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

//kazanımlar içinde bu yapıyı oluşturmam gerekli
class Tartismalar {
  final String id;
  final String icerik;
  final String yayinlayanId;
  final int begeniSayisi;
  final Timestamp olusturulmaZamani;
  final String dusunce;

  Tartismalar(
      {this.id,
      this.dusunce,
      this.icerik,
      this.yayinlayanId,
      this.begeniSayisi,
      this.olusturulmaZamani});
  factory Tartismalar.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Tartismalar(
        id: doc.id,
        icerik: doc['icerik'],
        yayinlayanId: doc['yayinlayanId'],
        begeniSayisi: doc['begeniSayisi'],
        olusturulmaZamani: doc['olusturulmaZamani'],
        dusunce: doc['dusunce']);
  }
}
