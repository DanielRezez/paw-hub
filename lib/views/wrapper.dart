// lib/views/wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'tela_login.dart';       // Sua futura tela de login
import 'tela_inicial.dart';    // Sua tela principal quando logado
// Se você tiver uma tela de carregamento específica para autenticação, pode usá-la aqui.
// import 'tela_carregamento_auth.dart';

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
      // Se autenticado e o usuário existe, mostra a tela inicial
        if (authViewModel.user != null) {
          // TODO: Certifique-se que você tem uma TelaInicial criada
          return TelaInicial(); // Adapte para o nome da sua tela principal
        }
        // Se por algum motivo o status é autenticado mas user é null, vai para o login (fallback)
        return TelaLogin(); // Adapte para o nome da sua tela de login
      case AuthStatus.unauthenticated:
      case AuthStatus.error: // Se não autenticado ou deu erro, mostra a tela de login
      // TODO: Certifique-se que você tem uma TelaLogin criada
        return TelaLogin(); // Adapte para o nome da sua tela de login
    }
  }
}

