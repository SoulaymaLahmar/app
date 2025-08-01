import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../utils/app_textstyles.dart';

class StatisticsScreen extends StatelessWidget {
  StatisticsScreen({super.key});

  final List<Map<String, dynamic>> costSummary = [
    {"label": "Carburant", "value": 1200.0, "color": Colors.orange[400]},
    {"label": "Entretien", "value": 800.0, "color": Colors.blue[400]},
    {"label": "Assurance", "value": 300.0, "color": Colors.green[400]},
    {"label": "Réparation", "value": 500.0, "color": Colors.red[400]},
  ];

  final List<Map<String, dynamic>> vehiclePerformance = [
    {"vehicle": "Peugeot 208", "km": 15200, "conso": 6.5},
    {"vehicle": "Renault Clio", "km": 9800, "conso": 7.2},
    {"vehicle": "Ford Focus", "km": 17800, "conso": 5.9},
  ];

  final List<Map<String, dynamic>> driverStats = [
    {"name": "Mohamed Ben Ali", "km": 12000, "note": 87},
    {"name": "Hichem Trabelsi", "km": 8900, "note": 72},
    {"name": "Sami Jouini", "km": 10100, "note": 93},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: textColor),
        ),
        title: Text(
          'Rapports et Analyses',
          style: AppTextStyle.withColor(AppTextStyle.h3, textColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Résumé des Coûts", Icons.pie_chart, textColor),
          _buildCostChart(cardColor!, isDark),

          const SizedBox(height: 24),
          _sectionTitle("Performance des Véhicules", Icons.speed, textColor),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: vehiclePerformance.map((e) => _buildVehicleCard(e, cardColor)).toList(),
          ),

          const SizedBox(height: 24),
          _sectionTitle("Comparaison des Conducteurs", Icons.people_alt, textColor),
          const SizedBox(height: 32),
          _buildDriverComparisonChart(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyle.h3.copyWith(fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCostChart(Color cardColor, bool isDark) {
    final total = costSummary.fold<double>(0, (sum, i) => sum + (i['value'] as double));
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      color: cardColor,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: costSummary.map((e) {
                    final value = e['value'] as double;
                    final percentage = ((value / total) * 100).toStringAsFixed(1);
                    return PieChartSectionData(
                      value: value,
                      color: e['color'],
                      title: "$percentage%",
                      radius: 50,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(enabled: true),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: costSummary.map((e) {
                return Chip(
                  avatar: CircleAvatar(backgroundColor: e['color'], radius: 6),
                  label: Text("${e['label']} (${e['value']} TND)", style: const TextStyle(fontWeight: FontWeight.w500)),
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  shape: const StadiumBorder(),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> data, Color cardColor) {
    final double maxKm = 20000;
    final double km = data['km'] * 1.0;
    final double progress = (km / maxKm).clamp(0.0, 1.0);
    final double conso = data['conso'];

    Color consoColor;
    if (conso < 6.0) {
      consoColor = Colors.green;
    } else if (conso <= 7.0) {
      consoColor = Colors.orange;
    } else {
      consoColor = Colors.red;
    }

    return SizedBox(
      width: 160,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.directions_car, color: Colors.blue, size: 28),
              const SizedBox(height: 8),
              Text(data['vehicle'], style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Km parcourus"),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey[300],
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 4),
              Text("${data['km']} km", style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_gas_station, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "${data['conso']} L/100km",
                    style: TextStyle(color: consoColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverComparisonChart() {
    final double maxKm = driverStats.map((d) => d['km'] as int).reduce((a, b) => a > b ? a : b).toDouble();
    final double maxNote = driverStats.map((d) => d['note'] as int).reduce((a, b) => a > b ? a : b).toDouble();
    final double scaledMaxNote = maxNote * 150.0;
    final double maxY = (maxKm > scaledMaxNote) ? maxKm : scaledMaxNote;
    final double barWidth = 8;

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              maxY: maxY + 1000,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.grey[800],
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem("${rod.toY.toInt()}", const TextStyle(color: Colors.white)),
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index < 0 || index >= driverStats.length) return const SizedBox.shrink();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(driverStats[index]['name'].split(' ')[0], style: const TextStyle(fontSize: 12)),
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 3000,
                    getTitlesWidget: (value, _) => Text('${value.toInt()}'),
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true, horizontalInterval: 3000),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(driverStats.length, (index) {
                final driver = driverStats[index];
                final km = driver['km'] * 1.0;
                final note = driver['note'] * 150.0;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(toY: km, width: barWidth, color: Colors.blueAccent, borderRadius: BorderRadius.circular(4)),
                    BarChartRodData(toY: note, width: barWidth, color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                  ],
                  barsSpace: 6,
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.blueAccent, "Km parcourus"),
            const SizedBox(width: 24),
            _buildLegendItem(Colors.amber, "Note (x150)"),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
