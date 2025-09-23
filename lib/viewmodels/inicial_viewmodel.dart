import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projeto_integrador2/views/tela_agenda.dart';
import 'package:projeto_integrador2/views/tela_configuracoes.dart';
import 'package:provider/provider.dart';

import 'auth_viewmodel.dart';
import 'configuracoes_viewmodel.dart';
import 'agenda_viewmodel.dart';

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
  void onItemTapped(int index, BuildContext context) { // <<< ADICIONE BuildContext context
    if (_selectedIndex == index && index == 3) {
      // Se o usuário já está na tela de configurações (ou a lógica que a representa)
      // e clica nela de novo, não faz nada para evitar empilhar a mesma tela várias vezes.
      // Você pode ajustar essa lógica se precisar de um comportamento diferente.
      return;
    }

    _selectedIndex = index;

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
      case 3: // Config
        print("Item 'Config' selecionado. Navegando para TelaConfiguracoes...");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<ConfiguracoesViewModel>(
              create: (context) {
                // Obtém o AuthViewModel já fornecido para passá-lo ao ConfiguracoesViewModel
                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                return ConfiguracoesViewModel(authViewModel);
              },
              child: TelaConfiguracoes(), // Remova o const se não for mais necessário
            ),
          ),
        );
        // IMPORTANTE: Se você navega para uma nova tela CHEIA (como TelaConfiguracoes),
        // você geralmente NÃO quer que o _selectedIndex permaneça 3 quando voltar,
        // pois a TelaInicial será a tela "por baixo".
        // Considere resetar o _selectedIndex para o índice da tela principal (ex: 0)
        // APÓS o Navigator.push, ou não atualizar o _selectedIndex aqui se a navegação
        // for para uma tela completamente diferente que cobre a TelaInicial.
        // Se a TelaConfiguracoes for uma sub-view DENTRO da TelaInicial, então manter
        // _selectedIndex = 3 faz sentido.
        //
        // Para o seu caso, como TelaConfiguracoes é uma nova tela via MaterialPageRoute,
        // o BottomNavigationBar da TelaInicial não será visível na TelaConfiguracoes.
        // Quando você voltar da TelaConfiguracoes, o _selectedIndex ainda será 3,
        // o que pode ou não ser o desejado.
        //
        // Uma abordagem comum é que o BottomNavigationBar controle apenas as seções
        // PRINCIPAIS da tela atual. Se "Configurações" é uma tela totalmente separada,
        // talvez não devesse mudar o selectedIndex da TelaInicial, ou deveria
        // ser acessada por um botão diferente (ex: no AppBar).
        //
        // Se você quer que o item "Config" fique selecionado E navegue, o código atual
        // está bom. Apenas esteja ciente do comportamento do selectedIndex ao voltar.
        break;
      default:
        print("Índice de item desconhecido: $index");
    }

    // Você só precisa chamar notifyListeners se a própria TelaInicial
    // muda sua UI com base no _selectedIndex (além do destaque do BottomNav).
    // Se você está navegando para telas completamente diferentes,
    // o notifyListeners aqui pode não ser estritamente necessário para a navegação em si,
    // mas ainda é útil para atualizar o item destacado no BottomNav.
    notifyListeners();
  }
}