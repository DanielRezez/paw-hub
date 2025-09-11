import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/views/tela_carregamento.dart';
import 'package:projeto_integrador2/viewmodels/carregamento_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/tela_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  print('Firebase inicializado com sucesso!');

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
