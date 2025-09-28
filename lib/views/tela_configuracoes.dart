// lib/views/tela_configuracoes.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/viewmodels/configuracoes_viewmodel.dart';

// Remova StatefulWidget se não precisar mais de estado local complexo
// class TelaConfiguracoes extends StatefulWidget {
//   @override
//   _TelaConfiguracoesState createState() => _TelaConfiguracoesState();
// }
// class _TelaConfiguracoesState extends State<TelaConfiguracoes> {

class TelaConfiguracoes extends StatelessWidget { // Transformado em StatelessWidget
  const TelaConfiguracoes({super.key}); // Adicione construtor const

  // bool isDarkMode = false; // MOVIDO PARA VIEWMODEL
  // bool notificationsEnabled = true; // MOVIDO PARA VIEWMODEL

  // void toggleTheme(bool value) { // MOVIDO PARA VIEWMODEL
  // }

  // void toggleNotifications(bool value) { // MOVIDO PARA VIEWMODEL
  // }

  // void logout() { // MOVIDO PARA VIEWMODEL
  // }

  @override
  Widget build(BuildContext context) {
    // Obtenha a instância do ViewModel
    final viewModel = Provider.of<ConfiguracoesViewModel>(context);
    // Para ações que não precisam reconstruir a UI ao serem chamadas:
    // final viewModelActions = Provider.of<ConfiguracoesViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        // A cor do AppBar agora pode ser controlada pelo tema geral do app,
        // que por sua vez seria influenciado pelo estado isDarkMode do ViewModel
        // ou de um ThemeProvider dedicado.
        // backgroundColor: viewModel.isDarkMode ? Colors.grey[900] : Colors.blue,
      ),
      body: ListView(
        children: [
          // Seção: Aparência
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Aparência',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            title: const Text('Tema escuro'),
            trailing: Switch(
              value: viewModel.isDarkMode, // LÊ DO VIEWMODEL
              onChanged: (value) => viewModel.toggleTheme(value), // CHAMA O VIEWMODEL
            ),
          ),

          const Divider(),

          // Seção: Notificações
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Notificações',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            title: const Text('Notificações push'),
            trailing: Switch(
              value: viewModel.notificationsEnabled, // LÊ DO VIEWMODEL
              onChanged: (value) => viewModel.toggleNotifications(value), // CHAMA O VIEWMODEL
            ),
          ),

          const Divider(),

          ListTile(
            title: const Text('Sair da conta'),
            trailing: const Icon(Icons.logout),
            onTap: () async { // Adicione async se o método do viewModel for async
              // Mostrar diálogo de confirmação (pode ser movido para o ViewModel também, se preferir)
              final bool? confirmarLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Confirmar Logout'),
                    content: const Text('Você tem certeza que deseja sair?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text('Sair', style: TextStyle(color: Colors.red.shade700)),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (confirmarLogout == true) {
                await viewModel.logout();
                // Remove todas as telas da pilha até a primeira (Wrapper)
                Navigator.of(context).popUntil((route) => route.isFirst);

              }
            },
          ),
        ],
      ),
    );
  }
}
