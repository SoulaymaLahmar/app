import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stage/controllers/theme_controller.dart';
import 'package:stage/features/statistics/screens/statistics_screen.dart';
import 'package:stage/features/notifications/view/notifications_screen.dart';
import '../controllers/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  bool isLoading = true;
  Map<String, dynamic> dashboardData = {};
  List<dynamic> recentVehicles = [];
  List<dynamic> recentActivities = [];
  String? error;
  static const String BASE_URL = 'http://10.0.2.2:5000/api';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
    _animationController!.forward();
    _fetchDashboardData();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      print('AuthController user data: ${AuthController.to.user}');
      final userId = AuthController.to.user?['_id'] ??
          AuthController.to.user?['id'] ??
          AuthController.to.user?['userId'];
      final token = AuthController.to.token;

      print('Extracted userId: $userId');
      print('Token available: ${token != null}');

      if (userId == null) {
        throw Exception('User ID not found. Available user data: ${AuthController.to.user?.keys}');
      }

      await Future.wait([
        _fetchVehicleStats(userId, token),
        _fetchRecentVehicles(userId, token),
        _fetchRecentActivities(userId, token),
        _fetchMonthlyStats(userId, token, selectedDate),
      ]);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur de chargement des données: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchVehicleStats(String userId, String? token) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/dashboard/vehicles/stats/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Vehicle stats response: ${response.statusCode}');
      print('Vehicle stats URL: $BASE_URL/dashboard/vehicles/stats/$userId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          dashboardData['vehicleStats'] = data;
        }
      } else if (response.statusCode == 404) {
        dashboardData['vehicleStats'] = {
          'total': 0,
          'enService': 0,
          'enMaintenance': 0,
          'horsService': 0,
          'totalKilometrage': 0,
          'coutTotal': 0
        };
        print('Vehicle stats endpoint not found, using empty stats');
      } else {
        throw Exception('Failed to load vehicle stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _fetchVehicleStats: $e');
      dashboardData['vehicleStats'] = {
        'total': 0,
        'enService': 0,
        'enMaintenance': 0,
        'horsService': 0,
        'totalKilometrage': 0,
        'coutTotal': 0
      };
    }
  }
  Future<void> _fetchRecentVehicles(String userId, String? token) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/dashboard/vehicles/recent/$userId?limit=3'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data['vehicles'] != null) {
        recentVehicles = List<Map<String, dynamic>>.from(data['vehicles']);
      } else {
        recentVehicles = [];
      }
    } else {
      throw Exception('Failed to load recent vehicles: ${response.statusCode}');
    }
  }

  Future<void> _fetchRecentActivities(String userId, String? token) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/dashboard/activities/recent/$userId?limit=3'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data['activities'] != null) {
        recentActivities = List<Map<String, dynamic>>.from(data['activities']);
      } else {
        recentActivities = [];
      }
    } else {
      throw Exception('Failed to load recent activities: ${response.statusCode}');
    }
  }

  Future<void> _fetchMonthlyStats(String userId, String? token, DateTime date) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/dashboard/stats/monthly/$userId?year=${date.year}&month=${date.month}'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null) {
        dashboardData['monthlyStats'] = data;
      }
    } else {
      throw Exception('Failed to load monthly stats: ${response.statusCode}');
    }
  }
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
      final userId = AuthController.to.user['_id'];
      final token = AuthController.to.token;
      await _fetchMonthlyStats(userId, token, selectedDate);
    }
  }

  Future<void> _refreshData() async {
    await _fetchDashboardData();
  }

  Color _getVehicleStateColor(String etat) {
    switch (etat) {
      case 'En service':
        return const Color(0xFF10B981);
      case 'En maintenance':
        return const Color(0xFFF59E0B);
      case 'Hors service':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'entretien':
        return Icons.build_rounded;
      case 'ajout':
      case 'système':
        return Icons.add_circle_rounded;
      case 'affectation':
        return Icons.person_add_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedMonth = DateFormat.yMMMM('fr_FR').format(selectedDate);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0E27) : const Color(0xFFF8FAFC),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0E27) : const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDashboardData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E27) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Theme.of(context).primaryColor,
          child: _fadeAnimation != null
              ? FadeTransition(
            opacity: _fadeAnimation!,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                SliverToBoxAdapter(child: _buildWelcomeCard()),
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                SliverToBoxAdapter(child: _buildStatCards()),
                SliverToBoxAdapter(child: const SizedBox(height: 32)),
                SliverToBoxAdapter(child: _buildMonthlyStats(formattedMonth)),
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                SliverToBoxAdapter(child: _buildRecentVehicles()),
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                SliverToBoxAdapter(child: _buildRecentActivities()),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          )
              : CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),
              SliverToBoxAdapter(child: _buildWelcomeCard()),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),
              SliverToBoxAdapter(child: _buildStatCards()),
              SliverToBoxAdapter(child: const SizedBox(height: 32)),
              SliverToBoxAdapter(child: _buildMonthlyStats(formattedMonth)),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),
              SliverToBoxAdapter(child: _buildRecentVehicles()),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),
              SliverToBoxAdapter(child: _buildRecentActivities()),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = AuthController.to.user;
    final imageUrl = user['profileImage'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Hero(
            tag: 'profile_avatar',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : const AssetImage('assets/images/ff0436d36131c01b6c504901b407dcf3') as ImageProvider,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tableau de bord',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AuthController.to.user['name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderAction(Icons.notifications_outlined, () => Get.to(() => NotificationsScreen())),
          const SizedBox(width: 8),
          _buildHeaderAction(Icons.bar_chart_rounded, () => Get.to(() => StatisticsScreen())),
          const SizedBox(width: 8),
          GetBuilder<ThemeController>(
            builder: (controller) => _buildHeaderAction(
              controller.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              controller.toggleTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onPressed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 22),
        onPressed: onPressed,
        color: isDark ? Colors.white70 : const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Bonjour' : hour < 17 ? 'Bon après-midi' : 'Bonsoir';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E40AF), const Color(0xFF3B82F6)]
              : [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AuthController.to.user['name']?.split(' ')[0] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gérez votre flotte efficacement',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    final stats = dashboardData['vehicleStats'] ?? {};
    final totalVehicles = stats['total'] ?? 0;
    final enPanne = stats['enMaintenance'] ?? 0;
    final actifs = stats['enService'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: EnhancedStatCard(
            title: 'Véhicules',
            value: totalVehicles.toString(),
            color: const Color(0xFF3B82F6),
            icon: Icons.directions_car_rounded,
          )),
          const SizedBox(width: 12),
          Expanded(child: EnhancedStatCard(
            title: 'En panne',
            value: enPanne.toString(),
            color: const Color(0xFFEF4444),
            icon: Icons.warning_rounded,
          )),
          const SizedBox(width: 12),
          Expanded(child: EnhancedStatCard(
            title: 'Actifs',
            value: actifs.toString(),
            color: const Color(0xFF10B981),
            icon: Icons.check_circle_rounded,
          )),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats(String month) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthlyStats = dashboardData['monthlyStats'] ?? {};

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Statistiques mensuelles",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        month,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.calendar_month_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: _selectMonth,
                    tooltip: "Changer de mois",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                EnhancedMonthlyStatCard(
                  icon: Icons.attach_money_rounded,
                  label: "Coût total",
                  value: "${monthlyStats['totalCost'] ?? 0} TND",
                  color: const Color(0xFF8B5CF6),
                ),
                EnhancedMonthlyStatCard(
                  icon: Icons.local_gas_station_rounded,
                  label: "Carburant",
                  value: "${monthlyStats['fuelConsumption'] ?? 0} L",
                  color: const Color(0xFFF59E0B),
                ),
                EnhancedMonthlyStatCard(
                  icon: Icons.speed_rounded,
                  label: "Distance",
                  value: "${monthlyStats['totalDistance'] ?? 0} km",
                  color: const Color(0xFF3B82F6),
                ),
                EnhancedMonthlyStatCard(
                  icon: Icons.build_circle_rounded,
                  label: "Entretiens",
                  value: "${monthlyStats['maintenanceCount'] ?? 0}",
                  color: const Color(0xFF10B981),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentVehicles() {
    return _buildSectionCard(
      title: "Véhicules récents",
      icon: Icons.directions_car_rounded,
      children: recentVehicles.isEmpty
          ? [const Text('Aucun véhicule récent')]
          : recentVehicles.map((vehicle) => _buildVehicleItem(vehicle)).toList(),
    );
  }

  Widget _buildVehicleItem(Map<String, dynamic> vehicle) {
    final etat = vehicle['etat'] ?? 'En service';
    final color = _getVehicleStateColor(etat);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${vehicle['marque']} ${vehicle['modele']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  etat,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (vehicle['kilometrage'] != null)
            Text(
              "${vehicle['kilometrage']} km",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return _buildSectionCard(
      title: "Activités récentes",
      icon: Icons.timeline_rounded,
      children: recentActivities.isEmpty
          ? [const Text('Aucune activité récente')]
          : recentActivities.map((activity) => _buildActivityItem(activity)).toList(),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final activityType = activity['type'] ?? 'info';
    final activityColor = activity['color'] != null
        ? Color(int.parse(activity['color'].toString().replaceAll('#', '0xFF')))
        : const Color(0xFF3B82F6);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activityColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityIcon(activityType),
              color: activityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? activity['description'] ?? 'Activité',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['date'] != null
                      ? DateFormat('dd MMM').format(DateTime.parse(activity['date']))
                      : 'Date inconnue',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: activityColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              activityType,
              style: TextStyle(
                color: activityColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class EnhancedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const EnhancedStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class EnhancedMonthlyStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const EnhancedMonthlyStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}