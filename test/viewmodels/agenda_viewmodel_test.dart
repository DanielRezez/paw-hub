import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart'; // Importa para TimeOfDay
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ajuste o caminho do import se o nome do seu pacote for diferente
import 'package:projeto_integrador2/viewmodels/agenda_viewmodel.dart';

import 'agenda_viewmodel_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late TelaAgendaViewModel viewModel;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  // --- TAREFA 1: Testar adicionarNovaRefeicao ---
  test('TAREFA 1: Deve adicionar uma nova refeição à lista', () async {
    SharedPreferences.setMockInitialValues({});
    viewModel = TelaAgendaViewModel();
    await viewModel.carregarPerfil();

    expect(viewModel.perfilHorarios.length, 0);

    viewModel.adicionarNovaRefeicao();

    expect(viewModel.perfilHorarios.length, 1);
    expect(viewModel.perfilHorarios[0].ativa, true);
  });

  // --- TAREFA 2: Testar removerRefeicaoDefinitivamente ---
  test('TAREFA 2: Deve remover a refeição correta da lista', () async {
    SharedPreferences.setMockInitialValues({});
    viewModel = TelaAgendaViewModel();
    await viewModel.carregarPerfil();

    viewModel.adicionarNovaRefeicao();
    viewModel.adicionarNovaRefeicao();
    viewModel.atualizarQuantidadeRefeicao(0, 'item 1');
    viewModel.atualizarQuantidadeRefeicao(1, 'item 2');
    expect(viewModel.perfilHorarios.length, 2);

    viewModel.removerRefeicaoDefinitivamente(0);

    expect(viewModel.perfilHorarios.length, 1);
    expect(viewModel.perfilHorarios[0].quantidade, 'item 2');
  });

  // --- TAREFA 3 (Parte A): Testar carregarPerfil ---
  test('TAREFA 3 (Carregar): Deve carregar o perfil salvo do SharedPreferences', () async {
    final Map<String, Object> valoresSimulados = {
      'numero_refeicoes': 2,
      'refeicao_0_quantidade': '100g', 'refeicao_0_horario_hour': 10, 'refeicao_0_horario_minute': 30, 'refeicao_0_ativa': true, 'refeicao_0_id': 'id_123',
      'refeicao_1_quantidade': '200g', 'refeicao_1_horario_hour': 14, 'refeicao_1_horario_minute': 0, 'refeicao_1_ativa': false, 'refeicao_1_id': 'id_456',
    };
    SharedPreferences.setMockInitialValues(valoresSimulados);

    viewModel = TelaAgendaViewModel();
    await viewModel.carregarPerfil();

    expect(viewModel.perfilHorarios.length, 2);
    expect(viewModel.perfilHorarios[0].quantidade, '100g');
    expect(viewModel.perfilHorarios[1].id, 'id_456');
  });

  // --- TAREFA 3 (Parte B): Testar salvarPerfil ---
  test('TAREFA 3 (Salvar): Deve salvar o perfil no SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    viewModel = TelaAgendaViewModel();
    await viewModel.carregarPerfil();

    viewModel.adicionarNovaRefeicao();
    viewModel.atualizarHorarioRefeicao(0, TimeOfDay(hour: 8, minute: 0));
    viewModel.atualizarQuantidadeRefeicao(0, '50g');

    await viewModel.salvarPerfil();

    final prefs = await SharedPreferences.getInstance();

    expect(prefs.getInt('numero_refeicoes'), 1);
    expect(prefs.getString('refeicao_0_quantidade'), '50g');
    expect(prefs.getInt('refeicao_0_horario_hour'), 8);
  });

  // --- TESTE BÔNUS: Lógica de Limpeza do Salvar ---
  test('TAREFA 3 (Salvar - Limpeza): salvarPerfil deve limpar chaves antigas', () async {
    // PREPARAÇÃO (Arrange)
    // --- ESTA É A CORREÇÃO ---
    // Agora os dados falsos estão "completos"
    final Map<String, Object> valoresAntigos = {
      'numero_refeicoes': 2, 'total_refeicoes_salvas_anteriormente': 2,
      // Item 0 (completo)
      'refeicao_0_quantidade': 'item 0', 'refeicao_0_id': 'id_0',
      'refeicao_0_horario_hour': 8, 'refeicao_0_horario_minute': 0, 'refeicao_0_ativa': true,
      // Item 1 (completo) - Este deve sumir
      'refeicao_1_quantidade': 'item 1', 'refeicao_1_id': 'id_1',
      'refeicao_1_horario_hour': 12, 'refeicao_1_horario_minute': 0, 'refeicao_1_ativa': false,
    };
    SharedPreferences.setMockInitialValues(valoresAntigos);

    viewModel = TelaAgendaViewModel();
    await viewModel.carregarPerfil(); // (Log agora vai mostrar: Total: 2)

    // Esta linha (127 no seu log antigo) agora vai passar!
    expect(viewModel.perfilHorarios.length, 2);

    // AÇÃO (Act)
    viewModel.removerRefeicaoDefinitivamente(1);
    expect(viewModel.perfilHorarios.length, 1);

    await viewModel.salvarPerfil();

    // VERIFICAÇÃO (Assert)
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('numero_refeicoes'), 1);
    expect(prefs.getString('refeicao_0_quantidade'), 'item 0'); // item 0 ainda existe

    expect(prefs.getString('refeicao_1_quantidade'), isNull);
    expect(prefs.getString('refeicao_1_id'), isNull);
    expect(prefs.getInt('total_refeicoes_salvas_anteriormente'), 1);
  });
}