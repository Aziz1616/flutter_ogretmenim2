// @dart=2.9

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ogretmenim2/modeller/kullanici.dart';

import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/servisler/storageServisi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfiliDuzenle extends StatefulWidget {
  final Kullanici profil;

  const ProfiliDuzenle({Key key, this.profil}) : super(key: key);
  @override
  State<ProfiliDuzenle> createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {
  var _formKey = GlobalKey<FormState>();
  String _kullaniciAdi;
  String _hakkinda;
  File _seciliFoto;
  bool _yukleniyor = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text(
          'Profili Düzenle',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.black,
            ),
            onPressed: () => _kaydet(),
          ),
        ],
      ),
      body: ListView(children: [
        _yukleniyor
            ? LinearProgressIndicator()
            : SizedBox(
                height: 0,
              ),
        _profilFoto(),
        _kullaniciBilgileri()
      ]),
    );
  }

  _kaydet() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _yukleniyor = true;
      });
      _formKey.currentState.save();
      String profilFotoUrl;
      if (_seciliFoto == null) {
        profilFotoUrl = widget.profil.fotoUrl;
      } else {
        profilFotoUrl = await StorageServisi().profilResmiYukle(_seciliFoto);
      }
      String aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKulaniciId;
      FirestoreServisi().kullaniciGuncelle(
          hakkinda: _hakkinda,
          kullaniciAdi: _kullaniciAdi,
          kullaniciId: aktifKullaniciId,
          fotoUrl: profilFotoUrl);
    }
    setState(() {
      _yukleniyor = false;
    });
    Navigator.pop(context);
  }

  _profilFoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20),
      child: Center(
        child: InkWell(
          onTap: _galeridenSec,
          child: CircleAvatar(
            backgroundImage: _seciliFoto == null
                ? NetworkImage(widget.profil.fotoUrl)
                : FileImage(_seciliFoto),
            backgroundColor: Colors.grey,
            radius: 50,
          ),
        ),
      ),
    );
  }

  _galeridenSec() async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _seciliFoto = File(image.path);
    });
  }

  _kullaniciBilgileri() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextFormField(
              initialValue: widget.profil.kullaniciAdi,
              decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
              validator: (girilenDeger) {
                return girilenDeger.trim().length <= 3
                    ? 'Kullanıcı adı en az 4 karakter olmalı'
                    : null;
              },
              onSaved: (girilenDeger) {
                _kullaniciAdi = girilenDeger;
              },
            ),
            TextFormField(
              initialValue: widget.profil.hakkinda,
              decoration: InputDecoration(labelText: 'Hakkında'),
              validator: (girilenDeger) {
                return girilenDeger.trim().length > 100
                    ? '100 karakterden fazla olmaz'
                    : null;
              },
              onSaved: (girilenDeger) {
                _hakkinda = girilenDeger;
              },
            ),
          ],
        ),
      ),
    );
  }
}
