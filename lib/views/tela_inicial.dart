import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/viewmodels/inicial_viewmodel.dart';
import 'package:projeto_integrador2/utils/cores.dart';

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
                    onTap: () async {
                      final novoValor = await _mostrarDialogoAgua(
                        context,
                        viewModel.aguaConsumidaHoje,
                      );
                      if (novoValor != null) {
                        await viewModel.atualizarAguaConsumida(novoValor);
                      }
                    },
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
                    onTap: () async {
                      final novoValor = await _mostrarDialogoRacao(
                        context,
                        viewModel.racaoConsumidaHoje,
                      );
                      if (novoValor != null) {
                        await viewModel.atualizarRacaoConsumida(novoValor);
                      }
                    },
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
                    alertText: 'Ração baixa',
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

  // ============== Diálogo pra editar ração consumida ==============

  Future<double?> _mostrarDialogoRacao(
      BuildContext context, double valorAtual) async {
    final controller = TextEditingController(
      text: valorAtual.toStringAsFixed(0),
    );

    return showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Atualizar ração consumida'),
          content: TextField(
            controller: controller,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Quantidade (g)',
              hintText: 'Ex: 100',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final raw = controller.text.trim().replaceAll(',', '.');
                final valor = double.tryParse(raw);
                Navigator.of(ctx).pop(valor);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // ============== Diálogo pra editar água consumida ==============

  Future<double?> _mostrarDialogoAgua(
      BuildContext context, double valorAtual) async {
    final controller = TextEditingController(
      text: valorAtual.toStringAsFixed(0),
    );

    return showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Atualizar água consumida'),
          content: TextField(
            controller: controller,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Quantidade (ml)',
              hintText: 'Ex: 200',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final raw = controller.text.trim().replaceAll(',', '.');
                final valor = double.tryParse(raw);
                Navigator.of(ctx).pop(valor);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // =================== UI Helpers ===================

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
                  rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        );
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Seg', style: style);
                          case 1:
                            return const Text('Ter', style: style);
                          case 2:
                            return const Text('Qua', style: style);
                          case 3:
                            return const Text('Qui', style: style);
                          case 4:
                            return const Text('Sex', style: style);
                          case 5:
                            return const Text('Sáb', style: style);
                          case 6:
                            return const Text('Dom', style: style);
                          default:
                            return const Text('', style: style);
                        }
                      },
                    ),
                  ),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String meta,
    required double progress,
    required Color progressColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
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
                  style: const TextStyle(
                      color: corPretoAzulado, fontWeight: FontWeight.bold),
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
              style: TextStyle(
                color: corPretoAzulado.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
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
                style: const TextStyle(
                    color: corPretoAzulado, fontWeight: FontWeight.bold),
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
            style: TextStyle(
              color: corPretoAzulado.withOpacity(0.7),
              fontSize: 12,
            ),
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
                style: const TextStyle(
                    color: corPretoAzulado, fontWeight: FontWeight.bold),
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
            child: const Text(
              'Ração baixa',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            actionText,
            style: TextStyle(
              color: corPretoAzulado.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10.5),
        ],
      ),
    );
  }
}
