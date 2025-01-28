import 'package:flutter/material.dart';
import 'package:senior/data/src/components/list_colaboradores.dart';
import 'package:senior/data/src/layout/base_layout.dart';

class HomePage extends StatefulWidget {
  @override
  _Homepage createState() => _Homepage();
}

class _Homepage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        body: Scaffold(
      body: ListColaboradores(),
    ));
  }
}
