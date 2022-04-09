import 'package:flutter/material.dart';
import 'package:flutter_ogretmenim2/widgetlar/kazanimKarti.dart';

class Kazanimlar extends StatefulWidget {
  const Kazanimlar({Key? key}) : super(key: key);

  @override
  State<Kazanimlar> createState() => _KazanimlarState();
}

class _KazanimlarState extends State<Kazanimlar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kazanımlar')),
      body: sinifSeciniz(),
    );
  }

  sinifSeciniz() {
    return ListTile();
  }
}
