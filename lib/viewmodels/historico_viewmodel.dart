import 'package:flutter/material.dart';

// Enum para o período (Diário/Semanal)
enum ChartViewType { daily, weekly }

class HistoricoViewModel extends ChangeNotifier {
  // --- ESTADO ---
  ChartViewType _currentView = ChartViewType.daily;
  bool _isChartView = true; // true para gráfico, false para lista

  // --- DADOS MOCK ---
  // Ração
  final List<Map<String, dynamic>> feedDataDaily = [
    {'day': 'Seg', 'value': 300.0}, {'day': 'Ter', 'value': 450.0}, {'day': 'Qua', 'value': 600.0},
    {'day': 'Qui', 'value': 550.0}, {'day': 'Sex', 'value': 700.0}, {'day': 'Sab', 'value': 750.0},
    {'day': 'Dom', 'value': 400.0},
  ];
  final List<Map<String, dynamic>> feedDataWeekly = [
    {'week': 'Sem 1', 'value': 2500.0}, {'week': 'Sem 2', 'value': 3000.0},
    {'week': 'Sem 3', 'value': 2800.0}, {'week': 'Sem 4', 'value': 3200.0},
  ];

  // Água
  final List<Map<String, dynamic>> waterDataDaily = [
    {'day': 'Seg', 'value': 500.0}, {'day': 'Ter', 'value': 650.0}, {'day': 'Qua', 'value': 600.0},
    {'day': 'Qui', 'value': 700.0}, {'day': 'Sex', 'value': 750.0}, {'day': 'Sab', 'value': 800.0},
    {'day': 'Dom', 'value': 650.0},
  ];
  final List<Map<String, dynamic>> waterDataWeekly = [
    {'week': 'Sem 1', 'value': 4500.0}, {'week': 'Sem 2', 'value': 5000.0},
    {'week': 'Sem 3', 'value': 4800.0}, {'week': 'Sem 4', 'value': 5200.0},
  ];

  // --- GETTERS ---
  ChartViewType get currentView => _currentView;
  bool get isChartView => _isChartView;

  // --- MÉTODOS ---
  void changeView(ChartViewType newView) {
    _currentView = newView;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _isChartView = !_isChartView;
    notifyListeners();
  }

  void fetchData() {
    notifyListeners();
  }
}