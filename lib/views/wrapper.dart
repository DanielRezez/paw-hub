// lib/views/wrapper.dart
import 'package:projeto_integrador2/utils/app_exports.dart'; // Import centralizado
import 'package:projeto_integrador2/views/tela_inicial.dart';
import 'package:projeto_integrador2/views/tela_login.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  // Função helper para construir a tela de login com seu provider
  // Isso evita duplicação e garante que LoginViewModel sempre seja fornecido para TelaLogin
  Widget _buildLoginScreen(BuildContext context) {
    // print("[Wrapper Helper] Construindo TelaLogin com LoginViewModel");
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
    // print("[Wrapper Build] Status: ${authViewModel.status}, User: ${authViewModel.user?.uid}");

    switch (authViewModel.status) {
      case AuthStatus.uninitialized:
      case AuthStatus.authenticating:
      // print("[Wrapper] Status: Uninitialized or Authenticating -> Loading");
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );

      case AuthStatus.authenticated:
      // print("[Wrapper] Status: Authenticated");
        if (authViewModel.user != null) {
          // print("[Wrapper] User authenticated -> TelaInicial com InicialViewModel");
          return ChangeNotifierProvider<InicialViewModel>( // <<< NOME CORRIGIDO
            create: (context) {
              // Se InicialViewModel precisar do AuthViewModel ou User:
              // final authVM = Provider.of<AuthViewModel>(context, listen: false);
              // return InicialViewModel(authVM.user!); // Exemplo
              return InicialViewModel(); // <<< NOME CORRIGIDO (e como estava no seu código)
            },
            child: const TelaInicial(),
          );
        }
        // Se status é authenticated mas user é null (estado inconsistente),
        // melhor redirecionar para login usando nosso helper.
        // print("[Wrapper] Authenticated mas user é null (inconsistent) -> TelaLogin via helper");
        return _buildLoginScreen(context);

      case AuthStatus.unauthenticated:
      case AuthStatus.error: // Tratar erro da mesma forma que unauthenticated
      // print("[Wrapper] Status: Unauthenticated or Error -> TelaLogin via helper");
        return _buildLoginScreen(context);

    // Não é estritamente necessário um 'default' se todos os enums são cobertos,
    // mas pode ser uma boa prática para robustez ou se o enum mudar.
    // default:
    //   print("[Wrapper] Status: Default (unexpected) -> TelaLogin via helper");
    //   return _buildLoginScreen(context);
    }
  }
}
