import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math'; // Para gerar IDs únicos simples

// Modelo para Refeição Programada
class RefeicaoProgramada {
  TimeOfDay horario;
  String quantidade;
  bool ativa;
  String id; // ID único para cada refeição

  RefeicaoProgramada({
    required this.horario,
    required this.quantidade,
    required this.ativa,
    required this.id,
  });
}

class TelaAgendaViewModel extends ChangeNotifier {
  // Agora uma lista dinâmica, não mais com 3 slots fixos.
  final List<RefeicaoProgramada> _perfilHorarios = [];

  List<RefeicaoProgramada> get perfilHorarios => _perfilHorarios;

  // --- ESTA É A CORREÇÃO ---
  // O construtor agora é "limpo" e não chama mais código async
  TelaAgendaViewModel() {
    // carregarPerfil(); <-- LINHA REMOVIDA
    // O carregamento agora é feito pelo "dono" do ViewModel
    // (neste caso, os nossos testes ou a sua Tela).
  }

  // Chaves base para SharedPreferences
  static const String _keyNumeroRefeicoes = 'numero_refeicoes';
  String _keyHorarioHour(int index) => 'refeicao_${index}_horario_hour';
  String _keyHorarioMinute(int index) => 'refeicao_${index}_horario_minute';
  String _keyQuantidade(int index) => 'refeicao_${index}_quantidade';
  String _keyAtiva(int index) => 'refeicao_${index}_ativa';
  String _keyId(int index) => 'refeicao_${index}_id';


  Future<void> carregarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    _perfilHorarios.clear(); // Limpa a lista antes de carregar

    final int? numeroDeRefeicoes = prefs.getInt(_keyNumeroRefeicoes);

    if (numeroDeRefeicoes != null && numeroDeRefeicoes > 0) {
      for (int i = 0; i < numeroDeRefeicoes; i++) {
        final hour = prefs.getInt(_keyHorarioHour(i));
        final minute = prefs.getInt(_keyHorarioMinute(i));
        final quantidade = prefs.getString(_keyQuantidade(i));
        final ativa = prefs.getBool(_keyAtiva(i));
        final id = prefs.getString(_keyId(i));

        if (hour != null && minute != null && quantidade != null && ativa != null && id != null) {
          _perfilHorarios.add(RefeicaoProgramada(
            horario: TimeOfDay(hour: hour, minute: minute),
            quantidade: quantidade,
            ativa: ativa,
            id: id,
          ));
        }
      }
    }
    notifyListeners();
    print("Perfil de horários carregado do SharedPreferences. Total: ${_perfilHorarios.length}");
  }

  Future<bool> salvarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setInt(_keyNumeroRefeicoes, _perfilHorarios.length);

      for (int i = 0; i < _perfilHorarios.length; i++) {
        final refeicao = _perfilHorarios[i];
        await prefs.setInt(_keyHorarioHour(i), refeicao.horario.hour);
        await prefs.setInt(_keyHorarioMinute(i), refeicao.horario.minute);
        await prefs.setString(_keyQuantidade(i), refeicao.quantidade);
        await prefs.setBool(_keyAtiva(i), refeicao.ativa);
        await prefs.setString(_keyId(i), refeicao.id);
      }
      // Se houveram mais refeições salvas anteriormente do que agora, precisamos limpar as antigas.
      // Isso é importante se o usuário deletou refeições.
      int? totalSalvoAnteriormente = prefs.getInt('total_refeicoes_salvas_anteriormente'); // Chave auxiliar
      if (totalSalvoAnteriormente != null) {
        for (int i = _perfilHorarios.length; i < totalSalvoAnteriormente; i++) {
          await prefs.remove(_keyHorarioHour(i));
          await prefs.remove(_keyHorarioMinute(i));
          await prefs.remove(_keyQuantidade(i));
          await prefs.remove(_keyAtiva(i));
          await prefs.remove(_keyId(i));
        }
      }
      await prefs.setInt('total_refeicoes_salvas_anteriormente', _perfilHorarios.length);


      print("Perfil de horários salvo no SharedPreferences. Total: ${_perfilHorarios.length}");
      notifyListeners();
      return true;
    } catch (e) {
      print("Erro ao salvar perfil no SharedPreferences: $e");
      return false;
    }
  }

  // --- MÉTODOS CRUD ---

  // CREATE: Adicionar uma nova refeição programada
  void adicionarNovaRefeicao() {
    // Cria um ID único simples (para este exemplo)
    String novoId = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();
    _perfilHorarios.add(
      RefeicaoProgramada(
        horario: TimeOfDay.now(), // Horário atual como padrão
        quantidade: "", // Quantidade vazia
        ativa: true, // Ativa por padrão
        id: novoId,
      ),
    );
    notifyListeners();
    // O salvamento ocorrerá quando o usuário clicar em "Salvar Configurações"
  }

  // DELETE: Remover uma refeição programada
  void removerRefeicaoDefinitivamente(int index) {
    if (index < 0 || index >= _perfilHorarios.length) return;
    _perfilHorarios.removeAt(index);
    notifyListeners();
    // O salvamento (e a efetiva remoção do SharedPreferences) ocorrerá
    // quando o usuário clicar em "Salvar Configurações", pois o salvarPerfil
    // irá salvar a lista atual, que é menor.
  }


  // --- MÉTODOS DE ATUALIZAÇÃO (UPDATE) ---
  // (Estes permanecem os mesmos, mas operam sobre a lista dinâmica)

  void atualizarHorarioRefeicao(int index, TimeOfDay novoHorario) {
    if (index < 0 || index >= _perfilHorarios.length) return;
    _perfilHorarios[index].horario = novoHorario;
    notifyListeners();
  }

  void atualizarQuantidadeRefeicao(int index, String novaQuantidade) {
    if (index < 0 || index >= _perfilHorarios.length) return;
    _perfilHorarios[index].quantidade = novaQuantidade;
    notifyListeners();
  }

  void toggleAtivacaoRefeicao(int index) {
    if (index < 0 || index >= _perfilHorarios.length) return;
    _perfilHorarios[index].ativa = !_perfilHorarios[index].ativa;
    notifyListeners();
  }
}