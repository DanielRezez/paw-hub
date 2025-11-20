// test/viewmodels/auth_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';
import 'package:projeto_integrador2/services/i_auth_service.dart';
import '../mocks/i_auth_service_mock.mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  late MockIAuthService mockAuthService;
  late AuthViewModel viewModel;

  setUp(() {
    mockAuthService = MockIAuthService();

    // Inicializa a stream vazia
    when(mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream<User?>.empty());

    // Current user inicial
    when(mockAuthService.currentUser).thenReturn(null);

    viewModel = AuthViewModel(mockAuthService);
  });

  group('signIn', () {
    test('login com sucesso', () async {
      final user = FakeUser(email: 'test@test.com');

      // Simula signIn retornando usuário
      when(mockAuthService.signIn(any, any)).thenAnswer((_) async => user);

      // Faz a stream emitir o usuário
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream<User?>.fromIterable([user]));

      final result = await viewModel.signIn('test@test.com', '123456');

      // Espera listener da stream atualizar status
      await Future.delayed(Duration.zero);

      expect(result, true);
      expect(viewModel.status, AuthStatus.authenticated);
      expect(viewModel.user, user);
      expect(viewModel.errorMessage, null);
    });

    test('login falha', () async {
      when(mockAuthService.signIn(any, any))
          .thenThrow(Exception('Usuário ou senha incorretos'));

      final result = await viewModel.signIn('test@test.com', '123456');

      await Future.delayed(Duration.zero);

      expect(result, false);
      expect(viewModel.status, AuthStatus.error);
      expect(viewModel.user, null);
      expect(viewModel.errorMessage, isNotNull);
    });
  });

  group('signUp', () {
    test('cadastro com sucesso', () async {
      final user = FakeUser(email: 'novo@test.com');

      when(mockAuthService.signUp(any, any)).thenAnswer((_) async => user);

      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream<User?>.fromIterable([user]));

      final result = await viewModel.signUp('novo@test.com', '123456');

      await Future.delayed(Duration.zero);

      expect(result, true);
      expect(viewModel.status, AuthStatus.authenticated);
      expect(viewModel.user, user);
      expect(viewModel.errorMessage, null);
    });

    test('cadastro falha', () async {
      when(mockAuthService.signUp(any, any))
          .thenThrow(Exception('E-mail inválido'));

      final result = await viewModel.signUp('novo@test.com', '123456');

      await Future.delayed(Duration.zero);

      expect(result, false);
      expect(viewModel.status, AuthStatus.error);
      expect(viewModel.user, null);
      expect(viewModel.errorMessage, isNotNull);
    });
  });

  group('signInWithGoogle', () {
    test('login com Google sucesso', () async {
      final user = FakeUser(email: 'google@test.com');
      when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => user);

      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream<User?>.fromIterable([user]));

      final result = await viewModel.signInWithGoogle();
      await Future.delayed(Duration.zero);

      expect(result, true);
      expect(viewModel.status, AuthStatus.authenticated);
      expect(viewModel.user, user);
      expect(viewModel.errorMessage, null);
    });

    test('login com Google falha', () async {
      when(mockAuthService.signInWithGoogle())
          .thenThrow(Exception('Erro no Google SignIn'));

      final result = await viewModel.signInWithGoogle();
      await Future.delayed(Duration.zero);

      expect(result, false);
      expect(viewModel.status, AuthStatus.error);
      expect(viewModel.user, null);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('login com Google cancelado', () async {
      when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => null);

      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream<User?>.fromIterable([null]));

      final result = await viewModel.signInWithGoogle();
      await Future.delayed(Duration.zero);

      expect(result, false);
      expect(viewModel.status, AuthStatus.unauthenticated);
      expect(viewModel.user, null);
      expect(viewModel.errorMessage, null);
    });
  });

  group('signOutAll', () {
    test('logout sucesso', () async {
      await viewModel.signOutAll();
      verify(mockAuthService.signOut()).called(1);
      expect(viewModel.status, AuthStatus.unauthenticated);
      expect(viewModel.user, null);
      expect(viewModel.errorMessage, null);
    });

    test('logout falha', () async {
      when(mockAuthService.signOut()).thenThrow(Exception('Erro no logout'));

      await viewModel.signOutAll();

      expect(viewModel.status, AuthStatus.error);
      expect(viewModel.user, null);
      expect(viewModel.errorMessage, isNotNull);
    });
  });
}

// Fake User para testes
class FakeUser implements User {
  @override
  final String? email;

  FakeUser({this.email});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
