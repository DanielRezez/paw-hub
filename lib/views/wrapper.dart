import 'package:flutter/material.dart';
import 'package:projeto_integrador2/views/tela_inicial.dart';
import 'package:projeto_integrador2/views/tela_login.dart';
import 'package:projeto_integrador2/viewmodels/carregamento_viewmodel.dart';

class TelaCarregamento extends StatefulWidget {
  final String title;
  const TelaCarregamento({
    super.key,
    required this.title,
  });

  @override
  State<TelaCarregamento> createState() => _TelaCarregamentoState();
}

class _TelaCarregamentoState extends State<TelaCarregamento> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
    );
  }
}