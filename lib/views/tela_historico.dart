import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/viewmodels/historico_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projeto_integrador2/utils/cores.dart';

class TelaHistorico extends StatelessWidget {
  const TelaHistorico({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoricoViewModel()..fetchData(),
      child: Scaffold(
        backgroundColor: corOffWhite,
        appBar: AppBar(
          title: const Text('Histórico de Consumo'),
          backgroundColor: corVerdeAgua.withOpacity(0.5),
          foregroundColor: corPretoAzulado,
          elevation: 0,
          centerTitle: true,
        ),
        body: Consumer<HistoricoViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildChartCard(context, viewModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, HistoricoViewModel viewModel) {
    final bool isDailyView = viewModel.currentView == ChartViewType.daily;
    final String cardTitle = isDailyView ? 'Consumo Diário (7 dias)' : 'Consumo Semanal (4 Semanas)';
    final List<Map<String, dynamic>> chartData = isDailyView ? viewModel.dailyConsumption : viewModel.weeklyConsumption;
    final List<bool> isSelected = [isDailyView, !isDailyView];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: corVerdeAgua.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(cardTitle,
                  style: const TextStyle(
                      color: corPretoAzulado,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(
                  viewModel.isChartView ? Icons.list : Icons.bar_chart,
                  color: corPretoAzulado,
                ),
                onPressed: () {
                  viewModel.toggleDisplayMode();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return ToggleButtons(
                isSelected: isSelected,
                onPressed: (int index) {
                  final newView = index == 0 ? ChartViewType.daily : ChartViewType.weekly;
                  viewModel.changeView(newView);
                },
                borderRadius: BorderRadius.circular(8.0),
                selectedBorderColor: corPretoAzulado,
                selectedColor: Colors.white,
                fillColor: corPretoAzulado.withOpacity(0.8),
                color: corPretoAzulado,
                constraints: BoxConstraints.expand(
                  width: (constraints.maxWidth / 2) - 2,
                  height: 40,
                ),
                children: const [
                  Text('Diário'),
                  Text('Semanal'),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: viewModel.isChartView
                ? SizedBox(
              key: const ValueKey('chart'),
              height: 200,
              child: _buildBarChart(context, chartData, isDailyView),
            )
                : Container(
              key: const ValueKey('list'),
              child: _buildConsumptionList(chartData, isDailyView),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionList(List<Map<String, dynamic>> data, bool isDailyView) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (context, index) => Divider(color: corPretoAzulado.withOpacity(0.2)),
      itemBuilder: (context, index) {
        final item = data[index];
        final String title = isDailyView ? item['day'] : item['week'];
        final String value = _formatValue((item['value'] as num).toDouble(), isDailyView);
        return ListTile(
          dense: true,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: corPretoAzulado)),
          trailing: Text(value, style: const TextStyle(fontSize: 16, color: corPretoAzulado)),
        );
      },
    );
  }

  String _formatValue(double value, bool isDailyView) {
    if (!isDailyView && value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}kg';
    }
    return '${value.toInt()}g';
  }

  Widget _buildBarChart(BuildContext context, List<Map<String, dynamic>> data, bool isDailyView) {
    if (data.isEmpty) return const Center(child: Text("Sem dados."));

    final maxValue = data.map((e) => e['value'] as num).reduce((a, b) => a > b ? a : b).toDouble();
    final yInterval = _calculateYInterval(maxValue);
    final chartMaxY = (maxValue / yInterval).ceil() * yInterval;

    String getBottomTitle(double value) {
      if (isDailyView) {
        return data[value.toInt()]['day'];
      } else {
        return data[value.toInt()]['week'];
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMaxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: yInterval,
              getTitlesWidget: (value, meta) {
                if (value > meta.max) return const Text('');
                return Text(_formatValue(value, isDailyView),
                    style: const TextStyle(color: corPretoAzulado, fontSize: 10));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(getBottomTitle(value),
                    style: const TextStyle(
                        color: corPretoAzulado,
                        fontWeight: FontWeight.bold,
                        fontSize: 14));
              },
            ),
          ),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (item['value'] as num).toDouble(),
                color: corPretoAzulado,
                width: 22,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _calculateYInterval(double max) {
    if (max <= 150) return 30;
    if (max <= 300) return 50;
    if (max <= 800) return 200;
    if (max <= 2000) return 500;
    if (max <= 4000) return 1000;
    return 1000;
  }
}