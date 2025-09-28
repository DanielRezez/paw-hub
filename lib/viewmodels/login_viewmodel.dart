// lib/viewmodels/login_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';

class LoginViewModel with ChangeNotifier {
  final AuthViewModel _authViewModel;

  LoginViewModel(this._authViewModel);

  // Poderíamos ter um estado de isLoading específico aqui se necessário,
  // mas por enquanto vamos depender do AuthViewModel.status
  // bool _isLoading = false;
  // bool get isLoading => _isLoading;

  // Função para lidar com o login por e-mail e senha
  Future<void> signInWithEmailAndPassword({
    required GlobalKey<FormState> formKey,
    required String email,
    required String password,
    required Function(String) showErrorSnackBar, // Callback para mostrar SnackBar na View
  }) async {
    if (formKey.currentState!.validate()) {
      // _isLoading = true; // Se tivéssemos isLoading local
      // notifyListeners();

      bool success = await _authViewModel.signIn(email, password);

      if (!success && _authViewModel.errorMessage != null) {
        showErrorSnackBar(_authViewModel.errorMessage!);
      }

      // _isLoading = false; // Se tivéssemos isLoading local
      // Se não estivermos usando isLoading local, o AuthViewModel.status já notifica
      // e a view pode depender dele para o CircularProgressIndicator.
      // Se a view não ouvir AuthViewModel diretamente para o status, precisamos notificar.
      // notifyListeners();
    }
  }

  // Função para lidar com o login com Google
  Future<void> signInWithGoogle({
    required Function(String) showErrorSnackBar, // Callback para mostrar SnackBar na View
  }) async {
    // _isLoading = true; // Se tivéssemos isLoading local
    // notifyListeners();

    bool success = await _authViewModel.signInWithGoogle();

    if (!success && _authViewModel.errorMessage != null) {
      showErrorSnackBar(_authViewModel.errorMessage!);
    }

    // _isLoading = false; // Se tivéssemos isLoading local
    // notifyListeners();
  }
}

