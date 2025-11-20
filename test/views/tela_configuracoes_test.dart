import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:projeto_integrador2/views/tela_configuracoes.dart';
import '../mocks/config_vm.mocks.mocks.dart';

void main() {
  group('TelaConfiguracoes - Testes de Widget com Mockito', () {
    late MockConfiguracoesViewModel mockViewModel;

    Widget createWidgetUnderTest() {
      return ChangeNotifierProvider<MockConfiguracoesViewModel>.value(
        value: mockViewModel,
        child: const MaterialApp(
          home: TelaConfiguracoes(),
        ),
      );
    }

    setUp(() {
      mockViewModel = MockConfiguracoesViewModel();

      // Valores padrão
      when(mockViewModel.isDarkMode).thenReturn(false);
      when(mockViewModel.notificationsEnabled).thenReturn(true);
    });

    testWidgets('Exibe switches com valores iniciais corretos', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final darkSwitch = find.byType(Switch).at(0);
      final notifSwitch = find.byType(Switch).at(1);

      expect(tester.widget<Switch>(darkSwitch).value, false);
      expect(tester.widget<Switch>(notifSwitch).value, true);
    });

    testWidgets('Ao clicar no switch de tema chama toggleTheme', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final darkSwitch = find.byType(Switch).at(0);

      await tester.tap(darkSwitch);
      await tester.pumpAndSettle();

      verify(mockViewModel.toggleTheme(any)).called(1);
    });

    testWidgets('Ao clicar no switch de notificações chama toggleNotifications', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final notifSwitch = find.byType(Switch).at(1);

      await tester.tap(notifSwitch);
      await tester.pumpAndSettle();

      verify(mockViewModel.toggleNotifications(any)).called(1);
    });

    testWidgets('Dialogo de logout é exibido e logout chamado', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final logoutTile = find.text('Sair da conta');

      // Abre o diálogo
      await tester.tap(logoutTile);
      await tester.pumpAndSettle();

      expect(find.text('Confirmar Logout'), findsOneWidget);

      // Confirmar logout
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      verify(mockViewModel.logout()).called(1);
    });
  });
}
