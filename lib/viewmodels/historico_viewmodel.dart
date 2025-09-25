import 'package:flutter/material.dart';

// Enum para definir os tipos de visualização de forma clara
enum ChartViewType { daily, weekly }

class HistoricoViewModel extends ChangeNotifier {
  // --- ESTADO ---
  ChartViewType _currentView = ChartViewType.daily;
  bool _isChartView = true; // true para gráfico, false para lista

  // --- DADOS MOCK ---
  final List<Map<String, dynamic>> _dailyConsumption = [
    {'day': 'Seg', 'value': 300.0},
    {'day': 'Ter', 'value': 450.0},
    {'day': 'Qua', 'value': 600.0},
    {'day': 'Qui', 'value': 550.0},
    {'day': 'Sex', 'value': 700.0},
    {'day': 'Sab', 'value': 750.0},
    {'day': 'Dom', 'value': 400.0},
  ];

  final List<Map<String, dynamic>> _weeklyConsumption = [
    {'week': 'Sem 1', 'value': 2500.0},
    {'week': 'Sem 2', 'value': 3000.0},
    {'week': 'Sem 3', 'value': 2800.0},
    {'week': 'Sem 4', 'value': 3200.0},
  ];

  // --- GETTERS ---
  ChartViewType get currentView => _currentView;
  bool get isChartView => _isChartView;
  List<Map<String, dynamic>> get dailyConsumption => _dailyConsumption;
  List<Map<String, dynamic>> get weeklyConsumption => _weeklyConsumption;

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