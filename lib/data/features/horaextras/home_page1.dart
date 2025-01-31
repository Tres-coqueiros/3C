import 'package:flutter/material.dart';
import 'package:senior/data/core/widgets/components/list_colaboradores.dart';
import 'package:senior/data/core/widgets/base_layout.dart';

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
