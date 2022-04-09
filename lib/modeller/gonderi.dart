// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';

class Gonderi {
  final String id;
  final String gonderiResimUrl;
  final String aciklama;
  final String yayinlayanId;
  final int begeniSayisi;
  final String konum;

  Gonderi(
      {this.id,
      this.gonderiResimUrl,
      this.aciklama,
      this.yayinlayanId,
      this.begeniSayisi,
      this.konum});

  factory Gonderi.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Gonderi(
      id: doc.id,
      gonderiResimUrl: doc['gonderiResmiUrl'],
      aciklama: doc['aciklama'],
      yayinlayanId: doc['yayinlayanId'],
      begeniSayisi: doc['begeniSayisi'],
      konum: doc['konum'],
    );
  }
}
