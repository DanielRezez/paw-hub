import 'package:projeto_integrador2/viewmodels/inicial_viewmodel.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: TelaInicial(title: "Tela inicial"),
  ));
}

class TelaInicial extends StatefulWidget {
  final String title;
  const TelaInicial({
    super.key,
    required this.title,
  });

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
    );
  }
}