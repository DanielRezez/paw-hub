// lib/views/tela_login.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'tela_cadastro.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  // Chave para identificar e validar nosso formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para pegar o texto dos campos de e-mail e senha
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // É importante limpar os controladores quando a tela não for mais usada
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função chamada quando o botão de "Entrar" é pressionado
  Future<void> _submitForm() async {
    // Primeiro, verifica se o formulário é válido (campos preenchidos corretamente)
    if (_formKey.currentState!.validate()) {
      // Pega a instância do AuthViewModel (sem ouvir por atualizações aqui, só para chamar a função)
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      // Chama a função de signIn do ViewModel
      bool success = await authViewModel.signIn(
        _emailController.text,
        _passwordController.text,
      );

      // Se o login NÃO deu certo E há uma mensagem de erro E a tela ainda existe
      if (!success && authViewModel.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      // Se o login deu certo, o Wrapper cuidará de navegar para a TelaInicial.
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthViewModel>().status;

    return Scaffold(
      body: Container(
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
                    color: Color(0xFF388E3C), // Verde escuro para contraste
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24.0),
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
                        // Campos de e-mail e senha
                        TextFormField(
                          controller: _emailController,
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
                          onFieldSubmitted: (_) => _submitForm(),
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
                            onPressed: _submitForm,
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
                              : () async {
                            final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                            bool success = await authViewModel.signInWithGoogle();
                            if (!success && authViewModel.errorMessage != null && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authViewModel.errorMessage!),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
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
