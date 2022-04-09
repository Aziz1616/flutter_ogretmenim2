// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:flutter_ogretmenim2/sayfalar/hesapOlustur.dart';
import 'package:flutter_ogretmenim2/sayfalar/sifremiUnuttum.dart';
import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';

import 'package:provider/provider.dart';

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({Key key}) : super(key: key);

  @override
  State<GirisSayfasi> createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  bool yukleniyor = false;
  //Kullanıcıları kayıt edeceğimi< nitelikler aşağıdadır
  String email, sifre;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      body: Stack(
        children: [
          _sayfaElemanlari(),
          _yuklemeAnimasyonu(),
        ],
      ),
    );
  }

  Widget _yuklemeAnimasyonu() {
    if (yukleniyor) {
      return Center(child: CircularProgressIndicator());
    } else {
      return SizedBox(
        height: 0,
      );
    }
  }

  Widget _sayfaElemanlari() {
    return Form(
      key: _formAnahtari,
      child: ListView(
        padding: EdgeInsets.only(left: 20, right: 20, top: 60),
        children: <Widget>[
          FlutterLogo(
            size: 90,
          ),
          SizedBox(
            height: 80,
          ),
          TextFormField(
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email adresinizi giriniz',
              errorStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(
                Icons.mail,
              ),
            ),
            validator: (girilenDeger) {
              if (girilenDeger.isEmpty) {
                return 'Email alanı boş bırakılamaz';
              } else if (!girilenDeger.contains('@')) {
                return 'Girilen değer mail formatında olmalı';
              }
              return null;
            },
            onSaved: (girilenDeger) => email = girilenDeger,
          ),
          SizedBox(
            height: 40,
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Şifrenizi giriniz',
              errorStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (girilenDeger) {
              if (girilenDeger.isEmpty) {
                return 'Şifre alanı boş bırakılamaz';
              } else if (girilenDeger.trim().length < 6) {
                return 'Şifre az 6 karakter olmalı';
              }
              return null;
            },
            onSaved: (girilenDeger) => sifre = girilenDeger,
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            children: [
              Expanded(
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HesapOlustur()));
                  },
                  child: Text(
                    'Hesap Oluştur',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  color: Colors.blue,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: FlatButton(
                  onPressed: _girisYap,
                  child: Text(
                    'Giriş Yap',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Center(child: Text('Veya')),
          SizedBox(
            height: 20,
          ),
          Center(
            child: InkWell(
              onTap: _googleIleGiris,
              child: Text(
                'Google ile giriş yap',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SifremiUnuttum()));
                  },
                  child: Text('Şifremi unuttum'))),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  void _girisYap() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    if (_formAnahtari.currentState.validate()) {
      _formAnahtari.currentState?.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        await _yetkilendirmeServisi.mailIleGiris(email, sifre);
        //Navigator.pop(context);
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata.hashCode);
      }
    }
  }

  void _googleIleGiris() async {
    var _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    setState(() {
      yukleniyor = true;
    });
    try {
      Kullanici kullanici = await _yetkilendirmeServisi.googleIleGiris();
      if (kullanici != null) {
        Kullanici firestoreKullanici =
            await FirestoreServisi().kullaniciGetir(kullanici.id);
        if (firestoreKullanici == null) {
          FirestoreServisi().kullaniciOlustur(
            id: kullanici.id,
            email: kullanici.email,
            kullaniciAdi: kullanici.kullaniciAdi,
            fotoUrl: kullanici.fotoUrl,
          );
        }
      }
    } catch (hata) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(hataKodu: hata.hashCode);
    }
  }
  //uyarı göster methodunda hata var

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu == "user-not-found") {
      hataMesaji = "Böyle bir kullanıcı bulunmuyor";
    } else if (hataKodu == "invalid-email") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir";
    } else if (hataKodu == "ERROR_WRONG_PASSWORD") {
      hataMesaji = "Girilen şifre hatalı";
    } else if (hataKodu == "user-disabled") {
      hataMesaji = "Kullanıcı engellenmiş";
    } else {
      hataMesaji = "Tanımlanamayan bir hata oluştu $hataKodu";
    }
    var snackBar = SnackBar(content: Text(hataMesaji));
//yeni kullanım
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
