import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projeto_integrador2/views/tela_agenda.dart';
import 'package:projeto_integrador2/views/tela_historico.dart';
import 'package:projeto_integrador2/views/tela_configuracoes.dart';
import 'package:projeto_integrador2/viewmodels/agenda_viewmodel.dart';
import 'package:provider/provider.dart';

import 'auth_viewmodel.dart';
import 'configuracoes_viewmodel.dart';

class InicialViewModel extends ChangeNotifier {
  // ===================================================================
  // CONSTANTES
  // ===================================================================

  // chave pro SharedPreferences (ração consumida hoje)
  static const String _keyRacaoConsumidaHoje = 'racao_consumida_hoje';

  // ===================================================================
  // DEPENDÊNCIAS
  // ===================================================================

  final TelaAgendaViewModel agendaViewModel;

  InicialViewModel(this.agendaViewModel) {
    // Atualiza assim que criar
    _atualizarProximaRefeicao();

    // Atualiza sempre que a agenda mudar (ex.: usuário salvar a agenda)
    agendaViewModel.addListener(_onAgendaChanged);

    // Timer para contagem regressiva ficar em tempo quase real
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _atualizarProximaRefeicao(),
    );

    // Carrega o valor de ração consumida salvo anteriormente
    _carregarRacaoConsumida();
  }

  void _onAgendaChanged() {
    // Quando a agenda muda, atualiza próxima refeição e meta de ração
    _atualizarProximaRefeicao();
    notifyListeners();
  }

  Timer? _timer;

  // ===================================================================
  // ESTADO E DADOS
  // ===================================================================

  // Estado da navegação
  int _selectedIndex = 0;

  // Água (por enquanto mantém mockado)
  double _aguaConsumidaHoje = 290.0;
  double _metaAgua = 200.0;

  // Ração – consumo do dia (meta vem da Agenda)
  double _racaoConsumidaHoje = 0.0;

  // Próxima refeição (vindos da agenda)
  RefeicaoProgramada? _proximaRefeicao;
  Duration? _tempoRestante;

  // Dados do gráfico
  final List<FlSpot> _consumoSemanalSpots = const [
    FlSpot(0, 250), // Seg
    FlSpot(1, 310), // Ter
    FlSpot(2, 290), // Qua
    FlSpot(3, 320), // Qui
    FlSpot(4, 300), // Sex
    FlSpot(5, 315), // Sáb
    FlSpot(6, 295), // Dom
  ];

  // ===================================================================
  // GETTERS
  // ===================================================================

  int get selectedIndex => _selectedIndex;

  // Água
  String get aguaConsumidaFormatada => '${_aguaConsumidaHoje.toInt()}ml';
  String get metaAguaFormatada => 'Meta: ${_metaAgua.toInt()}ml';
  double get progressoAgua =>
      _metaAgua == 0 ? 0 : _aguaConsumidaHoje / _metaAgua;

  // ====== Ração (meta vinda da Agenda) ======

  /// Meta diária de ração (soma das quantidades das refeições ATIVAS)
  double get metaRacaoDiaria {
    double total = 0;

    for (final refeicao
    in agendaViewModel.perfilHorarios.where((r) => r.ativa)) {
      final q = _parseQuantidadeEmGramas(refeicao.quantidade);
      total += q;
    }

    return total;
  }

  /// Texto "25g"
  String get racaoConsumidaFormatada =>
      '${_racaoConsumidaHoje.toStringAsFixed(0)}g';

  /// Texto "Meta: 50g"
  String get metaRacaoFormatada =>
      'Meta: ${metaRacaoDiaria.toStringAsFixed(0)}g';

  /// Progresso (0.0 a 1.0)
  double get progressoRacao =>
      metaRacaoDiaria <= 0 ? 0 : _racaoConsumidaHoje / metaRacaoDiaria;

  /// Valor cru, pra usar no diálogo
  double get racaoConsumidaHoje => _racaoConsumidaHoje;

  // Próxima refeição (AGORA REAL, via agenda)
  String get proximaRefeicao {
    if (_proximaRefeicao == null) return '--:--';
    final h = _proximaRefeicao!.horario.hour.toString().padLeft(2, '0');
    final m = _proximaRefeicao!.horario.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get tempoAteProximaRefeicao {
    if (_tempoRestante == null) return 'Nenhuma refeição ativa';

    final totalMin = _tempoRestante!.inMinutes;
    if (totalMin <= 0) return 'Agora';

    final horas = totalMin ~/ 60;
    final minutos = totalMin % 60;

    if (horas > 0 && minutos > 0) {
      return 'Em ${horas}h ${minutos}min';
    } else if (horas > 0) {
      return 'Em ${horas}h';
    } else {
      return 'Em ${minutos}min';
    }
  }

  // Dados do Gráfico
  List<FlSpot> get consumoSemanalSpots => _consumoSemanalSpots;

  // ===================================================================
  // LÓGICA DA PRÓXIMA REFEIÇÃO
  // ===================================================================

  void _atualizarProximaRefeicao() {
    final entry = agendaViewModel.getProximaRefeicaoEHorario();

    if (entry == null) {
      _proximaRefeicao = null;
      _tempoRestante = null;
    } else {
      _proximaRefeicao = entry.key;
      _tempoRestante = entry.value;
    }

    notifyListeners();
  }

  // ===================================================================
  // PERSISTÊNCIA – Ração consumida
  // ===================================================================

  Future<void> _carregarRacaoConsumida() async {
    final prefs = await SharedPreferences.getInstance();
    _racaoConsumidaHoje =
        prefs.getDouble(_keyRacaoConsumidaHoje) ?? 0.0;
    notifyListeners();
  }

  /// Atualiza o valor consumido de ração (em gramas) e salva no SharedPreferences
  Future<void> atualizarRacaoConsumida(double novoValor) async {
    if (novoValor < 0) novoValor = 0;
    _racaoConsumidaHoje = novoValor;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyRacaoConsumidaHoje, _racaoConsumidaHoje);
  }

  // ===================================================================
  // AÇÕES DA VIEW
  // ===================================================================

  // Chamado quando o usuário clica em um item da barra de navegação
  void onItemTapped(int index, BuildContext context) {
    // Se for Configurações (índice 3), apenas navega para a tela, sem alterar _selectedIndex
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChangeNotifierProvider<ConfiguracoesViewModel>(
                create: (context) {
                  final authViewModel =
                  Provider.of<AuthViewModel>(context, listen: false);
                  return ConfiguracoesViewModel(authViewModel);
                },
                child: const TelaConfiguracoes(),
              ),
        ),
      );
      return;
    }

    // Para abas normais (0, 1, 2), atualiza o índice e notifica a UI
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }

    switch (index) {
      case 0:
        print("Item 'Visão Geral' selecionado.");
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TelaAgenda(),
          ),
        );
        print("Item 'Agenda' selecionado.");
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TelaHistorico(),
          ),
        );
        break;

      case 3:
      // já tratado lá em cima
        break;

      default:
        print("Índice de item desconhecido: $index");
    }
  }

  // ===================================================================
  // HELPERS
  // ===================================================================

  /// Tenta extrair um número da string de quantidade, em gramas.
  /// Exemplos:
  /// "200g" -> 200
  /// "50 g, 1 porção" -> 50
  /// "abc" -> 0
  double _parseQuantidadeEmGramas(String quantidade) {
    final regex = RegExp(r'(\d+(\,\d+)?(\.\d+)?)');
    final match = regex.firstMatch(quantidade);
    if (match == null) return 0;

    final raw = match.group(0) ?? '';
    final normalized = raw.replaceAll(',', '.');

    return double.tryParse(normalized) ?? 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    agendaViewModel.removeListener(_onAgendaChanged);
    super.dispose();
  }
}
