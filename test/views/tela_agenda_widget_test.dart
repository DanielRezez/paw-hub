import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:projeto_integrador2/viewmodels/agenda_viewmodel.dart';
import 'package:projeto_integrador2/views/tela_agenda.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TelaAgendaViewModel viewModel;

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<TelaAgendaViewModel>.value(
      value: viewModel,
      child: const MaterialApp(
        home: TelaAgenda(),
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    viewModel = TelaAgendaViewModel();
  });

  group('TelaAgenda - Widget Tests', () {
    testWidgets('Renderiza sem erros e começa sem refeições', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Agenda'), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('FAB adiciona nova refeição', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(viewModel.perfilHorarios.length, 1);
      expect(find.text('Refeição 1'), findsOneWidget);
    });

    testWidgets('Remove refeição após confirmação no diálogo', (tester) async {
      viewModel.adicionarNovaRefeicao();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Refeição 1'), findsOneWidget);

      // pressionar o botão deletar
      await tester.tap(find.byIcon(Icons.delete_forever_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Remover Refeição 1?'), findsOneWidget);

      // confirmar remoção
      await tester.tap(find.text('Remover'));
      await tester.pump();

      expect(viewModel.perfilHorarios.length, 0);
      expect(find.text('Refeição 1'), findsNothing);
    });

    testWidgets('Alterar quantidade atualiza o ViewModel', (tester) async {
      viewModel.adicionarNovaRefeicao();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final campoQuantidade = find.byKey(const Key('refeicao_0_quantidade'));
      expect(campoQuantidade, findsOneWidget);

      await tester.enterText(campoQuantidade, '250g');
      await tester.pumpAndSettle();

      expect(viewModel.perfilHorarios[0].quantidadeRacao, '250g');
    });


    testWidgets('Alterar Switch chama toggleAtivacaoRefeicao', (tester) async {
      viewModel.adicionarNovaRefeicao();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encontra o Card que contém o texto 'Refeição 1'
      final cardRefeicao = find.widgetWithText(Card, 'Refeição 1');
      expect(cardRefeicao, findsOneWidget);

      // Encontra o Switch dentro desse Card
      final switchWidget = find.descendant(
        of: cardRefeicao,
        matching: find.byType(Switch),
      );
      expect(switchWidget, findsOneWidget);

      // Estado inicial
      expect(viewModel.perfilHorarios[0].ativa, true);

      // Toca no switch
      await tester.tap(switchWidget);
      await tester.pumpAndSettle();

      expect(viewModel.perfilHorarios[0].ativa, false);
    });

    testWidgets('Botão salvar mostra Snackbar de sucesso', (tester) async {
      viewModel.adicionarNovaRefeicao();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pump(); // iniciar async
      await tester.pump(const Duration(milliseconds: 300)); // permitir exibir snackbar

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Configurações salvas!'), findsOneWidget);
    });
  });
}
