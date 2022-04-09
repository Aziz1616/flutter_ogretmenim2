// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ogretmenim2/modeller/gonderi.dart';
import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:flutter_ogretmenim2/modeller/yorum.dart';
import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class Yorumlar extends StatefulWidget {
  final Gonderi gonderi;

  const Yorumlar({Key key, this.gonderi}) : super(key: key);

  @override
  State<Yorumlar> createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  TextEditingController _yorumControlcusu = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Yorumlar',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(children: [_yorumlariGoster(), _yorumEkle()]),
    );
  }

  _yorumlariGoster() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            Yorum yorum = Yorum.dokumandanUret(snapshot.data.docs[index]);
            return _yorumSatiri(yorum);
          },
        );
      },
      stream: FirestoreServisi().yorumlariGetir(widget.gonderi.id),
    ));
  }

  _yorumSatiri(Yorum yorum) {
    return FutureBuilder<Kullanici>(
        future: FirestoreServisi().kullaniciGetir(yorum.yayinlayanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 0,
            );
          }

          Kullanici yayinlayan = snapshot.data;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(yayinlayan.fotoUrl),
            ),
            title: RichText(
              text: TextSpan(
                text: yayinlayan.kullaniciAdi + ' ',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: [
                  TextSpan(
                      text: yorum.icerik,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 14)),
                ],
              ),
            ),

            //yorum yapılma zamnını göstermek için
            subtitle: Text(
                timeago.format(yorum.olusturulmaZamani.toDate(), locale: 'tr')),
          );
        });
  }

  _yorumEkle() {
    return ListTile(
      title: TextFormField(
        controller: _yorumControlcusu,
        decoration: InputDecoration(hintText: 'Yorum Yazınız'),
      ),
      trailing: IconButton(
        icon: Icon(Icons.send),
        onPressed: _yorumGonder,
      ),
    );
  }

  void _yorumGonder() {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKulaniciId;

    FirestoreServisi().yorumEkle(
        aktifKullaniciId: aktifKullaniciId,
        gonderi: widget.gonderi,
        icerik: _yorumControlcusu.text);
    _yorumControlcusu.clear();
  }
}
