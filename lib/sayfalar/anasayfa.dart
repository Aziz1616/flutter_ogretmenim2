// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_ogretmenim2/sayfalar/akis.dart';
import 'package:flutter_ogretmenim2/sayfalar/duyurular.dart';
import 'package:flutter_ogretmenim2/sayfalar/forumSayfasi.dart';
import 'package:flutter_ogretmenim2/sayfalar/profil.dart';
import 'package:flutter_ogretmenim2/sayfalar/yukle.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';
import 'package:provider/provider.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({Key key}) : super(key: key);

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  int _aktifSayfaNo = 0;
  PageController sayfaKumandasi;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sayfaKumandasi = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    sayfaKumandasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKulaniciId;

    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (acilanSayfaNo) {
          setState(() {
            _aktifSayfaNo = acilanSayfaNo;
          });
        },
        controller: sayfaKumandasi,
        children: [
          Akis(),
          ForumSayfasi(),
          Yukle(),
          Duyurular(),
          Profil(
            profilSahibiId: aktifKullaniciId,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _aktifSayfaNo,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Akış'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Forum'),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_upload), label: 'Yükle'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Duyurular'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (secilenSayfaNo) {
          setState(() {
            sayfaKumandasi.jumpToPage(secilenSayfaNo);
          });
        },
      ),
    );
  }
}
