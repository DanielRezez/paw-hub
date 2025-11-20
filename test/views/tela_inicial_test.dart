// test/views/tela_inicial_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:projeto_integrador2/views/tela_inicial.dart';
import 'package:projeto_integrador2/viewmodels/inicial_viewmodel.dart';

import 'tela_inicial_test.mocks.dart';

@GenerateMocks([InicialViewModel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // helper pra montar a TelaInicial com um ViewModel mockado
  Widget _buildWidgetUnderTest(MockInicialViewModel mockVm) {
    // Provider precisa desses métodos, então já relaxamos eles
    when(mockVm.addListener(any)).thenAnswer((_) {});
    when(mockVm.removeListener(any)).thenAnswer((_) {});
    when(mockVm.dispose()).thenAnswer((_) {});

    return MaterialApp(
      home: ChangeNotifierProvider<InicialViewModel>.value(
        value: mockVm,
        child: const TelaInicial(),
      ),
    );
  }

  testWidgets('Text dos cards exibem strings formatadas do ViewModel',
          (tester) async {
        final mockVm = MockInicialViewModel();

        when(mockVm.selectedIndex).thenReturn(0);

        // Água
        when(mockVm.aguaConsumidaFormatada).thenReturn('50ml');
        when(mockVm.metaAguaFormatada).thenReturn('Meta: 150ml');
        when(mockVm.progressoAgua).thenReturn(0.3);

        // Ração
        when(mockVm.racaoConsumidaFormatada).thenReturn('20g');
        when(mockVm.metaRacaoFormatada).thenReturn('Meta: 60g');
        when(mockVm.progressoRacao).thenReturn(0.33);

        // Próxima refeição
        when(mockVm.proximaRefeicao).thenReturn('12:00');
        when(mockVm.tempoAteProximaRefeicao).thenReturn('Em 1h');

        // Gráfico
        when(mockVm.consumoSemanalSpots).thenReturn(const []);

        await tester.pumpWidget(_buildWidgetUnderTest(mockVm));

        expect(find.text('50ml'), findsOneWidget);
        expect(find.text('Meta: 150ml'), findsOneWidget);
        expect(find.text('20g'), findsOneWidget);
        expect(find.text('Meta: 60g'), findsOneWidget);
        expect(find.text('12:00'), findsOneWidget);
        expect(find.text('Em 1h'), findsOneWidget);
      });

  testWidgets(
      'LinearProgressIndicators refletem os valores de progresso do ViewModel',
          (tester) async {
        final mockVm = MockInicialViewModel();

        when(mockVm.selectedIndex).thenReturn(0);

        // Água 0%, Ração 50%
        when(mockVm.aguaConsumidaFormatada).thenReturn('0ml');
        when(mockVm.metaAguaFormatada).thenReturn('Meta: 100ml');
        when(mockVm.progressoAgua).thenReturn(0.0);

        when(mockVm.racaoConsumidaFormatada).thenReturn('25g');
        when(mockVm.metaRacaoFormatada).thenReturn('Meta: 50g');
        when(mockVm.progressoRacao).thenReturn(0.5);

        when(mockVm.proximaRefeicao).thenReturn('--:--');
        when(mockVm.tempoAteProximaRefeicao).thenReturn('');
        when(mockVm.consumoSemanalSpots).thenReturn(const []);

        await tester.pumpWidget(_buildWidgetUnderTest(mockVm));

        final indicators = tester
            .widgetList<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        )
            .toList();

        expect(indicators.length, 2);
        expect(indicators[0].value, 0.0); // água
        expect(indicators[1].value, 0.5); // ração
      });

  testWidgets('LineChart é renderizado quando há dados no ViewModel',
          (tester) async {
        final mockVm = MockInicialViewModel();

        when(mockVm.selectedIndex).thenReturn(0);

        // stubs mínimos pra tela montar
        when(mockVm.aguaConsumidaFormatada).thenReturn('0ml');
        when(mockVm.metaAguaFormatada).thenReturn('Meta: 0ml');
        when(mockVm.progressoAgua).thenReturn(0.0);
        when(mockVm.racaoConsumidaFormatada).thenReturn('0g');
        when(mockVm.metaRacaoFormatada).thenReturn('Meta: 0g');
        when(mockVm.progressoRacao).thenReturn(0.0);
        when(mockVm.proximaRefeicao).thenReturn('--:--');
        when(mockVm.tempoAteProximaRefeicao).thenReturn('');

        when(mockVm.consumoSemanalSpots).thenReturn(const [
          FlSpot(0, 100),
          FlSpot(1, 200),
        ]);

        await tester.pumpWidget(_buildWidgetUnderTest(mockVm));

        expect(find.byType(LineChart), findsOneWidget);
      });

  testWidgets(
      'toque em um BottomNavigationBarItem chama onItemTapped no ViewModel',
          (tester) async {
        final mockVm = MockInicialViewModel();

        when(mockVm.selectedIndex).thenReturn(0);

        // stubs mínimos pra buildar
        when(mockVm.aguaConsumidaFormatada).thenReturn('0ml');
        when(mockVm.metaAguaFormatada).thenReturn('Meta: 0ml');
        when(mockVm.progressoAgua).thenReturn(0.0);
        when(mockVm.racaoConsumidaFormatada).thenReturn('0g');
        when(mockVm.metaRacaoFormatada).thenReturn('Meta: 0g');
        when(mockVm.progressoRacao).thenReturn(0.0);
        when(mockVm.proximaRefeicao).thenReturn('--:--');
        when(mockVm.tempoAteProximaRefeicao).thenReturn('');
        when(mockVm.consumoSemanalSpots).thenReturn(const []);

        await tester.pumpWidget(_buildWidgetUnderTest(mockVm));

        // clica no item "Agenda" (ícone de calendário – índice 1)
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        verify(mockVm.onItemTapped(1, any)).called(1);
      });
}
