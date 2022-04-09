// @dart=2.9
import 'package:flutter/material.dart';

import 'package:flutter_ogretmenim2/modeller/gonderi.dart';
import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:flutter_ogretmenim2/sayfalar/profil.dart';
import 'package:flutter_ogretmenim2/sayfalar/yorumlar.dart';
import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';
import 'package:provider/provider.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;

  const GonderiKarti({Key key, this.gonderi, this.yayinlayan})
      : super(key: key);

  @override
  State<GonderiKarti> createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi = 0;
  bool _begendin = false;
  String _aktifKullaniciId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKulaniciId;
    _begeniSayisi = widget.gonderi.begeniSayisi;
    begeniVarmi();
  }

  begeniVarmi() async {
    bool begeniVarmi =
        await FirestoreServisi().begenivarmi(widget.gonderi, _aktifKullaniciId);
    if (begeniVarmi) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            _gonderiBasligi(),
            _gonderResmi(),
            _gonderAlt(),
          ],
        ));
  }

  gonderiSecenekleri() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Seçim Yapınız '),
            children: [
              SimpleDialogOption(
                child: Text('Gönderi Sil !'),
                onPressed: () {
                  FirestoreServisi().gonderiSil(
                      aktifKullaniciId: _aktifKullaniciId,
                      gonderi: widget.gonderi);
                  Navigator.pop(context);
                },
              ),
              SimpleDialogOption(
                child: Text(
                  'Vazgeç !',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profil(
                          profilSahibiId: widget.gonderi.yayinlayanId,
                        )));
          },
          child: CircleAvatar(
            backgroundImage: widget.yayinlayan.fotoUrl.isNotEmpty
                ? NetworkImage(widget.yayinlayan.fotoUrl)
                : AssetImage('asssets/images/ogretmen.png'),
            backgroundColor: Colors.blue,
          ),
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Profil(
                        profilSahibiId: widget.gonderi.yayinlayanId,
                      )));
        },
        child: Text(
          widget.yayinlayan.kullaniciAdi,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      trailing: _aktifKullaniciId == widget.gonderi.yayinlayanId
          ? IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => gonderiSecenekleri(),
            )
          : null,
      contentPadding: EdgeInsets.all(0),
    );
  }

  _gonderResmi() {
    return GestureDetector(
      onDoubleTap: _begenidegistir,
      child: Image.network(
        widget.gonderi.gonderiResimUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _gonderAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: _begenidegistir,
              icon: !_begendin
                  ? Icon(
                      Icons.favorite_border,
                      size: 35,
                    )
                  : Icon(
                      Icons.favorite,
                      size: 35,
                      color: Colors.red,
                    ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Yorumlar(
                              gonderi: widget.gonderi,
                            )));
              },
              icon: Icon(
                Icons.comment,
                size: 35,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '$_begeniSayisi  beğeni',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 2,
        ),
        widget.gonderi.aciklama.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RichText(
                  text: TextSpan(
                    text: widget.yayinlayan.kullaniciAdi + ' ',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                          text: widget.gonderi.aciklama,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 14)),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 5,
              ),
      ],
    );
  }

  void _begenidegistir() {
    if (_begendin) {
      // Kullanıcı gonderiyi begendiyse begeniyi kaldıracak kodlar yazılmalı,
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi - 1;
      });
      FirestoreServisi().gonderiBegeniKaldir(widget.gonderi, _aktifKullaniciId);
    } else {
      //kullanıcı begenmediyse beğenmesini sağlayacak kodları yazmalyız
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi + 1;
      });
      FirestoreServisi().gonderiBegen(widget.gonderi, _aktifKullaniciId);
    }
  }
}
