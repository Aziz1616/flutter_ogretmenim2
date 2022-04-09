// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_ogretmenim2/modeller/tartisma.dart';
import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';
import 'package:provider/provider.dart';

class TartismaBaslat extends StatefulWidget {
  final Tartismalar tartismalar;

  const TartismaBaslat({Key key, this.tartismalar}) : super(key: key);

  @override
  State<TartismaBaslat> createState() => _TartismaBaslatState();
}

final _formAnahtari = GlobalKey<FormState>();
final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
bool yukleniyor = false;

class _TartismaBaslatState extends State<TartismaBaslat> {
  String tartismaBasligi, dusunce;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldAnahtari,
        appBar: AppBar(
          title: Text('Tartisma Başlatma Sayfası'),
        ),
        body: Stack(
          children: [_tartismaFormu()],
        ));
  }

  Widget _tartismaFormu() {
    return Form(
      key: _formAnahtari,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tartışma başlığı yazınız'),
              validator: (girilenDeger) {
                if (girilenDeger.isEmpty) {
                  return 'Girilen değer boş olmaz';
                } else if (girilenDeger.length > 35) {
                  return 'En fazla 35 karakter';
                }
              },
              onChanged: (girilenDeger) => tartismaBasligi = girilenDeger,
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Düşüncelerinizi yazınız'),
              validator: (girilenDeger) {
                if (girilenDeger.isEmpty) {
                  return 'Düşünceleriniz boş olamaz';
                } else if (girilenDeger.length > 100) {
                  return 'En fazla 100 karakter';
                }
              },
              onChanged: (girilendeger) => dusunce = girilendeger,
            ),
          ),
          RaisedButton(
            color: Colors.blue,
            child: Text(
              'Tartışma gonder',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              if (_formAnahtari.currentState.validate()) {
                Navigator.pop(context);
                String aktifKullaniciId =
                    Provider.of<YetkilendirmeServisi>(context, listen: false)
                        .aktifKulaniciId;
                if (!yukleniyor) {
                  setState(() {
                    yukleniyor = true;
                  });
                  FirestoreServisi().tartismaOlustur(
                    dusunce: dusunce,
                    icerik: tartismaBasligi,
                    yayinlayanId: aktifKullaniciId,
                  );
                }
                setState(() {
                  yukleniyor = false;
                });
              }
            },
          )
        ],
      ),
    );
  }
}
