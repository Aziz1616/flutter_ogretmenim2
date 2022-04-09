// @dart=2.9

import 'package:flutter/material.dart';

import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:flutter_ogretmenim2/modeller/tartisma.dart';
import 'package:flutter_ogretmenim2/sayfalar/anasayfa.dart';
import 'package:flutter_ogretmenim2/sayfalar/girissayfasi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';
import 'package:provider/provider.dart';

class Yonlendirme extends StatelessWidget {
  const Yonlendirme({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    return StreamBuilder(
      stream: _yetkilendirmeServisi.durumTakipcisi,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          Kullanici aktifKullanici = snapshot.data;
          _yetkilendirmeServisi.aktifKulaniciId = aktifKullanici.id;

          return Anasayfa();
        } else {
          return GirisSayfasi();
        }
      },
    );
  }
}
