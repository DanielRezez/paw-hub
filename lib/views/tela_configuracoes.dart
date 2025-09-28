// lib/views/tela_configuracoes.dart
import 'package:projeto_integrador2/utils/app_exports.dart'; // Import centralizado

class TelaConfiguracoes extends StatelessWidget {
  const TelaConfiguracoes({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ConfiguracoesViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
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
              value: viewModel.isDarkMode,
              onChanged: (value) => viewModel.toggleTheme(value),
            ),
          ),

          const Divider(),

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
              value: viewModel.notificationsEnabled,
              onChanged: (value) => viewModel.toggleNotifications(value),
            ),
          ),

          const Divider(),

          ListTile(
            title: const Text('Sair da conta'),
            trailing: const Icon(Icons.logout),
            onTap: () async {
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
                await viewModel.logout(); // A navegação deve ser tratada pelo Wrapper
                                          // ao observar a mudança no AuthViewModel
                if (context.mounted) { // Checagem adicional
                   Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
