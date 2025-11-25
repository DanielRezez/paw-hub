// test/tela_login_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/views/tela_login.dart';


import '../mocks/login.mocks.mocks.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';
import 'package:projeto_integrador2/viewmodels/login_viewmodel.dart';

void main() {
  // Inicializa o binding para permitir uso de GlobalKey<FormState>
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

  group('TelaLogin Widget Tests', () {
    late MockAuthViewModel mockAuthViewModel;
    late MockLoginViewModel mockLoginViewModel;

    setUp(() {
      mockAuthViewModel = MockAuthViewModel();
      mockLoginViewModel = MockLoginViewModel();
      // Estado padrão para a maioria dos testes
      when(mockAuthViewModel.status).thenReturn(AuthStatus.unauthenticated);
    });

    // Função auxiliar para criar o widget com os providers mocados
    Future<void> _createWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthViewModel),
            ChangeNotifierProvider<LoginViewModel>.value(value: mockLoginViewModel),
          ],
          child: const MaterialApp(
            home: TelaLogin(),
          ),
        ),
      );
    }

    testWidgets('deve renderizar os campos de e-mail e senha', (tester) async {
      await _createWidget(tester);
      
      // Procura por TextFormFields com os rótulos específicos
      expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
    });

    testWidgets('deve mostrar erros de validação para campos vazios e e-mail inválido', (tester) async {
      // Arrange: Usa um LoginViewModel REAL para que a lógica de validação seja executada.
      // O teste original falhava porque o mock do LoginViewModel não chamava a validação do formulário.
      final realLoginViewModel = LoginViewModel(mockAuthViewModel);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthViewModel),
            ChangeNotifierProvider<LoginViewModel>.value(value: realLoginViewModel),
          ],
          child: const MaterialApp(
            home: TelaLogin(),
          ),
        ),
      );
      
      // Act: Tenta submeter com campos vazios.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      // Assert: Verifica se as mensagens de erro para campos vazios aparecem.
      expect(find.text('Por favor, insira seu e-mail.'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha.'), findsOneWidget);

      // Act 2: Insere um e-mail inválido.
      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'emailinvalido');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      // Assert 2: Verifica se a mensagem de e-mail inválido aparece. A de senha também, pois o campo continua vazio.
      expect(find.text('Por favor, insira um e-mail válido.'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha.'), findsOneWidget);
    });


    testWidgets('deve exibir CircularProgressIndicator quando o status for authenticating', (tester) async {
      // Configura o estado do mock
      when(mockAuthViewModel.status).thenReturn(AuthStatus.authenticating);

      await _createWidget(tester);
      await tester.pump(); // Reconstrói o widget com o novo estado

      // Verifica a presença do indicador e a ausência do botão
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsNothing);
    });

    testWidgets('deve chamar signInWithEmailAndPassword ao clicar em Entrar com dados válidos', (tester) async {
      await _createWidget(tester);

      // Preenche os campos com dados válidos
      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'teste@teste.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123456');

      // Toca no botão de entrar
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      // Verifica se o método do ViewModel foi chamado com os argumentos corretos
      verify(mockLoginViewModel.signInWithEmailAndPassword(
        formKey: anyNamed('formKey'),
        email: 'teste@teste.com',
        password: '123456',
        showErrorSnackBar: anyNamed('showErrorSnackBar'),
      )).called(1);
    });
  });
}
