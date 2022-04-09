// @dart=2.9
import 'package:flutter/material.dart';

import 'package:flutter_ogretmenim2/modeller/gonderi.dart';
import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:flutter_ogretmenim2/sayfalar/ara.dart';
import 'package:flutter_ogretmenim2/sayfalar/forumSayfasi.dart';
import 'package:flutter_ogretmenim2/sayfalar/kazanimlar.dart';
import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';
import 'package:flutter_ogretmenim2/widgetlar/gonderiKarti.dart';
import 'package:flutter_ogretmenim2/widgetlar/silinmeyenFutureBuilder.dart';
import 'package:provider/provider.dart';

class Akis extends StatefulWidget {
  Akis({Key key}) : super(key: key);

  @override
  State<Akis> createState() => _AkisState();
}

class _AkisState extends State<Akis> {
  List<Gonderi> _gonderiler = [];
  _akisGonderileriGetir() async {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKulaniciId;
    List<Gonderi> gonderiler =
        await FirestoreServisi().akisGonderileriniGetir(aktifKullaniciId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _akisGonderileriGetir();
  }

  @override
  Widget build(BuildContext context) {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKulaniciId;
    return Scaffold(
      drawer: Drawer(
        child: ListView(children: [
          DrawerHeader(
            child: Text('ÖĞRETMENİN GERÇEK PLATFORMU'),
          ),
          ListTile(
            title: Text('Öğretmen forum'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => ForumSayfasi())));
            },
          ),
          ListTile(
            title: Text('Mebden haberler'),
          ),
          ListTile(
            title: Text('Kazanımlar'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => Kazanimlar())));
            },
          ),
        ]),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Ara(),
                  ));
            },
          ),
        ],
        title: Text('Öğretmenim'),
        centerTitle: true,
      ),
      body: ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: _gonderiler.length,
        itemBuilder: (context, index) {
          Gonderi gonderi = _gonderiler[index];
          return SilinmeyenFutureBuilder(
            future: FirestoreServisi().kullaniciGetir(gonderi.yayinlayanId),
            builder: (context, snapShot) {
              if (!snapShot.hasData) {
                return SizedBox();
              }
              Kullanici gonderiSahibi = snapShot.data;
              return GonderiKarti(
                gonderi: gonderi,
                yayinlayan: gonderiSahibi,
              );
            },
          );
        },
      ),
    );
  }
}
