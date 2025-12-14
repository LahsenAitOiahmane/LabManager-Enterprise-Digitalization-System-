import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/drawer_widget.dart';
import '../../utils/constants.dart';

class LabHomePage extends StatefulWidget {
  const LabHomePage({super.key});

  @override
  State<LabHomePage> createState() => _LabHomePageState();
}

class _LabHomePageState extends State<LabHomePage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  
  // Dashboard data
  Map<String, dynamic> _dashboardData = {};
  List<Map<String, dynamic>> _ongoingTests = [];
  List<Map<String, dynamic>> _recentlyCompletedTests = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchDashboardData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchDashboardData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample dashboard data
    final dashboardData = {
      'stats': {
        'testsInProgress': 18,
        'testsCompleted': 42,
        'testsDelayed': 3,
        'avgCompletionTime': 14.5, // in hours
        'testSuccess': 0.96, // 96% success rate
        'capacityUtilization': 0.72, // 72% capacity utilization
      },
      'efficiency': {
        'weeklyTests': [28, 35, 25, 40, 38, 32, 42], // Last 7 days
        'resourceUtilization': [
          {'name': 'Equipment', 'utilized': 0.68},
          {'name': 'Personnel', 'utilized': 0.82},
          {'name': 'Test Stations', 'utilized': 0.75},
        ],
        'backlog': 14, // tests in backlog
        'testTypes': [
          {'name': 'Granulats', 'count': 25},
          {'name': 'Bétons', 'count': 18},
          {'name': 'Liants', 'count': 10},
          {'name': 'Enrobés', 'count': 15},
          {'name': 'Sols', 'count': 22},
        ],
      },
    };
    
    // Sample ongoing tests
    final ongoingTests = [
      {
        'id': 'T-1234',
        'name': 'Résistance à la compression',
        'type': 'Bétons',
        'urgency': 'high',
        'dossierId': 'D-089',
        'dossierName': 'Projet Autoroute Rabat-Casablanca',
        'testeur': 'Karim Benali',
        'testeurId': 'OP-001',
        'startDate': DateTime.now().subtract(const Duration(hours: 5)),
        'estimatedCompletion': DateTime.now().add(const Duration(hours: 7)),
        'progress': 0.35,
        'status': 'en_cours', // en_cours, en_attente, terminé, en_retard
      },
      {
        'id': 'T-1235',
        'name': 'Analyse granulométrique',
        'type': 'Granulats',
        'urgency': 'medium',
        'dossierId': 'D-090',
        'dossierName': 'Construction Centre Commercial Marrakech',
        'testeur': 'Fatima Zahrae',
        'testeurId': 'OP-002',
        'startDate': DateTime.now().subtract(const Duration(hours: 2)),
        'estimatedCompletion': DateTime.now().add(const Duration(hours: 3)),
        'progress': 0.65,
        'status': 'en_cours',
      },
      {
        'id': 'T-1236',
        'name': 'Limites d\'Atterberg',
        'type': 'Sols',
        'urgency': 'low',
        'dossierId': 'D-091',
        'dossierName': 'Résidence El Firdaous',
        'testeur': 'Ahmed Lamrani',
        'testeurId': 'OP-003',
        'startDate': DateTime.now().subtract(const Duration(hours: 1)),
        'estimatedCompletion': DateTime.now().add(const Duration(hours: 5)),
        'progress': 0.25,
        'status': 'en_cours',
      },
      {
        'id': 'T-1237',
        'name': 'Proctor Modifié',
        'type': 'Sols',
        'urgency': 'high',
        'dossierId': 'D-092',
        'dossierName': 'Barrage Oued Laou',
        'testeur': 'Siham El Ouazzani',
        'testeurId': 'OP-004',
        'startDate': DateTime.now().subtract(const Duration(hours: 8)),
        'estimatedCompletion': DateTime.now().subtract(const Duration(hours: 1)),
        'progress': 0.85,
        'status': 'en_retard',
      },
      {
        'id': 'T-1238',
        'name': 'Teneur en bitume',
        'type': 'Enrobés',
        'urgency': 'medium',
        'dossierId': 'D-093',
        'dossierName': 'Réfection Route Régionale P4022',
        'testeur': 'Unassigned',
        'testeurId': null,
        'startDate': null,
        'estimatedCompletion': DateTime.now().add(const Duration(days: 1)),
        'progress': 0.0,
        'status': 'en_attente',
      },
    ];
    
    // Sample recently completed tests
    final recentlyCompletedTests = [
      {
        'id': 'T-1230',
        'name': 'Densité et porosité',
        'type': 'Bétons',
        'urgency': 'medium',
        'dossierId': 'D-085',
        'dossierName': 'Pont Mohammed VI',
        'testeur': 'Karim Benali',
        'testeurId': 'OP-001',
        'startDate': DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        'completionDate': DateTime.now().subtract(const Duration(hours: 4)),
        'result': 'conforme',
        'status': 'terminé',
      },
      {
        'id': 'T-1231',
        'name': 'Los Angeles',
        'type': 'Granulats',
        'urgency': 'high',
        'dossierId': 'D-087',
        'dossierName': 'Extension Port Tanger Med',
        'testeur': 'Ahmed Lamrani',
        'testeurId': 'OP-003',
        'startDate': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        'completionDate': DateTime.now().subtract(const Duration(hours: 6)),
        'result': 'conforme',
        'status': 'terminé',
      },
      {
        'id': 'T-1232',
        'name': 'Teneur en eau',
        'type': 'Sols',
        'urgency': 'low',
        'dossierId': 'D-088',
        'dossierName': 'Centre Hospitalier El Jadida',
        'testeur': 'Fatima Zahrae',
        'testeurId': 'OP-002',
        'startDate': DateTime.now().subtract(const Duration(days: 1, hours: 8)),
        'completionDate': DateTime.now().subtract(const Duration(hours: 2)),
        'result': 'non_conforme',
        'status': 'terminé',
      },
    ];
    
    setState(() {
      _dashboardData = dashboardData;
      _ongoingTests = ongoingTests;
      _recentlyCompletedTests = recentlyCompletedTests;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratoire d\'Essais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _fetchDashboardData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profil',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show quick actions dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Actions rapides'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Nouveau test'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to new test page
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment),
                    title: const Text('Gérer les tests'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/lab/tests');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Gérer les testeurs'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/lab/technicians');
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      drawer: DrawerWidget(
        role: UserRole.labManager,
        selectedRoute: Routes.labHome,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboard(),
    );
  }
  
  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCards(),
            const SizedBox(height: 16),
            _buildTestsOverviewChart(),
            const SizedBox(height: 16),
            _buildTestsSection(),
            const SizedBox(height: 16),
            _buildEfficiencySection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCards() {
    final stats = _dashboardData['stats'];
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Tests en cours',
          stats['testsInProgress'].toString(),
          Icons.pending_actions,
          Colors.blue,
        ),
        _buildStatCard(
          'Tests terminés',
          stats['testsCompleted'].toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Tests en retard',
          stats['testsDelayed'].toString(),
          Icons.error,
          Colors.red,
        ),
        _buildStatCard(
          'Taux de réussite',
          '${(stats['testSuccess'] * 100).toStringAsFixed(0)}%',
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  icon,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestsOverviewChart() {
    final weeklyTests = _dashboardData['efficiency']['weeklyTests'];
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tests par jour',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(days[value.toInt() % 7]),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    weeklyTests.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: weeklyTests[index].toDouble(),
                          color: Theme.of(context).colorScheme.primary,
                          width: 18,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tests en cours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to tests overview page
                Navigator.pushNamed(context, '/lab/tests');
              },
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildOngoingTestsList(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tests récemment terminés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to tests overview page
                Navigator.pushNamed(context, '/lab/tests');
              },
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildCompletedTestsList(),
      ],
    );
  }
  
  Widget _buildOngoingTestsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _ongoingTests.length,
      itemBuilder: (context, index) {
        final test = _ongoingTests[index];
        return _buildTestCard(test, isOngoing: true);
      },
    );
  }
  
  Widget _buildCompletedTestsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentlyCompletedTests.length,
      itemBuilder: (context, index) {
        final test = _recentlyCompletedTests[index];
        return _buildTestCard(test, isOngoing: false);
      },
    );
  }
  
  Widget _buildTestCard(Map<String, dynamic> test, {required bool isOngoing}) {
    final Color statusColor;
    final String statusText;
    
    if (isOngoing) {
      switch (test['status']) {
        case 'en_cours':
          statusColor = Colors.blue;
          statusText = 'En cours';
          break;
        case 'en_attente':
          statusColor = Colors.orange;
          statusText = 'En attente';
          break;
        case 'en_retard':
          statusColor = Colors.red;
          statusText = 'En retard';
          break;
        default:
          statusColor = Colors.grey;
          statusText = 'Inconnu';
      }
    } else {
      switch (test['result']) {
        case 'conforme':
          statusColor = Colors.green;
          statusText = 'Conforme';
          break;
        case 'non_conforme':
          statusColor = Colors.red;
          statusText = 'Non conforme';
          break;
        default:
          statusColor = Colors.grey;
          statusText = 'Terminé';
      }
    }
    
    // Urgency color
    final Color urgencyColor;
    switch (test['urgency']) {
      case 'high':
        urgencyColor = Colors.red;
        break;
      case 'medium':
        urgencyColor = Colors.orange;
        break;
      case 'low':
        urgencyColor = Colors.green;
        break;
      default:
        urgencyColor = Colors.grey;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: test['status'] == 'en_retard' ? Colors.red.withOpacity(0.5) : Colors.transparent,
          width: test['status'] == 'en_retard' ? 1 : 0,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to test details
          Navigator.pushNamed(context, '/lab/test/${test['id']}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: urgencyColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      test['urgency'] == 'high'
                          ? 'Urgent'
                          : test['urgency'] == 'medium'
                              ? 'Normal'
                              : 'Routine',
                      style: TextStyle(
                        color: urgencyColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    test['id'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                test['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.folder,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${test['dossierId']} - ${test['dossierName']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      test['type'],
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            test['testeur'] ?? 'Non assigné',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOngoing && test['status'] == 'en_cours')
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Progression: ${(test['progress'] * 100).toInt()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: test['progress'],
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isOngoing
                          ? 'Début: ${test['startDate'] != null ? DateFormat('dd/MM HH:mm').format(test['startDate']) : 'N/A'}'
                          : 'Terminé: ${DateFormat('dd/MM HH:mm').format(test['completionDate'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOngoing)
                    Expanded(
                      child: Text(
                        'Fin estimée: ${test['estimatedCompletion'] != null ? DateFormat('dd/MM HH:mm').format(test['estimatedCompletion']) : 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: test['status'] == 'en_retard' ? Colors.red : Colors.grey[600],
                          fontWeight: test['status'] == 'en_retard' ? FontWeight.bold : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEfficiencySection() {
    final resourceUtilization = _dashboardData['efficiency']['resourceUtilization'];
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Utilisation des ressources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: resourceUtilization.length,
              itemBuilder: (context, index) {
                final resource = resourceUtilization[index];
                final utilization = resource['utilized'] as double;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(resource['name']),
                        Text('${(utilization * 100).toInt()}%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: utilization,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        utilization > 0.8 ? Colors.red :
                        utilization > 0.6 ? Colors.orange : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tests en attente',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _dashboardData['efficiency']['backlog'].toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Durée moyenne',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_dashboardData['stats']['avgCompletionTime']} h',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Utilisation',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(_dashboardData['stats']['capacityUtilization'] * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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