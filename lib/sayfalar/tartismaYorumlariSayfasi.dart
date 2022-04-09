// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:flutter_ogretmenim2/modeller/tartisma.dart';
import 'package:flutter_ogretmenim2/modeller/tartismaYorumlari.dart';
import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class TartismaYorumlariSayfasi extends StatefulWidget {
  final Tartismalar tartismalar;

  const TartismaYorumlariSayfasi({Key key, this.tartismalar}) : super(key: key);

  @override
  State<TartismaYorumlariSayfasi> createState() =>
      _TartismaYorumlariSayfasiState();
}

class _TartismaYorumlariSayfasiState extends State<TartismaYorumlariSayfasi> {
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
        title: Text('Forum'),
      ),
      body: Column(
          children: [_tartismaYorumlarinigetir(), _tartismaYorumlariEkle()]),
    );
  }

  _tartismaYorumlarinigetir() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
      stream:
          FirestoreServisi().tartismaYorumlarinigetir(widget.tartismalar.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              TartismaYorumlari tartismaYorumlari =
                  TartismaYorumlari.dokumandanUret(snapshot.data.docs[index]);
              return _tartismaYorumlariSatiri(tartismaYorumlari);
            });
      },
    ));
  }

  _tartismaYorumlariSatiri(TartismaYorumlari tartismaYorumlari) {
    return FutureBuilder<Kullanici>(
        future:
            FirestoreServisi().kullaniciGetir(tartismaYorumlari.yayinlayanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            SizedBox(
              height: 0,
            );
          }
          Kullanici yayinlayan = snapshot.data;
          if (snapshot.data == null) {
            return SizedBox(
              height: 0,
            );
          }
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
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
                      text: tartismaYorumlari.icerik,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 14)),
                ],
              ),
            ),
            subtitle: Text(timeago.format(
                tartismaYorumlari.olusturulmaZamani.toDate(),
                locale: 'tr')),
          );
        });
  }

  _tartismaYorumlariEkle() {
    return ListTile(
      title: TextFormField(
          controller: _yorumControlcusu,
          decoration: InputDecoration(hintText: 'Buraya yazınız')),
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
    FirestoreServisi().tartismaYorumlariEkle(
        aktifKullaniciId: aktifKullaniciId,
        tartismalar: widget.tartismalar,
        icerik: _yorumControlcusu.text);
    _yorumControlcusu.clear();
  }
}
