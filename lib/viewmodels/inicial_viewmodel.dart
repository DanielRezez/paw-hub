import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projeto_integrador2/views/tela_agenda.dart';
import 'package:projeto_integrador2/views/tela_historico.dart';
import 'package:projeto_integrador2/views/tela_configuracoes.dart';
import 'package:projeto_integrador2/viewmodels/agenda_viewmodel.dart';
import 'package:provider/provider.dart';

import 'auth_viewmodel.dart';
import 'configuracoes_viewmodel.dart';

class InicialViewModel extends ChangeNotifier {
  // ===================================================================
  // DEPENDÊNCIAS
  // ===================================================================

  final TelaAgendaViewModel agendaViewModel;

  InicialViewModel(this.agendaViewModel) {
    // Atualiza assim que criar
    _atualizarProximaRefeicao();

    // Atualiza sempre que a agenda mudar (ex.: usuário salvar a agenda)
    agendaViewModel.addListener(_atualizarProximaRefeicao);

    // Timer para contagem regressiva ficar em tempo quase real
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _atualizarProximaRefeicao(),
    );
  }

  Timer? _timer;

  // ===================================================================
  // ESTADO E DADOS
  // ===================================================================

  // Estado da navegação
  int _selectedIndex = 0;

  // Dados mockados do pet (por enquanto continuam assim)
  final double _aguaConsumidaHoje = 290.0;
  final double _metaAgua = 200.0;
  final double _racaoConsumidaHoje = 135.0;
  final double _metaRacao = 120.0;

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

  // Card de Água
  String get aguaConsumidaFormatada => '${_aguaConsumidaHoje.toInt()}ml';
  String get metaAguaFormatada => 'Meta: ${_metaAgua.toInt()}ml';
  double get progressoAgua => _metaAgua == 0 ? 0 : _aguaConsumidaHoje / _metaAgua;

  // Card de Ração
  String get racaoConsumidaFormatada => '${_racaoConsumidaHoje.toInt()}g';
  String get metaRacaoFormatada => 'Meta: ${_metaRacao.toInt()}g';
  double get progressoRacao => _metaRacao == 0 ? 0 : _racaoConsumidaHoje / _metaRacao;

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
  // MÉTODOS (Ações que a View pode chamar)
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
                child: TelaConfiguracoes(),
              ),
        ),
      );
      // Não chamamos notifyListeners, porque a barra principal não muda
      return;
    }

    // Para abas normais (0, 1, 2), atualiza o índice e notifica a UI
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }

    switch (index) {
      case 0:
      // Visão Geral
        print("Item 'Visão Geral' selecionado.");
        break;

      case 1:
      // AGENDA
      // IMPORTANTE: usa o MESMO TelaAgendaViewModel global,
      // não cria outro ChangeNotifierProvider aqui.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaAgenda(),
          ),
        );
        print("Item 'Agenda' selecionado.");
        break;

      case 2:
      // Histórico
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TelaHistorico(),
          ),
        );
        break;

      case 3:
      // (já tratado acima, mas mantive por segurança)
        print(
            "Item 'Config' selecionado. Navegando para TelaConfiguracoes...");
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
                  child: TelaConfiguracoes(),
                ),
          ),
        );
        break;

      default:
        print("Índice de item desconhecido: $index");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    agendaViewModel.removeListener(_atualizarProximaRefeicao);
    super.dispose();
  }
}
