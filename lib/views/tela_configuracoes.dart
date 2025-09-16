// lib/views/tela_configuracoes.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart'; // Ajuste o caminho se necessário

class TelaConfiguracoes extends StatelessWidget {
  const TelaConfiguracoes({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenha o AuthViewModel para chamar a função signOut
    // Usamos listen: false aqui porque o botão em si não precisa
    // reconstruir se o AuthViewModel mudar. A navegação será tratada
    // pelo Wrapper quando o estado de autenticação mudar.
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        // Se você quiser que o botão de voltar apareça automaticamente,
        // esta tela precisa ser empurrada para a pilha de navegação
        // (ex: Navigator.push(context, MaterialPageRoute(builder: (_) => TelaConfiguracoes())) )
        // Se ela substitui a TelaInicial, você pode querer adicionar um explicitamente:
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      body: ListView( // Usando ListView para o caso de você ter mais configurações
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // ... Suas outras opções de configuração podem vir aqui ...
          // Exemplo:
          // ListTile(
          //   leading: Icon(Icons.person),
          //   title: Text('Perfil'),
          //   onTap: () {
          //     // Navegar para a tela de perfil
          //   },
          // ),
          // ListTile(
          //   leading: Icon(Icons.notifications),
          //   title: Text('Notificações'),
          //   onTap: () {
          //     // Navegar para configurações de notificação
          //   },
          // ),

          const Divider(), // Um divisor visual

          // --- BOTÃO DE LOGOUT ---
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade700),
            title: Text(
              'Sair (Logout)',
              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              // Mostrar um diálogo de confirmação antes de fazer logout
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
                          Navigator.of(dialogContext).pop(false); // Retorna false
                        },
                      ),
                      TextButton(
                        child: Text('Sair', style: TextStyle(color: Colors.red.shade700)),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true); // Retorna true
                        },
                      ),
                    ],
                  );
                },
              );

              // Se o usuário confirmou, então faça o logout
              if (confirmarLogout == true) {
                await authViewModel.signOut();
                // O Wrapper cuidará de redirecionar para a TelaLogin
                // Se a TelaConfiguracoes estiver em uma rota empilhada sobre a TelaInicial,
                // você pode querer desempilhar todas as rotas até a tela de login
                // para evitar que o usuário volte para a tela de configurações com o botão "voltar" do android.
                // No entanto, como o Wrapper já reage à mudança de estado, ele deve
                // substituir a árvore de widgets pela TelaLogin.
                //
                // Se você quiser garantir que todas as telas sejam removidas até a nova raiz (TelaLogin):
                // Navigator.of(context).pushAndRemoveUntil(
                //   MaterialPageRoute(builder: (context) => Wrapper()), // Ou diretamente TelaLogin se o Wrapper já estiver sendo reconstruído
                //   (Route<dynamic> route) => false,
                // );
                // Mas, geralmente, apenas chamar authViewModel.signOut() é suficiente
                // e o Wrapper fará o resto.
              }
            },
          ),
          // --- FIM DO BOTÃO DE LOGOUT ---

          // ... Mais opções de configuração ...
        ],
      ),
    );
  }
}
