// lib/viewmodels/auth_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Estados possíveis da autenticação
enum AuthStatus {
  uninitialized,    // Ainda não verificamos se há usuário logado
  authenticated,    // Usuário está logado
  authenticating,   // Tentando logar ou cadastrar
  unauthenticated,  // Não há usuário logado
  error             // Ocorreu um erro na autenticação
}

class AuthViewModel with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Nossa "ponte" com o Firebase Auth
  User? _user; // Guardará as informações do usuário logado
  AuthStatus _status = AuthStatus.uninitialized; // Estado inicial
  String? _errorMessage; // Para guardar mensagens de erro

  // Getters para as telas poderem ler essas informações de forma segura
  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  // Construtor: Assim que o AuthViewModel é criado, ele começa a ouvir mudanças no estado de autenticação
  AuthViewModel() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _checkCurrentUser(); // Verifica se já existe um usuário logado ao iniciar o app
  }

  // Verifica se já tem um usuário logado quando o app inicia
  Future<void> _checkCurrentUser() async {
    _user = _auth.currentUser; // Pega o usuário atual do Firebase
    _status = _user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners(); // Avisa as telas que algo mudou
  }

  // Esta função é chamada automaticamente pelo Firebase quando o usuário faz login ou logout
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) { // Se não há usuário no Firebase
      _user = null;
      _status = AuthStatus.unauthenticated;
    } else { // Se há um usuário no Firebase
      _user = firebaseUser;
      _status = AuthStatus.authenticated;
    }
    _errorMessage = null; // Limpa qualquer erro anterior
    notifyListeners(); // Avisa as telas
  }

  // Função para CADASTRAR um novo usuário
  Future<bool> signUp(String email, String password) async {
    _status = AuthStatus.authenticating; // Avisa que estamos "autenticando"
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(), // .trim() remove espaços em branco extras
        password: password.trim(),
      );
      // Se chegou aqui, o cadastro deu certo. O _onAuthStateChanged será chamado.
      return true;
    } on FirebaseAuthException catch (e) { // Se deu um erro específico do Firebase Auth
      _user = null;
      _status = AuthStatus.error;
      _errorMessage = _mapAuthErrorToString(e); // Transforma o erro técnico em mensagem amigável
      notifyListeners();
      return false;
    } catch (e) { // Se deu qualquer outro tipo de erro
      _user = null;
      _status = AuthStatus.error;
      _errorMessage = "Ocorreu um erro inesperado ao tentar cadastrar.";
      notifyListeners();
      return false;
    }
  }

  // Função para FAZER LOGIN de um usuário existente
  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Se chegou aqui, o login deu certo. O _onAuthStateChanged será chamado.
      return true;
    } on FirebaseAuthException catch (e) {
      _user = null;
      _status = AuthStatus.error;
      _errorMessage = _mapAuthErrorToString(e);
      notifyListeners();
      return false;
    } catch (e) {
      _user = null;
      _status = AuthStatus.error;
      _errorMessage = "Ocorreu um erro inesperado ao tentar fazer login.";
      notifyListeners();
      return false;
    }
  }

  // Função para FAZER LOGOUT (sair)
  Future<void> signOut() async {
    await _auth.signOut();
    // O _onAuthStateChanged será chamado automaticamente.
  }

  // Função auxiliar para transformar erros técnicos em mensagens amigáveis
  String _mapAuthErrorToString(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'A senha fornecida é muito fraca.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'user-not-found':
        return 'Usuário não encontrado com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'user-disabled':
        return 'Este usuário foi desabilitado.';
      default:
        return 'Ocorreu um erro. Tente novamente.';
    }
  }

  // Função para FAZER LOGIN COM GOOGLE
  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Iniciar o fluxo de login do Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Se o usuário cancelou o fluxo de login do Google
      if (googleUser == null) {
        _status = AuthStatus.unauthenticated; // Ou manter o status anterior, dependendo da sua lógica
        notifyListeners();
        return false;
      }

      // 2. Obter os detalhes de autenticação do Google (tokens)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Criar uma credencial do Firebase com os tokens do Google
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Fazer login no Firebase com a credencial do Google
      await _auth.signInWithCredential(credential);

      // Se chegou aqui, o login com Google e Firebase deu certo.
      // O _onAuthStateChanged será chamado automaticamente pelo listener que já temos,
      // atualizando _user e _status para AuthStatus.authenticated.
      return true;

    } on FirebaseAuthException catch (e) { // Erros específicos do Firebase
      _user = null; // Garante que o usuário seja nulo em caso de erro
      _status = AuthStatus.error;
      if (e.code == 'account-exists-with-different-credential') {
        _errorMessage = 'Este e-mail já está associado a outro método de login. Tente o método original.';
      } else {
        _errorMessage = _mapAuthErrorToString(e); // Reutiliza nosso mapeador de erros
      }
      notifyListeners();
      return false;
    } catch (e) { // Outros erros (ex: problema de rede, erro no plugin google_sign_in)
      _user = null;
      _status = AuthStatus.error;
      _errorMessage = "Ocorreu um erro inesperado ao tentar fazer login com o Google.";
      print("Erro no signInWithGoogle: $e"); // Ajuda no debug
      notifyListeners();
      return false;
    }
  }
}

