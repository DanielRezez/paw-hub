// test/views/tela_cadastro_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks/auth_viewmodel.mocks.dart';
import '../mocks/login.mocks.mocks.dart' hide MockAuthViewModel; // MockAuthViewModel
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';
import 'package:projeto_integrador2/views/tela_cadastro.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpTelaCadastro(
      WidgetTester tester, {
        required MockAuthViewModel mockAuth,
      }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthViewModel>.value(
          value: mockAuth,
          child: const TelaCadastro(),
        ),
      ),
    );
    await tester.pump(); // inicial
  }

  // Finders usando rótulos de acessibilidade (derivados de labelText)
  Finder emailField() => find.bySemanticsLabel('E-mail');
  Finder passwordField() => find.bySemanticsLabel('Senha');
  Finder confirmPasswordField() => find.bySemanticsLabel('Confirme a Senha');
  Finder cadastrarButton() => find.text('Cadastrar');

  group('TelaCadastro - Validação do formulário', () {
    testWidgets('Mostra erro quando confirmação de senha não coincide e não chama signUp', (tester) async {
      final mockAuth = MockAuthViewModel();
      when(mockAuth.status).thenReturn(AuthStatus.unauthenticated);

      await pumpTelaCadastro(tester, mockAuth: mockAuth);

      expect(emailField(), findsOneWidget);
      expect(passwordField(), findsOneWidget);
      expect(confirmPasswordField(), findsOneWidget);
      expect(cadastrarButton(), findsOneWidget);

      await tester.enterText(emailField(), 'novo@teste.com');
      await tester.enterText(passwordField(), '123456');
      await tester.enterText(confirmPasswordField(), 'diferente');

      await tester.tap(cadastrarButton());
      await tester.pump();

      expect(find.text('As senhas não coincidem.'), findsOneWidget);
      verifyNever(mockAuth.signUp(any, any));
    });

    testWidgets('Mostra erro quando e-mail é inválido e não chama signUp', (tester) async {
      final mockAuth = MockAuthViewModel();
      when(mockAuth.status).thenReturn(AuthStatus.unauthenticated);

      await pumpTelaCadastro(tester, mockAuth: mockAuth);

      await tester.enterText(emailField(), 'invalido');
      await tester.enterText(passwordField(), '123456');
      await tester.enterText(confirmPasswordField(), '123456');

      await tester.tap(cadastrarButton());
      await tester.pump();

      expect(find.text('Por favor, insira um e-mail válido.'), findsOneWidget);
      verifyNever(mockAuth.signUp(any, any));
    });

    testWidgets('Mostra erro quando senha tem menos de 6 caracteres e não chama signUp', (tester) async {
      final mockAuth = MockAuthViewModel();
      when(mockAuth.status).thenReturn(AuthStatus.unauthenticated);

      await pumpTelaCadastro(tester, mockAuth: mockAuth);

      await tester.enterText(emailField(), 'novo@teste.com');
      await tester.enterText(passwordField(), '123'); // curta
      await tester.enterText(confirmPasswordField(), '123');

      await tester.tap(cadastrarButton());
      await tester.pump();

      expect(find.text('A senha deve ter pelo menos 6 caracteres.'), findsOneWidget);
      verifyNever(mockAuth.signUp(any, any));
    });
  });

  group('TelaCadastro - Ação do botão "Cadastrar"', () {
    testWidgets('Clique em "Cadastrar" chama signUp no AuthViewModel quando o formulário é válido', (tester) async {
      final mockAuth = MockAuthViewModel();
      when(mockAuth.status).thenReturn(AuthStatus.unauthenticated);
      when(mockAuth.signUp('novo@teste.com', '123456')).thenAnswer((_) async => true);
      when(mockAuth.status).thenReturn(AuthStatus.authenticated);

      await pumpTelaCadastro(tester, mockAuth: mockAuth);

      await tester.enterText(emailField(), 'novo@teste.com');
      await tester.enterText(passwordField(), '123456');
      await tester.enterText(confirmPasswordField(), '123456');

      await tester.tap(cadastrarButton());
      await tester.pump();

      verify(mockAuth.signUp('novo@teste.com', '123456')).called(1);
      expect(find.text('Cadastro realizado com sucesso! Faça o login.'), findsOneWidget);
    });

    testWidgets('Quando signUp falha e existe errorMessage, mostra SnackBar de erro', (tester) async {
      final mockAuth = MockAuthViewModel();
      when(mockAuth.status).thenReturn(AuthStatus.unauthenticated);
      when(mockAuth.signUp('novo@teste.com', '123456')).thenAnswer((_) async => false);
      when(mockAuth.errorMessage).thenReturn('Erro ao cadastrar. Tente novamente.');

      await pumpTelaCadastro(tester, mockAuth: mockAuth);

      await tester.enterText(emailField(), 'novo@teste.com');
      await tester.enterText(passwordField(), '123456');
      await tester.enterText(confirmPasswordField(), '123456');

      await tester.tap(cadastrarButton());
      await tester.pump();

      expect(find.text('Erro ao cadastrar. Tente novamente.'), findsOneWidget);
      verify(mockAuth.signUp('novo@teste.com', '123456')).called(1);
    });

    testWidgets('Exibe indicador de progresso quando status é authenticating', (tester) async {
      final mockAuth = MockAuthViewModel();
      when(mockAuth.status).thenReturn(AuthStatus.authenticating);

      await pumpTelaCadastro(tester, mockAuth: mockAuth);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(cadastrarButton(), findsNothing);
    });
  });
}
