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
  static const String _keyRacaoConsumidaHoje = 'racao_consumida_hoje';
  static const String _keyAguaConsumidaHoje = 'agua_consumida_hoje';

  final TelaAgendaViewModel agendaViewModel;

  InicialViewModel(this.agendaViewModel) {
    _atualizarProximaRefeicao();
    agendaViewModel.addListener(_onAgendaChanged);

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _atualizarProximaRefeicao(),
    );

    _carregarRacaoConsumida();
    _carregarAguaConsumida();
  }

  void _onAgendaChanged() {
    _atualizarProximaRefeicao();
    notifyListeners();
  }

  Timer? _timer;

  int _selectedIndex = 0;

  double _aguaConsumidaHoje = 0.0;
  double _racaoConsumidaHoje = 0.0;

  RefeicaoProgramada? _proximaRefeicao;
  Duration? _tempoRestante;

  final List<FlSpot> _consumoSemanalSpots = const [
    FlSpot(0, 250),
    FlSpot(1, 310),
    FlSpot(2, 290),
    FlSpot(3, 320),
    FlSpot(4, 300),
    FlSpot(5, 315),
    FlSpot(6, 295),
  ];

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // ===== ÁGUA =====

  double get metaAguaDiaria {
    double total = 0;
    for (final refeicao
    in agendaViewModel.perfilHorarios.where((r) => r.ativa)) {
      total += _parseNumero(refeicao.quantidadeAgua);
    }
    return total;
  }

  String get aguaConsumidaFormatada =>
      '${_aguaConsumidaHoje.toStringAsFixed(0)}ml';

  String get metaAguaFormatada =>
      'Meta: ${metaAguaDiaria.toStringAsFixed(0)}ml';

  double get progressoAgua =>
      metaAguaDiaria <= 0 ? 0 : _aguaConsumidaHoje / metaAguaDiaria;

  double get aguaConsumidaHoje => _aguaConsumidaHoje;


  double get metaRacaoDiaria {
    double total = 0;
    for (final refeicao
    in agendaViewModel.perfilHorarios.where((r) => r.ativa)) {
      total += _parseNumero(refeicao.quantidadeRacao);
    }
    return total;
  }

  String get racaoConsumidaFormatada =>
      '${_racaoConsumidaHoje.toStringAsFixed(0)}g';

  String get metaRacaoFormatada =>
      'Meta: ${metaRacaoDiaria.toStringAsFixed(0)}g';

  double get progressoRacao =>
      metaRacaoDiaria <= 0 ? 0 : _racaoConsumidaHoje / metaRacaoDiaria;

  double get racaoConsumidaHoje => _racaoConsumidaHoje;

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

  List<FlSpot> get consumoSemanalSpots => _consumoSemanalSpots;

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

  // ===== Persistência =====

  Future<void> _carregarRacaoConsumida() async {
    final prefs = await SharedPreferences.getInstance();
    _racaoConsumidaHoje = prefs.getDouble(_keyRacaoConsumidaHoje) ?? 0.0;
    notifyListeners();
  }

  Future<void> _carregarAguaConsumida() async {
    final prefs = await SharedPreferences.getInstance();
    _aguaConsumidaHoje = prefs.getDouble(_keyAguaConsumidaHoje) ?? 0.0;
    notifyListeners();
  }

  Future<void> atualizarRacaoConsumida(double novoValor) async {
    if (novoValor < 0) novoValor = 0;
    _racaoConsumidaHoje = novoValor;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyRacaoConsumidaHoje, _racaoConsumidaHoje);
  }

  Future<void> atualizarAguaConsumida(double novoValor) async {
    if (novoValor < 0) novoValor = 0;
    _aguaConsumidaHoje = novoValor;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyAguaConsumidaHoje, _aguaConsumidaHoje);
  }

  void onItemTapped(int index, BuildContext context) {
    setIndex(index);

    if (index == 0) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          switch (index) {
            case 1:
              return const TelaAgenda();
            case 2:
              return const TelaHistorico();
            case 3:
              return ChangeNotifierProvider<ConfiguracoesViewModel>(
                create: (context) {
                  final authViewModel =
                  Provider.of<AuthViewModel>(context, listen: false);
                  return ConfiguracoesViewModel(authViewModel);
                },
                child: const TelaConfiguracoes(),
              );
            default:
              return const TelaAgenda();
          }
        },
      ),
    );
  }

  double _parseNumero(String texto) {
    final regex = RegExp(r'(\d+(\,\d+)?(\.\d+)?)');
    final match = regex.firstMatch(texto);
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
