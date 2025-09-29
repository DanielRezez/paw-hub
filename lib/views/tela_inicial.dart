import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/viewmodels/inicial_viewmodel.dart'; // IMPORTA O VIEWMODEL
import 'package:projeto_integrador2/utils/cores.dart';
// lib/views/tela_inicial.dart

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InicialViewModel>(context);

    return Scaffold(
      backgroundColor: corOffWhite,
      appBar: AppBar(
        backgroundColor: corBeringela,
        foregroundColor: corBrancoPuro,
        elevation: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PetHub Monitor',
              style: TextStyle(
                color: corBrancoPuro,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Cuidando do seu melhor amigo',
              style: TextStyle(
                color: corBrancoPuro.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.water_drop_outlined,
                    title: 'Água Hoje',
                    value: viewModel.aguaConsumidaFormatada,
                    meta: viewModel.metaAguaFormatada,
                    progress: viewModel.progressoAgua,
                    progressColor: Colors.blue.shade300,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Ração Hoje',
                    value: viewModel.racaoConsumidaFormatada,
                    meta: viewModel.metaRacaoFormatada,
                    progress: viewModel.progressoRacao,
                    progressColor: Colors.orange.shade300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSimpleInfoCard(
                    icon: Icons.timer_outlined,
                    title: 'Próxima Refeição',
                    value: viewModel.proximaRefeicao,
                    subtitle: viewModel.tempoAteProximaRefeicao,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAlertCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Alertas',
                    alertText: 'Água baixa',
                    actionText: 'Reabastecer tigela',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWeeklyChartCard(viewModel.consumoSemanalSpots),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Visão Geral',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
        currentIndex: viewModel.selectedIndex,
        onTap: (index) {
          viewModel.onItemTapped(index, context);
        },
        selectedItemColor: corPretoAzulado,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
      ),
    );
  }

  // ... Os outros métodos de build (_buildInfoCard, etc) continuam aqui ...
  // ... _buildInfoCard, _buildSimpleInfoCard, _buildAlertCard ...
  // A única mudança é no _buildWeeklyChartCard abaixo
  // A função bottomTitleWidgets foi REMOVIDA

  Widget _buildWeeklyChartCard(List<FlSpot> spots) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: corVerdeAgua,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consumo Semanal',
            style: TextStyle(
                color: corPretoAzulado,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 80,
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  // ======================= MUDANÇA AQUI =======================
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      // A lógica da função foi movida para cá
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = const Text('Seg', style: style);
                            break;
                          case 1:
                            text = const Text('Ter', style: style);
                            break;
                          case 2:
                            text = const Text('Qua', style: style);
                            break;
                          case 3:
                            text = const Text('Qui', style: style);
                            break;
                          case 4:
                            text = const Text('Sex', style: style);
                            break;
                          case 5:
                            text = const Text('Sáb', style: style);
                            break;
                          case 6:
                            text = const Text('Dom', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        // Agora a gente retorna SÓ O TEXTO, sem o SideTitleWidget
                        return text;
                      },
                    ),
                  ),
                  // ==================== FIM DA MUDANÇA ====================
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 320,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: corPretoAzulado,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cole os outros métodos de build aqui se precisar
  // _buildInfoCard, _buildSimpleInfoCard, _buildAlertCard
  // Só não precisa mais do bottomTitleWidgets
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String meta,
    required double progress,
    required Color progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: corVerdeAgua,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: corPretoAzulado, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: corPretoAzulado, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: corPretoAzulado,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            meta,
            style: TextStyle(color: corPretoAzulado.withOpacity(0.7), fontSize: 12),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 26.5),
      decoration: BoxDecoration(
        color: corVerdeAgua,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: corPretoAzulado, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: corPretoAzulado, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: corPretoAzulado,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(color: corPretoAzulado.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required String title,
    required String alertText,
    required String actionText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: corVerdeAgua,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: corPretoAzulado, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: corPretoAzulado, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: corBeringela,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              alertText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            actionText,
            style: TextStyle(color: corPretoAzulado.withOpacity(0.9), fontSize: 13),
          ),
          const SizedBox(height: 10.5),
        ],
      ),
    );
  }
}