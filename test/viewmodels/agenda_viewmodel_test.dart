import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrador2/viewmodels/agenda_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelaAgendaViewModel - Testes Unitários', () {
    late TelaAgendaViewModel viewModel;

    setUp(() {
      // Limpa SharedPreferences para cada teste
      SharedPreferences.setMockInitialValues({});
      viewModel = TelaAgendaViewModel();
    });

    test('Adicionar uma nova refeição deve aumentar a lista em 1', () async {
      final tamanhoAntes = viewModel.perfilHorarios.length;

      viewModel.adicionarNovaRefeicao();

      expect(viewModel.perfilHorarios.length, tamanhoAntes + 1);
    });

    test('Remover refeição deve diminuir a lista corretamente', () async {
      viewModel.adicionarNovaRefeicao(); // índice 0
      viewModel.adicionarNovaRefeicao(); // índice 1

      final tamanhoAntes = viewModel.perfilHorarios.length;

      viewModel.removerRefeicaoDefinitivamente(0);

      expect(viewModel.perfilHorarios.length, tamanhoAntes - 1);
    });

    test('Salvar perfil deve persistir os dados no SharedPreferences', () async {
      viewModel.adicionarNovaRefeicao();
      viewModel.adicionarNovaRefeicao();

      viewModel.perfilHorarios[0].quantidade = "150g";
      viewModel.perfilHorarios[1].quantidade = "200g";

      final sucesso = await viewModel.salvarPerfil();
      expect(sucesso, true);

      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getInt('numero_refeicoes'), 2);
      expect(prefs.getString('refeicao_0_quantidade'), "150g");
      expect(prefs.getString('refeicao_1_quantidade'), "200g");
    });

    test('Carregar perfil deve reconstruir a lista salva', () async {
      // Simula estado salvo no SharedPreferences
      SharedPreferences.setMockInitialValues({
        'numero_refeicoes': 1,
        'refeicao_0_horario_hour': 10,
        'refeicao_0_horario_minute': 30,
        'refeicao_0_quantidade': '180g',
        'refeicao_0_ativa': true,
        'refeicao_0_id': 'abc123',
      });

      viewModel = TelaAgendaViewModel();

      expect(viewModel.perfilHorarios.length, 1);
      expect(viewModel.perfilHorarios[0].quantidade, '180g');
      expect(viewModel.perfilHorarios[0].horario.hour, 10);
      expect(viewModel.perfilHorarios[0].horario.minute, 30);
      expect(viewModel.perfilHorarios[0].ativa, true);
      expect(viewModel.perfilHorarios[0].id, 'abc123');
    });
  });
}
