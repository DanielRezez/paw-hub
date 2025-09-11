import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/views/tela_carregamento.dart';
import 'package:projeto_integrador2/viewmodels/carregamento_viewmodel.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CarregamentoViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: TelaCarregamento(title: 'Carregando...'),
    );
  }
}
