// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_ogretmenim2/modeller/gonderi.dart';
import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:flutter_ogretmenim2/sayfalar/profiliDuzenle.dart';
import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';
import 'package:flutter_ogretmenim2/widgetlar/gonderiKarti.dart';

import 'package:provider/provider.dart';

class Profil extends StatefulWidget {
  final String profilSahibiId;
  const Profil({Key key, this.profilSahibiId}) : super(key: key);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _gonderiSayisi = 0;
  int _takipci = 0;
  int _takipEdilen = 0;
  List<Gonderi> _gonderiler = [];
  String gonderiStili = 'Liste';
  String _aktifKullaniciId;
  Kullanici _profilSahibi;
  bool _takipEdildi = false;
  _takipcisayisiGetir() async {
    int takipciSayisi =
        await FirestoreServisi().takipciSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipci = takipciSayisi;
      });
    }
  }

  _takipEdilensayisiGetir() async {
    int takipEdilenSayisi =
        await FirestoreServisi().takipEdilenSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipEdilen = takipEdilenSayisi;
      });
    }
  }

  _gonderileriGetir() async {
    List<Gonderi> gonderiler =
        await FirestoreServisi().gonderileriGetir(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
        _gonderiSayisi = _gonderiler.length;
      });
    }
  }

  _takipKontrol() async {
    bool takipVarmi = await FirestoreServisi().takipKontrol(
        profilSahibiId: widget.profilSahibiId,
        aktifKullaniciId: _aktifKullaniciId);

    setState(() {
      _takipEdildi = takipVarmi;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _takipcisayisiGetir();
    _takipEdilensayisiGetir();
    _gonderileriGetir();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKulaniciId;
    _takipKontrol();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blue[300],
        actions: [
          widget.profilSahibiId == _aktifKullaniciId
              ? IconButton(
                  onPressed: _cikisYap,
                  icon: Icon(Icons.exit_to_app),
                  color: Colors.black,
                )
              : SizedBox(
                  height: 0,
                ),
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Object>(
          future: FirestoreServisi().kullaniciGetir(widget.profilSahibiId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            _profilSahibi = snapshot.data;
            return ListView(
              children: [
                _profilDetaylari(snapshot.data),
                _gonderileriGoster(snapshot.data),
              ],
            );
          }),
    );
  }

  Widget _gonderileriGoster(Kullanici profilData) {
    if (gonderiStili == 'Liste') {
      return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: _gonderiler.length,
        itemBuilder: (context, index) {
          return GonderiKarti(
            gonderi: _gonderiler[index],
            yayinlayan: profilData,
          );
        },
      );
    } else {
      List<GridTile> fayanslar = [];
      _gonderiler.forEach((gonderi) {
        fayanslar.add(
          _fayansOlustur(gonderi),
        );
      });
      return GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        shrinkWrap: true,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: fayanslar,
        childAspectRatio: 1.0,
      );
    }
  }

  GridTile _fayansOlustur(Gonderi gonderi) {
    return GridTile(
      child: Image.network(
        gonderi.gonderiResimUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _profilDetaylari(Kullanici profilData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 50,
                backgroundImage: profilData.fotoUrl.isNotEmpty
                    ? NetworkImage(profilData.fotoUrl)
                    : AssetImage('assets/images/ogretmen.png'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sosyalSayac(baslik: 'Gönderiler', sayi: _gonderiSayisi),
                    _sosyalSayac(baslik: 'Takipçi', sayi: _takipci),
                    _sosyalSayac(baslik: 'Takip', sayi: _takipEdilen)
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            profilData.kullaniciAdi,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            profilData.hakkinda,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          widget.profilSahibiId == _aktifKullaniciId
              ? _profiliDuzenleButon()
              : _takipButonu(),
        ],
      ),
    );
  }

  Widget _takipButonu() {
    return _takipEdildi ? _takiptenCik() : _takipEtButonu();
  }

  Widget _takipEtButonu() {
    return Container(
      width: double.infinity,
      child: FlatButton(
        color: Colors.blue,
        onPressed: () {
          FirestoreServisi().takipEt(
              profilSahibiId: widget.profilSahibiId,
              aktifKullaniciId: _aktifKullaniciId);
          setState(() {
            _takipEdildi = true;
            _takipci = _takipci + 1;
          });
        },
        child: Text(
          'Takip et',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _takiptenCik() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {
          FirestoreServisi().takiptenCik(
              profilSahibiId: widget.profilSahibiId,
              aktifKullaniciId: _aktifKullaniciId);
          setState(() {
            _takipEdildi = false;
            _takipci = _takipci - 1;
          });
        },
        child:
            Text('Takipten çık', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _profiliDuzenleButon() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfiliDuzenle(
                  profil: _profilSahibi,
                ),
              ));
        },
        child: Text('Profili Düzenle'),
      ),
    );
  }

  Widget _sosyalSayac({String baslik, int sayi}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          sayi.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2,
        ),
        Text(
          baslik,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  void _cikisYap() {
    Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }
}
