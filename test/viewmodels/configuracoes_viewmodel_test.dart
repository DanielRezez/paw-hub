import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:projeto_integrador2/viewmodels/configuracoes_viewmodel.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';

// Mock gerado automaticamente
import '../mocks/auth_viewmodel.mocks.dart';

void main() {
  late MockAuthViewModel mockAuth;
  late ConfiguracoesViewModel viewModel;

  Future<ConfiguracoesViewModel> createViewModel() async {
    final vm = ConfiguracoesViewModel(mockAuth);
    await Future.delayed(Duration.zero);
    return vm;
  }

  setUp(() {
    // Define valores iniciais do SharedPreferences
    SharedPreferences.setMockInitialValues({
      kDarkModePrefKey: false,
      kNotificationsEnabledPrefKey: true,
    });

    mockAuth = MockAuthViewModel();
  });

  group('toggleNotifications', () {
    test('deve alterar notificationsEnabled e salvar no SharedPreferences', () async {
      viewModel = await createViewModel();

      expect(viewModel.notificationsEnabled, true);

      await viewModel.toggleNotifications(false);
      expect(viewModel.notificationsEnabled, false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kNotificationsEnabledPrefKey), false);
    });
  });

  group('toggleTheme', () {
    test('deve alterar isDarkMode e salvar no SharedPreferences', () async {
      viewModel = await createViewModel();

      expect(viewModel.isDarkMode, false);

      await viewModel.toggleTheme(true);
      expect(viewModel.isDarkMode, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kDarkModePrefKey), true);
    });
  });

  group('logout', () {
    test('deve chamar signOutAll() no AuthViewModel', () async {
      when(mockAuth.signOutAll()).thenAnswer((_) async => Future.value());

      viewModel = await createViewModel();

      await viewModel.logout();

      verify(mockAuth.signOutAll()).called(1);
    });
  });

  group('_loadPreferences', () {
    test('deve carregar os valores iniciais do SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        kDarkModePrefKey: true,
        kNotificationsEnabledPrefKey: false,
      });

      viewModel = await createViewModel();

      expect(viewModel.isDarkMode, true);
      expect(viewModel.notificationsEnabled, false);
    });
  });
}
