import 'package:flutter/material.dart';
import '../../widgets/drawer_widget.dart';
import '../../utils/constants.dart';

class TestsOverviewPage extends StatefulWidget {
  const TestsOverviewPage({super.key});

  @override
  State<TestsOverviewPage> createState() => _TestsOverviewPageState();
}

class _TestsOverviewPageState extends State<TestsOverviewPage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Lists for ongoing tests
  List<Map<String, dynamic>> _ongoingTests = [];
  List<Map<String, dynamic>> _filteredOngoingTests = [];

  // Lists for completed tests
  List<Map<String, dynamic>> _completedTests = [];
  List<Map<String, dynamic>> _filteredCompletedTests = [];

  // Filter values
  String _searchQuery = '';
  String? _selectedUrgency = 'Tous';
  String? _selectedStatus = 'Tous';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Reset filters when changing tabs
      if (_tabController.indexIsChanging) {
        setState(() {
          _searchQuery = '';
          _selectedUrgency = 'Tous';
          _selectedStatus = 'Tous';
        });
        _applyFilters();
      }
    });
    _fetchTestsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTestsData() async {
    // Simulate API fetch
    await Future.delayed(const Duration(seconds: 1));

    // Sample data - would be replaced with API call
    final ongoingTests = [
      {
        'id': 'T001',
        'name': 'Test de résistance à la traction',
        'sample': 'S001',
        'technician': 'Ahmed Benali',
        'client': 'Maroc Constructions',
        'status': 'En cours',
        'progress': 0.7,
        'startDate': '2023-05-15',
        'estimatedCompletion': '2023-05-20',
        'urgency': 'Haute',
        'notes': 'Utiliser les nouveaux équipements calibrés'
      },
      {
        'id': 'T002',
        'name': 'Analyse de composition chimique',
        'sample': 'S002',
        'technician': 'Fatima Zahra',
        'client': 'Laboratoire Central',
        'status': 'En attente',
        'progress': 0.3,
        'startDate': '2023-05-16',
        'estimatedCompletion': '2023-05-22',
        'urgency': 'Moyenne',
        'notes': 'Échantillon pourrait être contaminé'
      },
      {
        'id': 'T003',
        'name': 'Test d\'adhérence',
        'sample': 'S003',
        'technician': 'Youssef Nadori',
        'client': 'Autoroutes du Maroc',
        'status': 'En cours',
        'progress': 0.5,
        'startDate': '2023-05-14',
        'estimatedCompletion': '2023-05-19',
        'urgency': 'Basse',
        'notes': 'Standard procedure'
      },
      {
        'id': 'T004',
        'name': 'Analyse microstructurale',
        'sample': 'S004',
        'technician': 'Samira Tazi',
        'client': 'OCP Group',
        'status': 'En pause',
        'progress': 0.2,
        'startDate': '2023-05-17',
        'estimatedCompletion': '2023-05-24',
        'urgency': 'Haute',
        'notes': 'En attente d\'équipement spécial'
      },
    ];

    final completedTests = [
      {
        'id': 'T005',
        'name': 'Test de résistance au feu',
        'sample': 'S005',
        'technician': 'Hassan Moussaid',
        'client': 'Sécurité Incendie SA',
        'status': 'Terminé',
        'completionDate': '2023-05-10',
        'result': 'Conforme',
        'urgency': 'Haute',
        'notes': 'Tous les critères respectés'
      },
      {
        'id': 'T006',
        'name': 'Analyse de granulométrie',
        'sample': 'S006',
        'technician': 'Loubna Karam',
        'client': 'CimentMaroc',
        'status': 'Terminé',
        'completionDate': '2023-05-12',
        'result': 'Non-conforme',
        'urgency': 'Moyenne',
        'notes': 'Distribution irrégulière, voir rapport détaillé'
      },
      {
        'id': 'T007',
        'name': 'Test de perméabilité',
        'sample': 'S007',
        'technician': 'Karim Idrissi',
        'client': 'Eaux et Forêts',
        'status': 'Terminé',
        'completionDate': '2023-05-08',
        'result': 'Conforme',
        'urgency': 'Basse',
        'notes': 'Résultats dans les normes acceptables'
      },
    ];

    setState(() {
      _ongoingTests = ongoingTests;
      _filteredOngoingTests = ongoingTests;
      _completedTests = completedTests;
      _filteredCompletedTests = completedTests;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      // Filter ongoing tests
      if (_tabController.index == 0) {
        _filteredOngoingTests = _ongoingTests.where((test) {
          // Apply search query filter
          final matchesQuery = _searchQuery.isEmpty ||
              test['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              test['id'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              test['client'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              test['technician'].toLowerCase().contains(_searchQuery.toLowerCase());

          // Apply urgency filter
          final matchesUrgency = _selectedUrgency == 'Tous' || test['urgency'] == _selectedUrgency;

          // Apply status filter
          final matchesStatus = _selectedStatus == 'Tous' || test['status'] == _selectedStatus;

          return matchesQuery && matchesUrgency && matchesStatus;
        }).toList();
      } 
      // Filter completed tests
      else {
        _filteredCompletedTests = _completedTests.where((test) {
          // Apply search query filter
          final matchesQuery = _searchQuery.isEmpty ||
              test['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              test['id'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              test['client'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              test['technician'].toLowerCase().contains(_searchQuery.toLowerCase());

          // Apply urgency filter
          final matchesUrgency = _selectedUrgency == 'Tous' || test['urgency'] == _selectedUrgency;

          // Apply result filter (status for completed tests is the result)
          final matchesResult = _selectedStatus == 'Tous' || test['result'] == _selectedStatus;

          return matchesQuery && matchesUrgency && matchesResult;
        }).toList();
      }
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Filter Tests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status filter
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedStatus == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedStatus = null;
                            });
                          }
                        },
                      ),
                      FilterChip(
                        label: const Text('Pending'),
                        selected: _selectedStatus == 'pending',
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? 'pending' : null;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('In Progress'),
                        selected: _selectedStatus == 'in_progress',
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? 'in_progress' : null;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Completed'),
                        selected: _selectedStatus == 'completed',
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? 'completed' : null;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Type filter
                  const Text(
                    'Test Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedUrgency == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedUrgency = null;
                            });
                          }
                        },
                      ),
                      FilterChip(
                        label: const Text('Haute'),
                        selected: _selectedUrgency == 'Haute',
                        onSelected: (selected) {
                          setState(() {
                            _selectedUrgency = selected ? 'Haute' : null;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Moyenne'),
                        selected: _selectedUrgency == 'Moyenne',
                        onSelected: (selected) {
                          setState(() {
                            _selectedUrgency = selected ? 'Moyenne' : null;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Basse'),
                        selected: _selectedUrgency == 'Basse',
                        onSelected: (selected) {
                          setState(() {
                            _selectedUrgency = selected ? 'Basse' : null;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedStatus = null;
                            _selectedUrgency = null;
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        child: const Text('Apply Filters'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tests de laboratoire"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "En cours"),
            Tab(text: "Terminés"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () {
              _showFilterOptions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _fetchTestsData();
            },
          ),
        ],
      ),
      drawer: DrawerWidget(
        selectedRoute: Routes.labTests,
        role: UserRole.labManager,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Search bar
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher par nom, ID, client...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _applyFilters();
                        },
                      ),
                      const SizedBox(height: 12),
                      // Filter options
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownFilter(
                              label: 'Urgence',
                              value: _selectedUrgency,
                              items: const ['Tous', 'Haute', 'Moyenne', 'Basse'],
                              onChanged: (value) {
                                setState(() {
                                  _selectedUrgency = value!;
                                });
                                _applyFilters();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdownFilter(
                              label: _tabController.index == 0 ? 'Statut' : 'Résultat',
                              value: _selectedStatus,
                              items: _tabController.index == 0
                                  ? const ['Tous', 'En cours', 'En attente', 'En pause']
                                  : const ['Tous', 'Conforme', 'Non-conforme'],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                                _applyFilters();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Ongoing Tests
                      _buildOngoingTestsList(),
                      
                      // Tab 2: Completed Tests
                      _buildCompletedTestsList(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to assign test page
          Navigator.pushNamed(context, Routes.labAssign);
        },
        tooltip: 'Assign Test',
        child: const Icon(Icons.assignment_ind),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildOngoingTestsList() {
    if (_filteredOngoingTests.isEmpty) {
      return const Center(
        child: Text("Aucun test en cours trouvé"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOngoingTests.length,
      itemBuilder: (context, index) {
        final test = _filteredOngoingTests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to test details
              Navigator.pushNamed(
                context,
                '/lab/test/${test['id']}',
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        test['id'],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildUrgencyChip(test['urgency']),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    test['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        test['technician'],
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        test['client'],
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Progression",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: test['progress'],
                              backgroundColor: Colors.grey[200],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${(test['progress'] * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildStatusChip(test['status']),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (test['notes'] != null && test['notes'].isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.note, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              test['notes'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Add action buttons
                  if (test['status'] == 'pending')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.assignment_ind),
                            label: const Text('Assign'),
                            onPressed: () {
                              // Navigate to assign test page with this test ID
                              Navigator.pushNamed(
                                context,
                                '/lab/assign/${test['id']}',
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedTestsList() {
    if (_filteredCompletedTests.isEmpty) {
      return const Center(
        child: Text("Aucun test terminé trouvé"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCompletedTests.length,
      itemBuilder: (context, index) {
        final test = _filteredCompletedTests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to test details
              Navigator.pushNamed(
                context,
                '/lab/test/${test['id']}',
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        test['id'],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildResultChip(test['result']),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    test['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        test['technician'],
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        test['client'],
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Terminé le ${test['completionDate']}",
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (test['notes'] != null && test['notes'].isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.note, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              test['notes'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Add action buttons
                  if (test['status'] == 'pending')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.assignment_ind),
                            label: const Text('Assign'),
                            onPressed: () {
                              // Navigate to assign test page with this test ID
                              Navigator.pushNamed(
                                context,
                                '/lab/assign/${test['id']}',
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUrgencyChip(String urgency) {
    Color color;
    IconData icon;

    switch (urgency) {
      case 'Haute':
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case 'Moyenne':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'Basse':
        color = Colors.green;
        icon = Icons.info;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.5)),
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        urgency,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'En cours':
        color = Colors.blue;
        icon = Icons.autorenew;
        break;
      case 'En attente':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'En pause':
        color = Colors.red;
        icon = Icons.pause;
        break;
      case 'Terminé':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.5)),
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildResultChip(String result) {
    Color color;
    IconData icon;

    switch (result) {
      case 'Conforme':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'Non-conforme':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.5)),
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        result,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
} 