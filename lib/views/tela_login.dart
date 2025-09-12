// lib/views/tela_login.dart
import 'package:flutter/material.dart';
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
    // Ouve o status do AuthViewModel para mostrar o loading ou o botão
    final authStatus = context.watch<AuthViewModel>().status;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login - PawHub'),
        automaticallyImplyLeading: false, // Remove o botão de voltar, já que é a tela inicial para não logados
      ),
      body: Center( // Centraliza o conteúdo na tela
        child: SingleChildScrollView( // Permite rolar se o conteúdo for maior que a tela
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Associa a chave ao formulário
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
              crossAxisAlignment: CrossAxisAlignment.stretch, // Estica os filhos horizontalmente
              children: <Widget>[
                // TODO: Adicionar um logo do PawHub aqui seria legal!
                // Image.asset('assets/images/pawhub_logo.png', height: 100),
                // SizedBox(height: 48),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'seuemail@exemplo.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next, // Pula para o próximo campo
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira seu e-mail.';
                    }
                    // Validação simples de e-mail
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null; // Nulo significa que é válido
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                    // TODO: Adicionar um botão de mostrar/esconder senha seria uma boa melhoria
                  ),
                  obscureText: true, // Esconde a senha
                  textInputAction: TextInputAction.done, // Indica que o formulário terminou
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha.';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submitForm(), // Permite submeter com o "enter" do teclado
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
                    onPressed: _submitForm, // Chama a função de submissão
                    child: const Text('Entrar'),
                  ),
                const SizedBox(height: 16), // Espaçamento
                ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/images/google_logo_light.png', // VOCÊ PRECISARÁ ADICIONAR ESTA IMAGEM
                    height: 24.0,
                    width: 24.0,
                  ),
                  label: const Text('Entrar com Google'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black87, backgroundColor: Colors.white, // Cores típicas para botão Google
                    minimumSize: const Size(double.infinity, 50), // Faz o botão ocupar a largura
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  onPressed: authStatus == AuthStatus.authenticating
                      ? null // Desabilita o botão enquanto estiver autenticando
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
                    // Se o login deu certo, o Wrapper cuidará da navegação.
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
      ),
    );
  }
}


