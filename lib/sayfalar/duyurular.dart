// @dart=2.9
import 'package:flutter_ogretmenim2/modeller/duyuru.dart';
import 'package:flutter_ogretmenim2/modeller/kullanici.dart';
import 'package:flutter_ogretmenim2/sayfalar/profil.dart';
import 'package:flutter_ogretmenim2/sayfalar/tekliGonderi.dart';
import 'package:flutter_ogretmenim2/servisler/firestoreServisi.dart';
import 'package:flutter_ogretmenim2/servisler/yetkilendirmeServisi.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Duyurular extends StatefulWidget {
  @override
  State<Duyurular> createState() => _DuyurularState();
}

class _DuyurularState extends State<Duyurular> {
  List<Duyuru> _duyurular;
  String _aktifKullaniciId;
  bool _yukleniyor = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKulaniciId;
    duyurulariGetir();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Future<void> duyurulariGetir() async {
    List<Duyuru> duyurular =
        await FirestoreServisi().duyurulariGetir(_aktifKullaniciId);
    if (mounted) {
      setState(() {
        _duyurular = duyurular;
        _yukleniyor = false;
      });
    }
  }

  duyurlariGoster() {
    if (_yukleniyor) {
      return Center(child: CircularProgressIndicator());
    }
    if (_duyurular.isEmpty) {
      return Center(child: Text('Hiç duyuru yok'));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: RefreshIndicator(
        onRefresh: duyurulariGetir,
        child: ListView.builder(
          itemCount: _duyurular.length,
          itemBuilder: (context, index) {
            Duyuru duyuru = _duyurular[index];
            return duyuruSatiri(duyuru);
          },
        ),
      ),
    );
  }

  duyuruSatiri(Duyuru duyuru) {
    String mesaj = mesajOlustur(duyuru.aktiviteTipi);
    return FutureBuilder(
        future: FirestoreServisi().kullaniciGetir(duyuru.aktiviteYapanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 0,
            );
          }
          Kullanici aktiviteYapan = snapshot.data;
          return ListTile(
            leading: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profil(
                              profilSahibiId: duyuru.aktiviteYapanId,
                            )));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(aktiviteYapan.fotoUrl),
              ),
            ),
            title: RichText(
              text: TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => (Profil(
                                    profilSahibiId: duyuru.aktiviteYapanId,
                                  ))));
                    },
                  text: '${aktiviteYapan.kullaniciAdi} ',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: duyuru.yorum == null
                          ? '$mesaj'
                          : '$mesaj  ${duyuru.yorum}',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ]),
            ),
            subtitle: Text(timeago.format(duyuru.olusturulmaZamani.toDate(),
                locale: 'tr')),
            trailing: gonderiGorsel(
                duyuru.aktiviteTipi, duyuru.gonderiFoto, duyuru.gonderiId),
          );
        });
  }

  gonderiGorsel(String aktiviteTipi, String gonderiFoto, String gonderiId) {
    if (aktiviteTipi == 'takip') {
      return null;
    } else if (aktiviteTipi == 'begeni' || aktiviteTipi == 'yorum') {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Tekligonderi(
                        gonderiId: gonderiId,
                        gonderiSahibiId: _aktifKullaniciId,
                      )));
        },
        child: Image.network(
          gonderiFoto,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  mesajOlustur(String aktiviteTipi) {
    if (aktiviteTipi == 'begeni') {
      return 'gonderini beğendi';
    } else if (aktiviteTipi == 'takip') {
      return 'seni takip etti';
    } else if (aktiviteTipi == 'yorum') {
      return 'gonderine yorum yaptı';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Duyurular',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blue[100],
      ),
      body: duyurlariGoster(),
    );
  }
}
