import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class inicialViewModel extends ChangeNotifier {
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
  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners(); // Avisa a View que o estado mudou e ela precisa se redesenhar
  }
}