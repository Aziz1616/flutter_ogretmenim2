// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_ogretmenim2/modeller/gonderi.dart';
import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/widgetlar/gonderiKarti.dart';

class Tekligonderi extends StatefulWidget {
  final String gonderiId;
  final String gonderiSahibiId;

  const Tekligonderi({Key key, this.gonderiId, this.gonderiSahibiId})
      : super(key: key);

  @override
  State<Tekligonderi> createState() => _TekligonderiState();
}

class _TekligonderiState extends State<Tekligonderi> {
  Gonderi _gonderi;
  Kullanici _gonderiSahibi;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    gonderiGetir();
  }

  gonderiGetir() async {
    Gonderi gonderi = await FirestoreServisi()
        .tekliGonderiGetir(widget.gonderiId, widget.gonderiSahibiId);
    if (gonderi != null) {
      Kullanici gonderSahibi =
          await FirestoreServisi().kullaniciGetir(gonderi.yayinlayanId);
      setState(() {
        _gonderi = gonderi;
        _gonderiSahibi = gonderSahibi;
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gönderi',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blue[100],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: !_yukleniyor
          ? GonderiKarti(
              gonderi: _gonderi,
              yayinlayan: _gonderiSahibi,
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
