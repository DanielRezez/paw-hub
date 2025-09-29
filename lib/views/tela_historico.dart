import 'package:fl_chart/fl_chart.dart';
import 'package:projeto_integrador2/utils/app_exports.dart'; // Import centralizado

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
          backgroundColor: corBeringela,
          foregroundColor: corBrancoPuro,
          elevation: 0,
          centerTitle: true,
        ),
        body: Consumer<HistoricoViewModel>(
          builder: (context, viewModel, child) {
            final bool isDailyView = viewModel.currentView == ChartViewType.daily;

            final feedData = isDailyView ? viewModel.feedDataDaily : viewModel.feedDataWeekly;
            final waterData = isDailyView ? viewModel.waterDataDaily : viewModel.waterDataWeekly;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildControlsCard(context, viewModel),
                  const SizedBox(height: 16),

                  _buildConsumptionCard(
                    context: context,
                    viewModel: viewModel,
                    title: 'Consumo de Ração',
                    icon: Icons.restaurant_menu_outlined,
                    data: feedData,
                    barColor: Colors.amber.shade800,
                    isFeed: true,
                  ),
                  const SizedBox(height: 16),

                  _buildConsumptionCard(
                    context: context,
                    viewModel: viewModel,
                    title: 'Consumo de Água',
                    icon: Icons.water_drop_outlined,
                    data: waterData,
                    barColor: Colors.blue.shade700,
                    isFeed: false,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlsCard(BuildContext context, HistoricoViewModel viewModel) {
    final bool isDailyView = viewModel.currentView == ChartViewType.daily;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: corVerdeAgua,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ToggleButtons(
                  isSelected: [isDailyView, !isDailyView],
                  onPressed: (index) => viewModel.changeView(index == 0 ? ChartViewType.daily : ChartViewType.weekly),
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
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(viewModel.isChartView ? Icons.list : Icons.bar_chart, color: corPretoAzulado),
            onPressed: () => viewModel.toggleDisplayMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionCard({
    required BuildContext context,
    required HistoricoViewModel viewModel,
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> data,
    required Color barColor,
    required bool isFeed,
  }) {
    final bool isDailyView = viewModel.currentView == ChartViewType.daily;
    final String periodText = isDailyView ? "Últimos 7 dias" : "Últimas 4 semanas";
    final String fullTitle = '$title - $periodText';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: corVerdeAgua,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: barColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(fullTitle,
                    style: TextStyle(
                        color: corPretoAzulado,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: viewModel.isChartView
                ? SizedBox(
              key: ValueKey('$title-chart'),
              height: 200,
              child: _buildBarChart(data, isDailyView, isFeed, barColor),
            )
                : Container(
              key: ValueKey('$title-list'),
              child: _buildConsumptionList(data, isDailyView, isFeed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionList(List<Map<String, dynamic>> data, bool isDailyView, bool isFeed) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (context, index) => Divider(color: corPretoAzulado.withOpacity(0.2)),
      itemBuilder: (context, index) {
        final item = data[index];
        final String title = isDailyView ? item['day'] : item['week'];
        final String value = _formatValue((item['value'] as num).toDouble(), isDailyView, isFeed);
        return ListTile(
          dense: true,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: corPretoAzulado)),
          trailing: Text(value, style: const TextStyle(fontSize: 16, color: corPretoAzulado)),
        );
      },
    );
  }

  String _formatValue(double value, bool isDailyView, bool isFeed) {
    if (isFeed) {
      return isDailyView ? '${value.toInt()}g' : '${(value / 1000).toStringAsFixed(1)}kg';
    } else {
      return isDailyView ? '${value.toInt()}ml' : '${(value / 1000).toStringAsFixed(1)}L';
    }
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data, bool isDailyView, bool isFeed, Color barColor) {
    if (data.isEmpty) return const Center(child: Text("Sem dados."));

    final maxValue = data.map((e) => e['value'] as num).reduce((a, b) => a > b ? a : b).toDouble();
    final yInterval = _calculateYInterval(maxValue);
    final chartMaxY = (maxValue / yInterval).ceil() * yInterval;

    String getBottomTitle(double value) {
      if (value.toInt() < 0 || value.toInt() >= data.length) return ''; // Proteção
      return isDailyView ? data[value.toInt()]['day'] : data[value.toInt()]['week'];
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
                if (value > meta.max || value < meta.min) return const Text(''); // Proteção
                return Text(_formatValue(value, isDailyView, isFeed),
                    style: const TextStyle(color: corPretoAzulado, fontSize: 10));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                 if (value.toInt() < 0 || value.toInt() >= data.length) return const Text(''); // Proteção
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
                color: barColor,
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
    if (max <= 0) return 10; // Evita divisão por zero ou intervalo zero se max for 0 ou negativo
    if (max <= 150) return 30;
    if (max <= 300) return 50;
    if (max <= 1000) return 200;
    if (max <= 2000) return 500;
    if (max <= 6000) return 1000;
    return 2000;
  }
}
