import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math'; // Para gerar IDs únicos simples

// Modelo para Refeição Programada
class RefeicaoProgramada {
  TimeOfDay horario;
  String quantidadeRacao;  // nunca null
  String quantidadeAgua;   // nunca null
  bool ativa;
  String id; // ID único para cada refeição

  RefeicaoProgramada({
    required this.horario,
    required this.quantidadeRacao,
    required this.quantidadeAgua,
    required this.ativa,
    required this.id,
  });
}

class TelaAgendaViewModel extends ChangeNotifier {
  final List<RefeicaoProgramada> _perfilHorarios = [];
  List<RefeicaoProgramada> get perfilHorarios => _perfilHorarios;

  TelaAgendaViewModel() {
    carregarPerfil();
  }

  // Chaves base para SharedPreferences
  static const String _keyNumeroRefeicoes = 'numero_refeicoes';
  String _keyHorarioHour(int index) => 'refeicao_${index}_horario_hour';
  String _keyHorarioMinute(int index) => 'refeicao_${index}_horario_minute';

  // Mantém a chave antiga para ração
  String _keyQuantidadeRacao(int index) => 'refeicao_${index}_quantidade';
  // Nova chave para água
  String _keyQuantidadeAgua(int index) => 'refeicao_${index}_quantidade_agua';

  String _keyAtiva(int index) => 'refeicao_${index}_ativa';
  String _keyId(int index) => 'refeicao_${index}_id';

  Future<void> carregarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    _perfilHorarios.clear();

    final int? numeroDeRefeicoes = prefs.getInt(_keyNumeroRefeicoes);
    print('>> carregarPerfil: numero_refeicoes = $numeroDeRefeicoes');

    if (numeroDeRefeicoes != null && numeroDeRefeicoes > 0) {
      for (int i = 0; i < numeroDeRefeicoes; i++) {
        final hour = prefs.getInt(_keyHorarioHour(i));
        final minute = prefs.getInt(_keyHorarioMinute(i));
        final quantidadeRacao = prefs.getString(_keyQuantidadeRacao(i));
        final quantidadeAgua = prefs.getString(_keyQuantidadeAgua(i));
        final ativa = prefs.getBool(_keyAtiva(i));
        final id = prefs.getString(_keyId(i));

        print(
            '  idx $i -> h=$hour m=$minute rac="$quantidadeRacao" ag="$quantidadeAgua" ativa=$ativa id=$id');

        // Hora, minuto, ativa e id precisam existir;
        // quantidadeRacao/Agua viram "" se forem null.
        if (hour != null && minute != null && ativa != null && id != null) {
          _perfilHorarios.add(
            RefeicaoProgramada(
              horario: TimeOfDay(hour: hour, minute: minute),
              quantidadeRacao: quantidadeRacao ?? '', // <<< nunca null
              quantidadeAgua: quantidadeAgua ?? '',    // <<< nunca null
              ativa: ativa,
              id: id,
            ),
          );
        }
      }
    }

    notifyListeners();
    print("Perfil de horários carregado. Total: ${_perfilHorarios.length}");
  }

  Future<bool> salvarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setInt(_keyNumeroRefeicoes, _perfilHorarios.length);

      for (int i = 0; i < _perfilHorarios.length; i++) {
        final refeicao = _perfilHorarios[i];
        await prefs.setInt(_keyHorarioHour(i), refeicao.horario.hour);
        await prefs.setInt(_keyHorarioMinute(i), refeicao.horario.minute);
        await prefs.setString(_keyQuantidadeRacao(i), refeicao.quantidadeRacao);
        await prefs.setString(_keyQuantidadeAgua(i), refeicao.quantidadeAgua);
        await prefs.setBool(_keyAtiva(i), refeicao.ativa);
        await prefs.setString(_keyId(i), refeicao.id);
      }

      // Limpa posições antigas, se existirem
      int? totalSalvoAnteriormente =
      prefs.getInt('total_refeicoes_salvas_anteriormente');
      if (totalSalvoAnteriormente != null) {
        for (int i = _perfilHorarios.length; i < totalSalvoAnteriormente; i++) {
          await prefs.remove(_keyHorarioHour(i));
          await prefs.remove(_keyHorarioMinute(i));
          await prefs.remove(_keyQuantidadeRacao(i));
          await prefs.remove(_keyQuantidadeAgua(i));
          await prefs.remove(_keyAtiva(i));
          await prefs.remove(_keyId(i));
        }
      }
      await prefs.setInt(
          'total_refeicoes_salvas_anteriormente', _perfilHorarios.length);

      print("Perfil de horários salvo. Total: ${_perfilHorarios.length}");
      notifyListeners();
      return true;
    } catch (e) {
      print("Erro ao salvar perfil no SharedPreferences: $e");
      return false;
    }
  }

  // --- MÉTODOS CRUD ---

  void adicionarNovaRefeicao() {
    String novoId = DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
    _perfilHorarios.add(
      RefeicaoProgramada(
        horario: TimeOfDay.now(),
        quantidadeRacao: "",
        quantidadeAgua: "",
        ativa: true,
        id: novoId,
      ),
    );
    notifyListeners();
  }

  void removerRefeicaoDefinitivamente(int index) {
    if (index < 0 || index >= _perfilHorarios.length) return;
    _perfilHorarios.removeAt(index);
    notifyListeners();
  }

  // --- UPDATE ---

  void atualizarHorarioRefeicao(int index, TimeOfDay novoHorario) {
    if (index < 0 || index >= _perfilHorarios.length) return;
    _perfilHorarios[index].horario = novoHorario;
    notifyListeners();
  }

  void atualizarQuantidadeRacaoRefeicao(int index, String novaQuantidade) {
    if (index < 0 || index >= _perfilHorarios.length) return;
    _perfilHorarios[index].quantidadeRacao = novaQuantidade;
    notifyListeners();
  }

  void atualizarQuantidadeAguaRefeicao(int index, String novaQuantidade) {
    if (index < 0 || index >= _perfilHorarios.length) return;
    _perfilHorarios[index].quantidadeAgua = novaQuantidade;
    notifyListeners();
  }

  void toggleAtivacaoRefeicao(int index) {
    if (index < 0 || index >= _perfilHorarios.length) return;
    _perfilHorarios[index].ativa = !_perfilHorarios[index].ativa;
    notifyListeners();
  }

  // Próxima refeição
  MapEntry<RefeicaoProgramada, Duration>? getProximaRefeicaoEHorario() {
    if (_perfilHorarios.isEmpty) return null;

    final now = DateTime.now();
    RefeicaoProgramada? proximaRefeicao;
    Duration? menorDiferenca;

    final refeicoesAtivas = _perfilHorarios.where((r) => r.ativa);
    if (refeicoesAtivas.isEmpty) return null;

    for (var refeicao in refeicoesAtivas) {
      DateTime horarioRefeicao = DateTime(
        now.year,
        now.month,
        now.day,
        refeicao.horario.hour,
        refeicao.horario.minute,
      );

      if (horarioRefeicao.isBefore(now)) {
        horarioRefeicao = horarioRefeicao.add(const Duration(days: 1));
      }

      final diferenca = horarioRefeicao.difference(now);

      if (menorDiferenca == null || diferenca < menorDiferenca) {
        menorDiferenca = diferenca;
        proximaRefeicao = refeicao;
      }
    }

    if (proximaRefeicao == null || menorDiferenca == null) return null;
    return MapEntry(proximaRefeicao, menorDiferenca);
  }
}
