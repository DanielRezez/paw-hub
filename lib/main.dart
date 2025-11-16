import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/views/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';
import 'package:projeto_integrador2/viewmodels/sensor_viewmodel.dart';
import 'package:projeto_integrador2/viewmodels/agenda_viewmodel.dart';
import 'package:projeto_integrador2/viewmodels/inicial_viewmodel.dart';

// --- ATENÇÃO ---
import 'package:projeto_integrador2/utils/cores.dart';
import 'package:projeto_integrador2/utils/tipografia.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('Firebase inicializado com sucesso!');

  runApp(
    MultiProvider(
      providers: [
        // Providers originais
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => SensorViewModel()),

        // 1. Fonte da verdade da Agenda (global)
        ChangeNotifierProvider(
          create: (context) => TelaAgendaViewModel(),
        ),

        // 2. InicialViewModel recebe o TelaAgendaViewModel
        ChangeNotifierProxyProvider<TelaAgendaViewModel, InicialViewModel>(
          create: (context) {
            final agendaVM =
            Provider.of<TelaAgendaViewModel>(context, listen: false);
            return InicialViewModel(agendaVM);
          },
          update: (context, agendaVM, inicialAnterior) {
            // Se já existir, reaproveita; se não, cria com o agendaVM
            return inicialAnterior ?? InicialViewModel(agendaVM);
          },
        ),
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
      title: 'PetCare Monitor',
      theme: ThemeData(
        textTheme: tipografia,
        scaffoldBackgroundColor: corOffWhite,
        primaryColor: corVerdeAgua,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: corBeringela,
          secondary: corPesce,
          surface: corOffWhite,
          onSurface: const Color(0xFF0D1B2A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: corBeringela,
          foregroundColor: corBrancoPuro,
        ),
      ),
      home: Wrapper(),
    );
  }
}
