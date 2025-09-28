// lib/views/tela_login.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart'; // Ainda necessário para o status
import 'package:projeto_integrador2/viewmodels/login_viewmodel.dart'; // Importe o novo ViewModel
import 'tela_cadastro.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função para mostrar SnackBar de erro (passada como callback para o ViewModel)
  void _showErrorSnackBar(String message) {
    if (mounted) { // Garante que a tela ainda existe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // A função _submitForm foi movida para o LoginViewModel
  // Future<void> _submitForm() async { ... }

  @override
  Widget build(BuildContext context) {
    // Obtém o AuthViewModel para o status (para o CircularProgressIndicator)
    final authStatus = context.watch<AuthViewModel>().status;
    // Obtém o LoginViewModel para as ações
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

    return Scaffold(
      body: Container(
        // ... (decoração do container permanece a mesma) ...
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8E6CF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'PetHub',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF388E3C),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  // ... (decoração do container do formulário permanece a mesma) ...
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          // ... (validação e decoração permanecem as mesmas) ...
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            hintText: 'seuemail@exemplo.com',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, insira seu e-mail.';
                            }
                            if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                              return 'Por favor, insira um e-mail válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          // ... (validação e decoração permanecem as mesmas) ...
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira sua senha.';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) { // Chama o método do ViewModel
                            loginViewModel.signInWithEmailAndPassword(
                              formKey: _formKey,
                              email: _emailController.text,
                              password: _passwordController.text,
                              showErrorSnackBar: _showErrorSnackBar,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        if (authStatus == AuthStatus.authenticating)
                          const Center(child: CircularProgressIndicator())
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: () { // Chama o método do ViewModel
                              loginViewModel.signInWithEmailAndPassword(
                                formKey: _formKey,
                                email: _emailController.text,
                                password: _passwordController.text,
                                showErrorSnackBar: _showErrorSnackBar,
                              );
                            },
                            child: const Text('Entrar'),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: SvgPicture.asset(
                            'assets/images/google_logo.svg',
                            height: 30.0,
                            width: 30.0,
                          ),
                          label: const Text('Entrar com Google'),
                          // ... (estilo permanece o mesmo) ...
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          onPressed: authStatus == AuthStatus.authenticating
                              ? null
                              : () { // Chama o método do ViewModel
                            loginViewModel.signInWithGoogle(
                              showErrorSnackBar: _showErrorSnackBar,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const TelaCadastro()),
                            );
                          },
                          child: const Text('Não tem uma conta? Cadastre-se'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

