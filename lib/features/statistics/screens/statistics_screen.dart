import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../utils/app_textstyles.dart';
import '../controllers/statistics_controller.dart';

class StatisticsScreen extends StatefulWidget {
  StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _slideAnimation;
  Animation<double>? _fadeAnimation;

  final StatisticsController controller = Get.put(StatisticsController());
  final List<String> periods = ["Ce mois", "3 mois", "6 mois", "Année"];

  @override
  void initState() {
    super.initState();
    controller.loadData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );

    _animationController!.forward();
  }

  @override
  void dispose() {
    Get.delete<StatisticsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Color(0xFF0D1421) : Color(0xFFF8FAFC);
    final cardColor = isDark ? Color(0xFF1A1D29) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController ?? kAlwaysCompleteAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation?.value ?? 0),
              child: Opacity(
                opacity: _fadeAnimation?.value ?? 1,
                child: Column(
                  children: [
                    _buildHeader(context, textColor, isDark),
                    _buildPeriodSelector(isDark),
                    Expanded(
                      child: GetBuilder<StatisticsController>(
                        builder: (controller) {
                          if (controller.isLoading.value) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: controller.loadData,
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildKPICards(cardColor, textColor, isDark),
                                const SizedBox(height: 24),
                                _buildCostAnalysis(cardColor, textColor, isDark),
                                const SizedBox(height: 24),
                                _buildTrendsChart(cardColor, textColor, isDark),
                                const SizedBox(height: 24),
                                _buildVehiclePerformance(cardColor, textColor, isDark),
                                const SizedBox(height: 24),
                                _buildDriverComparison(cardColor, textColor, isDark),
                                const SizedBox(height: 24),
                                _buildInsights(cardColor, textColor, isDark),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back_ios_new, color: textColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tableau de Bord',
                  style: AppTextStyle.withColor(
                    AppTextStyle.h2.copyWith(fontWeight: FontWeight.bold),
                    textColor,
                  ),
                ),
                Text(
                  'Analyses et Rapports',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyMedium,
                    textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.analytics_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
      child: GetBuilder<StatisticsController>(
        id: 'period-selector', // Add specific ID for targeted updates
        builder: (controller) => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: periods.length,
          itemBuilder: (context, index) {
            final isSelected = controller.selectedPeriod.value == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () => controller.changePeriod(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                      )
                          : null,
                      color: isSelected
                          ? null
                          : isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(25),
                      border: isSelected
                          ? null
                          : Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      periods[index],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isDark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKPICards(Color cardColor, Color textColor, bool isDark) {
    return GetBuilder<StatisticsController>(
      id: 'kpi-cards', // Add specific ID
      builder: (controller) {
        final totalCostTrend = "+12%"; // You can calculate this from historical data
        final distanceTrend = "+8%";
        final vehiclesTrend = "0%";
        final efficiencyTrend = "+5%";

        final kpis = [
          {
            "title": "Coût Total",
            "value": "${controller.totalCost.toStringAsFixed(0)}",
            "unit": "TND",
            "icon": Icons.account_balance_wallet,
            "color": Color(0xFF4ECDC4),
            "trend": totalCostTrend
          },
          {
            "title": "Distance",
            "value": "${(controller.totalDistance / 1000).toStringAsFixed(1)}",
            "unit": "K KM",
            "icon": Icons.route,
            "color": Color(0xFF45B7D1),
            "trend": distanceTrend
          },
          {
            "title": "Véhicules",
            "value": "${controller.activeVehiclesCount}",
            "unit": "Actifs",
            "icon": Icons.directions_car,
            "color": Color(0xFFFF6B6B),
            "trend": vehiclesTrend
          },
          {
            "title": "Efficiency",
            "value": "${controller.averageEfficiency.toStringAsFixed(0)}",
            "unit": "%",
            "icon": Icons.eco,
            "color": Color(0xFF96CEB4),
            "trend": efficiencyTrend
          },
        ];

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: kpis.length,
            itemBuilder: (context, index) {
              final kpi = kpis[index];
              final isPositive = kpi['trend'].toString().startsWith('+');

              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cardColor,
                      cardColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (kpi['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              kpi['icon'] as IconData,
                              color: kpi['color'] as Color,
                              size: 20,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              kpi['trend'] as String,
                              style: TextStyle(
                                color: isPositive ? Colors.green : Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        "${kpi['value']} ${kpi['unit']}",
                        style: AppTextStyle.withColor(
                          AppTextStyle.h3.copyWith(fontWeight: FontWeight.bold),
                          textColor,
                        ),
                      ),
                      Text(
                        kpi['title'] as String,
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodySmall,
                          textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCostAnalysis(Color cardColor, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.pie_chart, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Répartition des Coûts',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h3.copyWith(fontWeight: FontWeight.bold),
                        textColor,
                      ),
                    ),
                    Text(
                      'Analyse détaillée par catégorie',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GetBuilder<StatisticsController>(
            id: 'cost-analysis', // Add specific ID
            builder: (controller) {
              final costSummary = controller.costSummary;
              if (costSummary.isEmpty) {
                return Center(
                  child: Text(
                    'Aucune donnée de coût disponible',
                    style: TextStyle(color: textColor.withOpacity(0.6)),
                  ),
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 35,
                          startDegreeOffset: -90,
                          sections: costSummary.map((e) {
                            final total = costSummary.fold<double>(0, (sum, i) => sum + (i['value'] as double));
                            final value = e['value'] as double;
                            final percentage = total > 0 ? ((value / total) * 100).toStringAsFixed(1) : '0.0';
                            return PieChartSectionData(
                              value: value,
                              color: e['color'],
                              title: "$percentage%",
                              radius: 45,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: costSummary.map((e) {
                        final total = costSummary.fold<double>(0, (sum, i) => sum + (i['value'] as double));
                        final value = (e['value'] as num?)?.toDouble() ?? 0.0;
                        final percentage = total > 0
                            ? ((value / total) * 100).toStringAsFixed(1)
                            : '0.0';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: e['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  e['icon'],
                                  color: e['color'],
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e['label'],
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      "${value.toStringAsFixed(0)} TND ($percentage%)",
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.6),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsChart(Color cardColor, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.trending_up, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tendances Mensuelles',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h3.copyWith(fontWeight: FontWeight.bold),
                        textColor,
                      ),
                    ),
                    Text(
                      'Évolution des coûts et distances',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GetBuilder<StatisticsController>(
            id: 'trends-chart', // Add specific ID
            builder: (controller) {
              final monthlyTrends = controller.monthlyTrends;
              return SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 500,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= monthlyTrends.length) return const SizedBox();
                            return Text(
                              monthlyTrends[index]['month'],
                              style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
                          ),
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: monthlyTrends.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value['cost'].toDouble());
                        }).toList(),
                        isCurved: true,
                        gradient: LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Color(0xFF667eea),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclePerformance(Color cardColor, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.speed, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance des Véhicules',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h3.copyWith(fontWeight: FontWeight.bold),
                        textColor,
                      ),
                    ),
                    Text(
                      'Efficacité et consommation',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GetBuilder<StatisticsController>(
            id: 'vehicle-performance', // Add specific ID
            builder: (controller) {
              final vehiclePerformance = controller.vehiclePerformance;
              if (vehiclePerformance.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Aucun véhicule disponible',
                      style: TextStyle(color: textColor.withOpacity(0.6)),
                    ),
                  ),
                );
              }
              return Column(
                children: vehiclePerformance.map((vehicle) => _buildVehicleCard(vehicle, textColor, isDark)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle, Color textColor, bool isDark) {
    final efficiency = (vehicle['efficiency'] as int) / 100.0;
    final statusColor = vehicle['efficiency'] >= 85
        ? Colors.green
        : vehicle['efficiency'] >= 70
        ? Colors.orange
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.directions_car, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle['vehicle'],
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      vehicle['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${vehicle['efficiency']}%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  "Distance",
                  "${vehicle['km']} km",
                  Icons.route,
                  Colors.blue,
                  textColor,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetric(
                  "Consommation",
                  "${vehicle['conso'].toStringAsFixed(1)} L/100km",
                  Icons.local_gas_station,
                  Colors.orange,
                  textColor,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: efficiency,
            backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverComparison(Color cardColor, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.people_alt, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comparaison des Conducteurs',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h3.copyWith(fontWeight: FontWeight.bold),
                        textColor,
                      ),
                    ),
                    Text(
                      'Performance et éco-conduite',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GetBuilder<StatisticsController>(
            id: 'driver-comparison', // Add specific ID
            builder: (controller) {
              final driverStats = controller.driverStats;
              if (driverStats.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Aucun conducteur disponible',
                      style: TextStyle(color: textColor.withOpacity(0.6)),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          if (group.x >= driverStats.length) return null;
                          final driver = driverStats[group.x];
                          if (rodIndex == 0) {
                            return BarTooltipItem(
                              '${driver['name']}\nNote: ${rod.toY.toInt()}',
                              TextStyle(color: textColor, fontWeight: FontWeight.w600),
                            );
                          } else {
                            return BarTooltipItem(
                              'Éco-score: ${rod.toY.toInt()}',
                              TextStyle(color: textColor, fontWeight: FontWeight.w600),
                            );
                          }
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= driverStats.length) return const SizedBox();
                            final name = driverStats[index]['name'].toString().split(' ')[0];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: textColor.withOpacity(0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 20,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
                          ),
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: driverStats.asMap().entries.map((entry) {
                      final index = entry.key;
                      final driver = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: (driver['note'] as int).toDouble(),
                            gradient: LinearGradient(
                              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 15,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          BarChartRodData(
                            toY: (driver['eco_score'] as int).toDouble(),
                            gradient: LinearGradient(
                              colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 15,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                        barsSpace: 4,
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Color(0xFF4facfe), "Note de conduite", isDark),
              const SizedBox(width: 24),
              _buildLegendItem(Color(0xFF43e97b), "Éco-score", isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInsights(Color cardColor, Color textColor, bool isDark) {
    return GetBuilder<StatisticsController>(
      id: 'insights', // Add specific ID
      builder: (controller) {
        // Calculate dynamic insights based on real data
        final totalMaintenanceCost = controller.maintenanceRecords
            .fold(0.0, (sum, maintenance) => sum + maintenance.cout);

        final upcomingMaintenance = controller.vehicles
            .where((v) => v.etat == 'En maintenance')
            .length;

        final bestPerformingVehicle = controller.vehicles.isNotEmpty
            ? controller.vehicles.reduce((a, b) => a.efficiency > b.efficiency ? a : b)
            : null;

        final insights = [
          {
            "title": "Économie Potentielle",
            "value": "15%",
            "description": "Réduction possible des coûts de carburant avec une meilleure planification des trajets",
            "icon": Icons.savings,
            "color": Color(0xFF4CAF50),
          },
          {
            "title": "Maintenance Prédictive",
            "value": "$upcomingMaintenance véhicules",
            "description": "Nécessitent un entretien selon les données d'utilisation",
            "icon": Icons.build_circle,
            "color": Color(0xFFFF9800),
          },
          if (bestPerformingVehicle != null)
            {
              "title": "Performance Optimale",
              "value": "${bestPerformingVehicle.marque} ${bestPerformingVehicle.modele}",
              "description": "Véhicule le plus efficace avec une consommation de ${bestPerformingVehicle.consommation}L/100km",
              "icon": Icons.emoji_events,
              "color": Color(0xFF2196F3),
            },
        ];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.lightbulb, color: Color(0xFF6B73FF), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insights & Recommandations',
                          style: AppTextStyle.withColor(
                            AppTextStyle.h3.copyWith(fontWeight: FontWeight.bold),
                            textColor,
                          ),
                        ),
                        Text(
                          'Optimisations suggérées',
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodySmall,
                            textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...insights.map((insight) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ((insight['color'] as Color?) ?? Colors.transparent).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (insight['color'] as Color)?.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        insight['icon'] as IconData,
                        color: insight['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                insight['title'] as String,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (insight['color'] as Color)?.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  insight['value'] as String,
                                  style: TextStyle(
                                    color: insight['color'] as Color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insight['description'] as String,
                            style: TextStyle(
                              color: textColor.withOpacity(0.6),
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }
}