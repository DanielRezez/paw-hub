// lib/views/wrapper.dart
import 'package:projeto_integrador2/utils/app_exports.dart'; // Import centralizado
import 'package:projeto_integrador2/views/tela_inicial.dart';
import 'package:projeto_integrador2/views/tela_login.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  // Função helper para construir a tela de login com seu provider
  // Isso evita duplicação e garante que LoginViewModel sempre seja fornecido para TelaLogin
  Widget _buildLoginScreen(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>(
      create: (context) {
        // Obtém o AuthViewModel já fornecido para passá-lo ao LoginViewModel
        final authVM = Provider.of<AuthViewModel>(context, listen: false);
        return LoginViewModel(authVM); // Passa a dependência
      },
      child: const TelaLogin(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    switch (authViewModel.status) {
      case AuthStatus.uninitialized:
      case AuthStatus.authenticating:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );

      case AuthStatus.authenticated:
        if (authViewModel.user != null) {
          // Aqui NÃO criamos outro InicialViewModel,
          // usamos o que já foi fornecido pelo MultiProvider no main.dart
          return const TelaInicial();
        }
        // Status autenticado mas user null -> força ir pro login
        return _buildLoginScreen(context);

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return _buildLoginScreen(context);
    }
  }
}
