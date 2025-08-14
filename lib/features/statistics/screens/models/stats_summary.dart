class StatisticsSummary {
  final double totalCost;
  final double totalDistance;
  final int activeVehicles;
  final double averageEfficiency;
  final Map<String, double> costBredown;
  final List<MonthlyTrend> monthlyTrends;

  StatisticsSummary({
    required this.totalCost,
    required this.totalDistance,
    required this.activeVehicles,
    required this.averageEfficiency,
    required this.costBredown,
    required this.monthlyTrends,
  });

  factory StatisticsSummary.fromJson(Map<String, dynamic> json) {
    return StatisticsSummary(
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      totalDistance: (json['totalDistance'] ?? 0).toDouble(),
      activeVehicles: json['activeVehicles'] ?? 0,
      averageEfficiency: (json['averageEfficiency'] ?? 0).toDouble(),
      costBredown: Map<String, double>.from(json['costBredown'] ?? {}),
      monthlyTrends: (json['monthlyTrends'] as List<dynamic>? ?? [])
          .map((trend) => MonthlyTrend.fromJson(trend))
          .toList(),
    );
  }
}

class MonthlyTrend {
  final String month;
  final double cost;
  final double km;

  MonthlyTrend({
    required this.month,
    required this.cost,
    required this.km,
  });

  factory MonthlyTrend.fromJson(Map<String, dynamic> json) {
    return MonthlyTrend(
      month: json['month'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      km: (json['km'] ?? 0).toDouble(),
    );
  }
}