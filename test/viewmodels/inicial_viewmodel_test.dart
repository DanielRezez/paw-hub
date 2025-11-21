// test/viewmodels/inicial_viewmodel_test.dart
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
  late MockTelaAgendaViewModel mockAgenda;

  setUp(() {
    // Mock do SharedPreferences
    SharedPreferences.setMockInitialValues({});

    mockAgenda = MockTelaAgendaViewModel();

    // Defaults seguros
    when(mockAgenda.perfilHorarios).thenReturn(<RefeicaoProgramada>[]);
    when(mockAgenda.getProximaRefeicaoEHorario()).thenReturn(null);
  });

  group('InicialViewModel - metas e progresso', () {
    test('metaRacaoDiaria e metaAguaDiaria começam em 0', () async {
      final vm = InicialViewModel(mockAgenda);

      // espera async interno carregar prefs vazias
      await Future.delayed(const Duration(milliseconds: 150));

      expect(vm.metaRacaoDiaria, 0);
      expect(vm.metaAguaDiaria, 0);
      expect(vm.metaRacaoFormatada, 'Meta: 0g');
      expect(vm.metaAguaFormatada, 'Meta: 0ml');
      expect(vm.progressoRacao, 0);
      expect(vm.progressoAgua, 0);

      vm.dispose();
    });

    test('metaRacaoDiaria soma apenas refeições ativas', () async {
      when(mockAgenda.perfilHorarios).thenReturn([
        RefeicaoProgramada(
          horario: const TimeOfDay(hour: 8, minute: 0),
          quantidadeRacao: '50g',
          quantidadeAgua: '100ml',
          ativa: true,
          id: '1',
        ),
        RefeicaoProgramada(
          horario: const TimeOfDay(hour: 12, minute: 0),
          quantidadeRacao: '70g',
          quantidadeAgua: '150ml',
          ativa: true,
          id: '2',
        ),
        RefeicaoProgramada(
          horario: const TimeOfDay(hour: 18, minute: 0),
          quantidadeRacao: '30g',
          quantidadeAgua: '200ml',
          ativa: false,
          id: '3',
        ),
      ]);

      final vm = InicialViewModel(mockAgenda);

      // espera async interno carregar prefs
      await Future.delayed(const Duration(milliseconds: 150));

      expect(vm.metaRacaoDiaria, 120);
      expect(vm.metaRacaoFormatada, 'Meta: 120g');

      await vm.atualizarRacaoConsumida(60);
      await Future.delayed(const Duration(milliseconds: 80));

      expect(vm.progressoRacao, closeTo(0.5, 0.001));

      vm.dispose();
    });

    test('metaAguaDiaria soma apenas refeições ativas', () async {
      when(mockAgenda.perfilHorarios).thenReturn([
        RefeicaoProgramada(
          horario: const TimeOfDay(hour: 8, minute: 0),
          quantidadeRacao: '50g',
          quantidadeAgua: '100ml',
          ativa: true,
          id: '1',
        ),
        RefeicaoProgramada(
          horario: const TimeOfDay(hour: 12, minute: 0),
          quantidadeRacao: '70g',
          quantidadeAgua: '150ml',
          ativa: true,
          id: '2',
        ),
      ]);

      final vm = InicialViewModel(mockAgenda);

      // 🔥 ESSA É A CORREÇÃO:
      // espera o construtor finalizar _carregarAguaConsumida()
      await Future.delayed(const Duration(milliseconds: 200));

      expect(vm.metaAguaDiaria, 250);
      expect(vm.metaAguaFormatada, 'Meta: 250ml');

      await vm.atualizarAguaConsumida(125);

      // espera o save/notify estabilizar
      await Future.delayed(const Duration(milliseconds: 100));

      expect(vm.progressoAgua, closeTo(0.5, 0.001));

      vm.dispose();
    });
  });

  group('InicialViewModel - próxima refeição', () {
    test('quando não há refeição ativa → "--:--"', () async {
      final vm = InicialViewModel(mockAgenda);

      await Future.delayed(const Duration(milliseconds: 120));

      expect(vm.proximaRefeicao, '--:--');
      expect(vm.tempoAteProximaRefeicao, 'Nenhuma refeição ativa');

      vm.dispose();
    });

    test('usa dados do AgendaViewModel', () async {
      final refeicao = RefeicaoProgramada(
        horario: const TimeOfDay(hour: 18, minute: 30),
        quantidadeRacao: '80g',
        quantidadeAgua: '200ml',
        ativa: true,
        id: 'prox',
      );

      when(mockAgenda.getProximaRefeicaoEHorario())
          .thenReturn(MapEntry(refeicao, const Duration(minutes: 90)));

      final vm = InicialViewModel(mockAgenda);

      await Future.delayed(const Duration(milliseconds: 120));

      expect(vm.proximaRefeicao, '18:30');
      expect(vm.tempoAteProximaRefeicao, 'Em 1h 30min');

      vm.dispose();
    });
  });

  group('InicialViewModel - dados do gráfico', () {
    test('7 pontos com valores esperados', () async {
      final vm = InicialViewModel(mockAgenda);

      await Future.delayed(const Duration(milliseconds: 80));

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

  group('InicialViewModel - navegação', () {
    test('onItemTapped(0) só altera selectedIndex', () async {
      final vm = InicialViewModel(mockAgenda);

      await Future.delayed(const Duration(milliseconds: 80));

      final fakeContext = _FakeBuildContext();

      vm.onItemTapped(0, fakeContext);

      expect(vm.selectedIndex, 0);

      vm.dispose();
    });
  });
}

class _FakeBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
