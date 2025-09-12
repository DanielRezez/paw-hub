// lib/views/tela_inicial.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    // Pega o usuário do AuthViewModel para mostrar alguma informação (opcional)
    final user = Provider.of<AuthViewModel>(context, listen: false).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PawHub - Bem-vindo!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              // Chama a função de signOut do ViewModel
              await Provider.of<AuthViewModel>(context, listen: false).signOut();
              // O Wrapper cuidará de navegar de volta para a TelaLogin.
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Você está logado no PawHub!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (user != null && user.email != null)
              Text('Seu e-mail: ${user.email}'),
            // TODO: Adicione o conteúdo principal do seu app aqui!
          ],
        ),
      ),
    );
  }
}


