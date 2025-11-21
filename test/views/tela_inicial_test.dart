// test/views/tela_inicial_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:projeto_integrador2/viewmodels/inicial_viewmodel.dart';
import 'package:projeto_integrador2/viewmodels/agenda_viewmodel.dart';
import 'package:projeto_integrador2/views/tela_inicial.dart';

import 'tela_inicial_test.mocks.dart';

@GenerateMocks([TelaAgendaViewModel])
void main() {
  late MockTelaAgendaViewModel mockAgenda;
  late InicialViewModel viewModel;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAgenda = MockTelaAgendaViewModel();

    when(mockAgenda.perfilHorarios).thenReturn(<RefeicaoProgramada>[]);
    when(mockAgenda.getProximaRefeicaoEHorario()).thenReturn(null);

    viewModel = InicialViewModel(mockAgenda);
  });

  Widget app(Widget child) {
    return MaterialApp(
      home: ChangeNotifierProvider<InicialViewModel>.value(
        value: viewModel,
        child: child,
      ),
    );
  }

  testWidgets('TelaInicial exibe textos principais', (tester) async {
    await tester.pumpWidget(app(const TelaInicial()));
    await tester.pump(); // garante build final

    expect(find.text('PetHub Monitor'), findsOneWidget);
    expect(find.text('Água Hoje'), findsOneWidget);
    expect(find.text('Ração Hoje'), findsOneWidget);
    expect(find.text('Próxima Refeição'), findsOneWidget);
    expect(find.text('Alertas'), findsOneWidget);
    expect(find.text('Consumo Semanal'), findsOneWidget);
  });

  testWidgets('Card de água abre diálogo', (tester) async {
    await tester.pumpWidget(app(const TelaInicial()));
    await tester.pump();

    await tester.tap(find.text('Água Hoje'));
    await tester.pumpAndSettle();

    expect(find.text('Atualizar água consumida'), findsOneWidget);
  });

  testWidgets('Card de ração abre diálogo', (tester) async {
    await tester.pumpWidget(app(const TelaInicial()));
    await tester.pump();

    await tester.tap(find.text('Ração Hoje'));
    await tester.pumpAndSettle();

    expect(find.text('Atualizar ração consumida'), findsOneWidget);
  });

  testWidgets('BottomNavigationBar contém os 4 itens', (tester) async {
    await tester.pumpWidget(app(const TelaInicial()));
    await tester.pump();

    const labels = ['Visão Geral', 'Agenda', 'Histórico', 'Config'];

    for (final l in labels) {
      expect(find.text(l), findsOneWidget);
    }
  });

  testWidgets('LineChart aparece na tela', (tester) async {
    await tester.pumpWidget(app(const TelaInicial()));
    await tester.pump();

    expect(find.byType(LineChart), findsOneWidget);
  });
}
