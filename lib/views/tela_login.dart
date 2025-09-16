import 'package:flutter/material.dart';
import 'package:projeto_integrador2/viewmodels/login_viewmodel.dart';

class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key}); // construtor const (opcional, mas recomendado)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("Aqui vai o formulário de login 😎"),
      ),
    );
  }
}
