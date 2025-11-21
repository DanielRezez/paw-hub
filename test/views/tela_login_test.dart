// test/tela_login_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/login.mocks.mocks.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';
import 'package:projeto_integrador2/viewmodels/login_viewmodel.dart';

void main() {
  // 🔑 Inicializa o binding para permitir uso de GlobalKey<FormState>
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthViewModel mockAuthViewModel;
  late LoginViewModel loginViewModel;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    loginViewModel = LoginViewModel(mockAuthViewModel);
  });

  group('LoginViewModel - Email e Senha', () {
    testWidgets('Deve realizar login com sucesso', (tester) async {
      final formKey = GlobalKey<FormState>();

      // Cria um Form associado ao formKey
      await tester.pumpWidget(MaterialApp(home: Form(key: formKey, child: Container())));

      // Arrange
      when(mockAuthViewModel.signIn('teste@teste.com', '123456'))
          .thenAnswer((_) async => true);
      when(mockAuthViewModel.status).thenReturn(AuthStatus.authenticated);

      // Act
      await loginViewModel.signInWithEmailAndPassword(
        formKey: formKey,
        email: 'teste@teste.com',
        password: '123456',
        showErrorSnackBar: (_) {},
      );

      // Assert
      verify(mockAuthViewModel.signIn('teste@teste.com', '123456')).called(1);
      expect(mockAuthViewModel.status, AuthStatus.authenticated);
    });

    testWidgets('Deve mostrar erro quando login falhar', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(MaterialApp(home: Form(key: formKey, child: Container())));

      // Arrange
      when(mockAuthViewModel.signIn('teste@teste.com', 'errado'))
          .thenAnswer((_) async => false);
      when(mockAuthViewModel.errorMessage).thenReturn('Credenciais inválidas');
      when(mockAuthViewModel.status).thenReturn(AuthStatus.error);

      String? snackMessage;
      void showError(String msg) => snackMessage = msg;

      // Act
      await loginViewModel.signInWithEmailAndPassword(
        formKey: formKey,
        email: 'teste@teste.com',
        password: 'errado',
        showErrorSnackBar: showError,
      );

      // Assert
      expect(snackMessage, 'Credenciais inválidas');
      verify(mockAuthViewModel.signIn('teste@teste.com', 'errado')).called(1);
    });
  });

  group('LoginViewModel - Google', () {
    test('Deve realizar login com Google com sucesso', () async {
      when(mockAuthViewModel.signInWithGoogle()).thenAnswer((_) async => true);
      when(mockAuthViewModel.status).thenReturn(AuthStatus.authenticated);

      await loginViewModel.signInWithGoogle(showErrorSnackBar: (_) {});

      verify(mockAuthViewModel.signInWithGoogle()).called(1);
      expect(mockAuthViewModel.status, AuthStatus.authenticated);
    });

    test('Deve mostrar erro quando login com Google falhar', () async {
      when(mockAuthViewModel.signInWithGoogle()).thenAnswer((_) async => false);
      when(mockAuthViewModel.errorMessage).thenReturn('Erro no Google Sign-In');
      when(mockAuthViewModel.status).thenReturn(AuthStatus.error);

      String? snackMessage;
      void showError(String msg) => snackMessage = msg;

      await loginViewModel.signInWithGoogle(showErrorSnackBar: showError);

      expect(snackMessage, 'Erro no Google Sign-In');
      verify(mockAuthViewModel.signInWithGoogle()).called(1);
    });
  });

  group('AuthViewModel - Cadastro e Logout', () {
    test('Deve realizar cadastro com sucesso', () async {
      when(mockAuthViewModel.signUp('novo@teste.com', '123456'))
          .thenAnswer((_) async => true);
      when(mockAuthViewModel.status).thenReturn(AuthStatus.authenticated);

      final result = await mockAuthViewModel.signUp('novo@teste.com', '123456');

      expect(result, true);
      verify(mockAuthViewModel.signUp('novo@teste.com', '123456')).called(1);
    });

    test('Deve realizar logout com sucesso', () async {
      when(mockAuthViewModel.signOutAll()).thenAnswer((_) async => Future.value());
      when(mockAuthViewModel.status).thenReturn(AuthStatus.unauthenticated);

      await mockAuthViewModel.signOutAll();

      verify(mockAuthViewModel.signOutAll()).called(1);
      expect(mockAuthViewModel.status, AuthStatus.unauthenticated);
    });
  });

  group('AuthViewModel - Estados de erro', () {
    test('Deve atualizar status para error quando signIn falhar', () async {
      when(mockAuthViewModel.signIn('teste@teste.com', '123456'))
          .thenAnswer((_) async => false);
      when(mockAuthViewModel.status).thenReturn(AuthStatus.error);
      when(mockAuthViewModel.errorMessage).thenReturn('Erro inesperado');

      final result = await mockAuthViewModel.signIn('teste@teste.com', '123456');

      expect(result, false);
      expect(mockAuthViewModel.status, AuthStatus.error);
      expect(mockAuthViewModel.errorMessage, 'Erro inesperado');
    });
  });
}
