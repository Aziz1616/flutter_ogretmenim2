// @dart=2.9

import 'package:flutter/material.dart';

import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:flutter_ogretmenim2/sayfalar/profil.dart';
import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';

class Ara extends StatefulWidget {
  @override
  State<Ara> createState() => _AraState();
}

class _AraState extends State<Ara> {
  TextEditingController _aramacontroller = TextEditingController();
  Future<List<Kullanici>> _aramaSonucu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarOlustur(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar _appBarOlustur() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: Colors.blue,
      title: TextFormField(
        onFieldSubmitted: (girilenDeger) {
          setState(() {
            _aramaSonucu = FirestoreServisi().kullaniciAra(girilenDeger);
          });
        },
        controller: _aramacontroller,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            size: 30,
          ),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _aramaSonucu = null;
                });
                _aramacontroller.clear();
              }),
          border: InputBorder.none,
          fillColor: Colors.white,
          filled: true,
          hintText: 'Kullanıcı ara...',
          contentPadding: EdgeInsets.only(top: 16),
        ),
      ),
    );
  }

  aramaYok() {
    return Center(child: Text('Kullanıcı ara'));
  }

  sonuclariGetir() {
    return FutureBuilder<List<Kullanici>>(
        future: _aramaSonucu,
        builder: (context, snapshots) {
          if (!snapshots.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshots.data.length == 0) {
            return Center(child: Text('Sonuç bulunamadı'));
          }
          return ListView.builder(
              itemCount: snapshots.data.length,
              itemBuilder: (context, index) {
                Kullanici kullanici = snapshots.data[index];
                return kullaniciSatiri(kullanici);
              });
        });
  }

  kullaniciSatiri(Kullanici kullanici) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Profil(
                      profilSahibiId: kullanici.id,
                    )));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(kullanici.fotoUrl),
        ),
        title: Text(
          kullanici.kullaniciAdi,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
