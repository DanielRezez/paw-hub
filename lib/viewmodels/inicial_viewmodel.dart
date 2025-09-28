import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projeto_integrador2/views/tela_agenda.dart';
import 'package:projeto_integrador2/views/tela_configuracoes.dart';
import 'package:provider/provider.dart';

import 'auth_viewmodel.dart';
import 'configuracoes_viewmodel.dart';
import 'agenda_viewmodel.dart';

class InicialViewModel extends ChangeNotifier {
  // ===================================================================
  // ESTADO E DADOS (A "fonte da verdade" da tela)
  // ===================================================================

  // Estado da navegação
  int _selectedIndex = 0;

  // Dados mockados do pet
  final double _aguaConsumidaHoje = 290.0;
  final double _metaAgua = 400.0;
  final double _racaoConsumidaHoje = 155.0;
  final double _metaRacao = 180.0;
  final String _proximaRefeicao = '18:30';
  final String _tempoAteProximaRefeicao = 'Em 2h 15min';

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
  // GETTERS (Dados já formatados e calculados pra View usar)
  // A View não precisa saber como calcular, só pega o resultado pronto.
  // ===================================================================

  int get selectedIndex => _selectedIndex;

  // Card de Água
  String get aguaConsumidaFormatada => '${_aguaConsumidaHoje.toInt()}ml';
  String get metaAguaFormatada => 'Meta: ${_metaAgua.toInt()}ml';
  double get progressoAgua => _aguaConsumidaHoje / _metaAgua;

  // Card de Ração
  String get racaoConsumidaFormatada => '${_racaoConsumidaHoje.toInt()}g';
  String get metaRacaoFormatada => 'Meta: ${_metaRacao.toInt()}g';
  double get progressoRacao => _racaoConsumidaHoje / _metaRacao;

  // Card de Próxima Refeição
  String get proximaRefeicao => _proximaRefeicao;
  String get tempoAteProximaRefeicao => _tempoAteProximaRefeicao;

  // Dados do Gráfico
  List<FlSpot> get consumoSemanalSpots => _consumoSemanalSpots;

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
          builder: (context) => ChangeNotifierProvider<ConfiguracoesViewModel>(
            create: (context) {
              final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
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
      // Lógica para Visão Geral (índice 0)
      // A TelaInicial já mostra a "Visão Geral" por padrão
        print("Item 'Visão Geral' selecionado.");
        break;
      case 1:
      // Lógica para Agenda (índice 1)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<TelaAgendaViewModel>(
              create: (context) {
                // Obtém o AuthViewModel já fornecido para passá-lo ao ConfiguracoesViewModel
                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                return TelaAgendaViewModel();
              },
              child: TelaAgenda(), // Remova o const se não for mais necessário
            ),
          ),
        );
        print("Item 'Agenda' selecionado.");
        break;
      case 2:
      // Lógica para Histórico (índice 2)
        print("Item 'Histórico' selecionado.");
        break;
      default:
        print("Índice de item desconhecido: $index");
    }
  }
}