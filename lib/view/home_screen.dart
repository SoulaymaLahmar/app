import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import 'package:stage/controllers/theme_controller.dart';
import 'package:stage/features/statistics/screens/statistics_screen.dart';
import 'package:stage/features/notifications/view/notifications_screen.dart';
import 'package:stage/view/widgets/custom_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectMonth() async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedMonth = DateFormat.yMMMM('fr_FR').format(selectedDate);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildStatCards(),
                const SizedBox(height: 30),
                _buildMonthlyStats(formattedMonth),
                _buildRecentVehicles(),
                _buildRecentActivities(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage('assets/images/account_img.jpg'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Tableau de bord', style: TextStyle(color: Colors.grey, fontSize: 15)),
              Text('Soulayma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.to(() =>  NotificationsScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: () => Get.to(() =>  StatisticsScreen()),
          ),
          GetBuilder<ThemeController>(
            builder: (controller) => IconButton(
              icon: Icon(controller.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: controller.toggleTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: const [
          StatCard(title: 'Véhicules', value: '25', color: Colors.blue),
          StatCard(title: 'En panne', value: '3', color: Colors.red),
          StatCard(title: 'Actifs', value: '22', color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats(String month) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text("Statistiques du mois de $month",
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _selectMonth,
                    tooltip: "Changer de mois",
                    color: Colors.grey[700],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  MonthlyStatCard(
                    icon: Icons.attach_money_outlined,
                    label: "Coût total",
                    value: "3400 TND",
                    color: Colors.deepPurple,
                  ),
                  MonthlyStatCard(
                    icon: Icons.local_gas_station,
                    label: "Carburant",
                    value: "720 L",
                    color: Colors.orange,
                  ),
                  MonthlyStatCard(
                    icon: Icons.speed,
                    label: "Distance",
                    value: "6400 km",
                    color: Colors.blue,
                  ),
                  MonthlyStatCard(
                    icon: Icons.build_circle,
                    label: "Entretiens",
                    value: "4",
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentVehicles() {
    final List<Map<String, String>> vehicles = [
      {'marque': 'Peugeot', 'modele': '208', 'etat': 'En service'},
      {'marque': 'Renault', 'modele': 'Clio', 'etat': 'En maintenance'},
      {'marque': 'Dacia', 'modele': 'Dokker', 'etat': 'Hors service'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Véhicules récents",
                  style: Theme.of(context).textTheme.titleMedium
              ),
              const SizedBox(height: 10),
              ...vehicles.map((v) => ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text("${v['marque']} ${v['modele']}"),
                trailing: Text(
                  v['etat']!,
                  style: TextStyle(
                    color: v['etat'] == "En service"
                        ? Colors.green
                        : v['etat'] == "En maintenance"
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    final List<Map<String, String>> activities = [
      {"title": "Vidange Camion B45", "date": "24 Juil", "type": "Entretien"},
      {"title": "Ajout véhicule Renault Clio", "date": "23 Juil", "type": "Système"},
      {"title": "Chauffeur Ali affecté", "date": "21 Juil", "type": "Affectation"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Activités récentes", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...activities.map((activity) => ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Colors.blue),
            title: Text(activity['title']!),
            subtitle: Text(activity['date']!),
            trailing: Chip(
              label: Text(activity['type']!, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.blueAccent,
            ),
          )),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const MonthlyStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

