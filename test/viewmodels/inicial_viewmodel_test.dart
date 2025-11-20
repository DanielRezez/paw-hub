// test/viewmodels/inicial_viewmodel_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:projeto_integrador2/viewmodels/inicial_viewmodel.dart';
import 'package:projeto_integrador2/viewmodels/agenda_viewmodel.dart';

import 'inicial_viewmodel_test.mocks.dart';

@GenerateMocks([TelaAgendaViewModel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // SharedPreferences fake em memória
    SharedPreferences.setMockInitialValues({});
  });

  group('InicialViewModel - próxima refeição', () {
    test('usa o valor retornado pelo AgendaViewModel', () async {
      final mockAgenda = MockTelaAgendaViewModel();

      // Monta uma refeição fake
      final refeicao = RefeicaoProgramada(
        horario: const TimeOfDay(hour: 12, minute: 0),
        // adapta esses campos para o teu RefeicaoProgramada real
        quantidadeRacao: '50g',
        quantidadeAgua: '100ml',
        ativa: true,
        id: '1',
      );

      // Quando o InicialViewModel perguntar pro AgendaViewModel,
      // ele recebe essa refeição com 60 minutos de diferença.
      when(mockAgenda.getProximaRefeicaoEHorario()).thenReturn(
        MapEntry(refeicao, const Duration(minutes: 60)),
      );

      final vm = InicialViewModel(mockAgenda);

      // deixa o construtor rodar os listeners/timer
      await Future<void>.delayed(Duration.zero);

      expect(vm.proximaRefeicao, '12:00');
      expect(vm.tempoAteProximaRefeicao, 'Em 1h');

      vm.dispose();
    });

    test('quando não há refeição ativa, mostra mensagens padrão', () async {
      final mockAgenda = MockTelaAgendaViewModel();
      when(mockAgenda.getProximaRefeicaoEHorario()).thenReturn(null);

      final vm = InicialViewModel(mockAgenda);

      await Future<void>.delayed(Duration.zero);

      expect(vm.proximaRefeicao, '--:--');
      expect(vm.tempoAteProximaRefeicao, 'Nenhuma refeição ativa');

      vm.dispose();
    });
  });

  group('InicialViewModel - dados do gráfico (FlSpot)', () {
    test('possui 7 pontos (um por dia) com os valores esperados', () {
      final mockAgenda = MockTelaAgendaViewModel();
      when(mockAgenda.getProximaRefeicaoEHorario()).thenReturn(null);

      final vm = InicialViewModel(mockAgenda);

      final spots = vm.consumoSemanalSpots;
      expect(spots.length, 7);

      expect(spots[0], const FlSpot(0, 250));
      expect(spots[1], const FlSpot(1, 310));
      expect(spots[2], const FlSpot(2, 290));
      expect(spots[3], const FlSpot(3, 320));
      expect(spots[4], const FlSpot(4, 300));
      expect(spots[5], const FlSpot(5, 315));
      expect(spots[6], const FlSpot(6, 295));

      vm.dispose();
    });
  });

  group('InicialViewModel - onItemTapped / selectedIndex', () {
    testWidgets('atualiza selectedIndex ao chamar onItemTapped',
            (tester) async {
          final mockAgenda = MockTelaAgendaViewModel();
          when(mockAgenda.getProximaRefeicaoEHorario()).thenReturn(null);

          final vm = InicialViewModel(mockAgenda);

          // cria um contexto qualquer pra passar pro onItemTapped
          late BuildContext capturedContext;
          await tester.pumpWidget(
            Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          );

          expect(vm.selectedIndex, 0);
          vm.onItemTapped(2, capturedContext);
          expect(vm.selectedIndex, 2);

          vm.dispose();
        });
  });
}
