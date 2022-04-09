// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';

import 'package:provider/provider.dart';

class HesapOlustur extends StatefulWidget {
  const HesapOlustur({Key key}) : super(key: key);

  @override
  State<HesapOlustur> createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  bool yukleniyor = false;
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  String kullaniciAdi, email, sifre;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      appBar: AppBar(title: Text('Hesap Oluştur')),
      body: ListView(
        children: [
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0,
                ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formAnahtari,
              child: Column(
                children: [
                  TextFormField(
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: 'Kullanıcı adınızı giriniz',
                        labelText: 'Kullanıcı adı:',
                        errorStyle: TextStyle(fontSize: 16),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (girilenDeger) {
                        if (girilenDeger.isEmpty) {
                          return 'Kullanıcı alanı boş bırakılamaz';
                        } else if (girilenDeger.trim().length < 4 ||
                            girilenDeger.trim().length > 10) {
                          return 'En az 4 en fazla 10 karakter olmalı';
                        }
                        return null;
                      },
                      onSaved: (girilenDeger) => kullaniciAdi = girilenDeger),
                  SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    autocorrect: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email adresinizi giriniz',
                      labelText: 'Mail:',
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
                      labelText: 'Şifre:',
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
                    height: 50,
                  ),
                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      onPressed: _kullaniciOlustur,
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
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _kullaniciOlustur() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    var _formState = _formAnahtari.currentState;
    if (_formState.validate()) {
      _formState.save();

      setState(() {
        yukleniyor = true;
      });

      try {
        Kullanici kullanici =
            await _yetkilendirmeServisi.mailIleKayit(email, sifre);
        if (kullanici != null) {
          FirestoreServisi().kullaniciOlustur(
              id: kullanici.id, email: email, kullaniciAdi: kullaniciAdi);
        }
        Navigator.pop(context);
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata.hashCode);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu == "invalid-email") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir";
    } else if (hataKodu == "ERROR_EMAIL_ALREADY_IN_USE") {
      hataMesaji = "Girdiğiniz mail kayıtlıdır";
    } else if (hataKodu == "ERROR_WEAK_PASSWORD") {
      hataMesaji = "Daha zor bir şifre tercih edin";
    } else {
      hataMesaji = "Tanımlanamayan bir hata oluştu $hataKodu";
    }
    var snackBar = SnackBar(content: Text(hataMesaji));
//yeni kullanım
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
