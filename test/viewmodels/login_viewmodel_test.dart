import 'package:flutter/material.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';

class LoginViewModel with ChangeNotifier {
  final AuthViewModel _authViewModel;

  LoginViewModel(this._authViewModel);

  /// Login com email e senha
  Future<void> signInWithEmailAndPassword({
    GlobalKey<FormState>? formKey,
    required String email,
    required String password,
    required Function(String) showErrorSnackBar,
  }) async {
    final isValid = formKey?.currentState?.validate() ?? true;

    if (isValid) {
      bool success = await _authViewModel.signIn(email, password);

      if (!success && _authViewModel.errorMessage != null) {
        showErrorSnackBar(_authViewModel.errorMessage!);
      }
    }

  }

  /// Login com Google
  Future<void> signInWithGoogle({
    required Function(String) showErrorSnackBar,
  }) async {
    bool success = await _authViewModel.signInWithGoogle();

    if (!success && _authViewModel.errorMessage != null) {
      showErrorSnackBar(_authViewModel.errorMessage!);
    }

  }
}
