import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:projeto_integrador2/viewmodels/configuracoes_viewmodel.dart';

class TelaConta extends StatelessWidget {
  const TelaConta({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ConfiguracoesViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conta'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Foto do usuário
          Center(
            child: GestureDetector(
              onTap: () async {
                await viewModel.trocarFoto();
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: viewModel.fotoUsuario != null
                    ? FileImage(viewModel.fotoUsuario!) as ImageProvider
                    : const AssetImage('assets/images/default_user.png'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Username
          ListTile(
            title: const Text('Trocar username'),
            subtitle: Text(viewModel.username ?? 'Sem nome'),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final novoNome = await _mostrarDialogoTexto(
                  context, 'Novo username', viewModel.username ?? '');
              if (novoNome != null && novoNome.isNotEmpty) {
                await viewModel.trocarUsername(novoNome);
              }
            },
          ),
          const Divider(),
          // Trocar senha
          ListTile(
            title: const Text('Trocar senha'),
            trailing: const Icon(Icons.lock),
            onTap: () async {
              await viewModel.trocarSenha();
            },
          ),
          const Divider(),
          // Logout
          ListTile(
            title: const Text('Sair da conta'),
            trailing: const Icon(Icons.logout),
            onTap: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar Logout'),
                  content: const Text('Você tem certeza que deseja sair?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Sair',
                          style: TextStyle(color: Colors.red.shade700),
                        )),
                  ],
                ),
              );

              if (confirmar == true) {
                await viewModel.logout();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _mostrarDialogoTexto(
      BuildContext context, String titulo, String valorAtual) {
    final controller = TextEditingController(text: valorAtual);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: titulo),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Salvar')),
        ],
      ),
    );
  }
}
