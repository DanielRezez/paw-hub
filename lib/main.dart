import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/views/wrapper.dart';
import 'package:projeto_integrador2/viewmodels/carregamento_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';
import 'package:projeto_integrador2/views/wrapper.dart';
import 'views/tela_login.dart';
import 'viewmodels/inicial_viewmodel.dart'; // Corrigido para seu ViewModel
import 'views/tela_inicial.dart';

// --- ATENÇÃO ---
// Garanta que você tem esses arquivos com suas definições de cores e fontes
import 'package:projeto_integrador2/utils/cores.dart';
import 'package:projeto_integrador2/utils/tipografia.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('Firebase inicializado com sucesso!');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
      ],
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
      home: Wrapper(),
    );
  }
}