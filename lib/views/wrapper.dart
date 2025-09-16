// lib/views/wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';
import 'package:projeto_integrador2/viewmodels/inicial_viewmodel.dart'; // Importar
import 'package:projeto_integrador2/views/tela_inicial.dart';
import 'package:projeto_integrador2/views/tela_login.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Pede ao Provider para nos dar acesso ao AuthViewModel
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Verifica o status da autenticação
    switch (authViewModel.status) {
      case AuthStatus.uninitialized:
      case AuthStatus.authenticating:
      // Enquanto estiver verificando ou tentando autenticar, mostra um loading
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.authenticated:
        if (authViewModel.user != null) {
          return ChangeNotifierProvider<inicialViewModel>(
            create: (context) {
              return inicialViewModel();
            },
            child: const TelaInicial(),
          );
        }
        return TelaLogin();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return TelaLogin();
    }
  }
}

