// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ogretmenim2/modeller/kullanici.dart';

import 'package:flutter_ogretmenim2/modeller/tartisma.dart';

import 'package:flutter_ogretmenim2/sayfalar/tartismaBalat.dart';
import 'package:flutter_ogretmenim2/sayfalar/tartismaYorumlariSayfasi.dart';

import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';
import 'package:flutter_ogretmenim2/widgetlar/silinmeyenFutureBuilder.dart';

import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumSayfasi extends StatefulWidget {
  final Tartismalar tartismalar;

  const ForumSayfasi({Key key, this.tartismalar}) : super(key: key);
  @override
  State<ForumSayfasi> createState() => _ForumSayfasiState();
}

class _ForumSayfasiState extends State<ForumSayfasi> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  Widget build(BuildContext context) {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKulaniciId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Forum Sayfasi'),
      ),
      body: Column(
        children: [_tartismalariGoster()],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.mode_edit),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => TartismaBaslat(
                        tartismalar: widget.tartismalar,
                      ))));
        },
      ),
    );
  }

  /*

  _tartismalariGetir() async {
    List<Tartismalar> tartismalar =
        await FirestoreServisi().tartismalariGetir(widget);
    setState(() {
      _tartismalar = tartismalar;
      print(_tartismalar[1].id);
    });
    print(_tartismalar[2].id);
  }

  Widget _tartismalariGoster() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _tartismalar.length,
        itemBuilder: (context, index) {
          return Container(
            height: 50,
            color: Colors.amber,
          );
        });
  }
  */

  _tartismalariGoster() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreServisi().tartismalariGetir(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                Tartismalar tartismalar =
                    Tartismalar.dokumandanUret(snapshot.data.docs[index]);
                return _tartismasatiri(tartismalar);
              });
        },
      ),
    );
  }

  _tartismasatiri(Tartismalar tartismalar) {
    return SilinmeyenFutureBuilder(
        future: FirestoreServisi().kullaniciGetir(tartismalar.yayinlayanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 0,
            );
          }
          Kullanici yayinlayan = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(5),
              height: 250,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(children: [
                Text(timeago.format(tartismalar.olusturulmaZamani.toDate(),
                    locale: 'tr')),
                Text(
                  yayinlayan.kullaniciAdi,
                  style: TextStyle(fontSize: 15),
                ),
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(
                    yayinlayan.fotoUrl,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      'Konu : ' + tartismalar.icerik,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TartismaYorumlariSayfasi(
                                  tartismalar: tartismalar,
                                )));
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    'Düşünce :' + tartismalar.dusunce,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ]),
            ),
          );
        });
  }
}
