import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/inicial_viewmodel.dart'; // Corrigido para seu ViewModel
import 'views/tela_inicial.dart';

// --- ATENÇÃO ---
// Garanta que você tem esses arquivos com suas definições de cores e fontes
import 'package:projeto_integrador2/utils/cores.dart';
import 'package:projeto_integrador2/utils/tipografia.dart';

void main() {
  runApp(
    // O Provider "servindo" sua ViewModel para o app
    ChangeNotifierProvider(
      create: (context) => inicialViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetCare Monitor', // Adicionado um título
      theme: ThemeData(
        textTheme: tipografia,
        scaffoldBackgroundColor: corOffWhite,
        primaryColor: corVerdeAgua,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: corBeringela, // Usado em alguns lugares
          secondary: corPesce,
          surface: corOffWhite, // Cor de fundo de cards, etc
          background: corOffWhite, // Cor de fundo principal
          onSurface: const Color(0xFF0D1B2A), // Cor para textos em cima de 'surface'
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: corBeringela,
          foregroundColor: corOffWhite,
        ),
      ),
      home: const TelaInicial(), // Não precisa mais do title aqui
    );
  }
}