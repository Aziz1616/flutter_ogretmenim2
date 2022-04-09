// @dart=2.9
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/servisler/storageServisi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Yukle extends StatefulWidget {
  const Yukle({Key key}) : super(key: key);

  @override
  State<Yukle> createState() => _YukleState();
}

class _YukleState extends State<Yukle> {
  File dosya;
  bool yukleniyor = false;
  TextEditingController aciklamaTextKumandasi = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return dosya == null ? yukleButonu() : gonderiFormu();
  }

  Widget yukleButonu() {
    return IconButton(
      icon: Icon(
        Icons.file_upload,
        size: 50,
      ),
      onPressed: () {
        fotografSec();
      },
    );
  }

  Widget gonderiFormu() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text(
          'Gönderi oluştur',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              dosya = null;
            });
          },
        ),
        actions: [
          IconButton(
              onPressed: _gonderiOlustur,
              icon: Icon(
                Icons.send,
                color: Colors.black,
              ))
        ],
      ),
      body: ListView(
        children: [
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0,
                ),
          AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Image.file(
                dosya,
                fit: BoxFit.cover,
              )),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: aciklamaTextKumandasi,
            decoration: InputDecoration(
              hintText: 'Açıklma ekle',
              contentPadding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
            ),
          ),
          //TextFormField(
          // decoration: InputDecoration(
          //    hintText: 'Açıklma ekle',
          //   contentPadding: EdgeInsets.only(
          //     left: 15,
          //     right: 15,
          //   )),
          //  ),
        ],
      ),
    );
  }

  void _gonderiOlustur() async {
    if (!yukleniyor) {
      setState(() {
        yukleniyor = true;
      });

      String resimUrl = await StorageServisi().gonderiResmiYukle(dosya);
      String aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKulaniciId;
      FirestoreServisi().gonderiOlustur(
          //konum değişkenini burada da boş bıraktım
          //gerekirse sonradan aktifleştirebiliriz
          gonderResmiUrl: resimUrl,
          aciklama: aciklamaTextKumandasi.text,
          yayinlayaId: aktifKullaniciId,
          konum: '');
      setState(() {
        yukleniyor = false;
        aciklamaTextKumandasi.clear();
        dosya = null;
      });
    }
  }

  fotografSec() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Gönderi oluştur'),
            children: [
              SimpleDialogOption(
                child: Text('Fotoğraf çek'),
                onPressed: () {
                  fotoCek();
                },
              ),
              SimpleDialogOption(
                child: Text('Galeriden yükle'),
                onPressed: () {
                  galeridenSec();
                },
              ),
              SimpleDialogOption(
                child: Text('İptal'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  fotoCek() async {
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      dosya = File(image.path);
    });
  }

  galeridenSec() async {
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      dosya = File(image.path);
    });
  }
}
