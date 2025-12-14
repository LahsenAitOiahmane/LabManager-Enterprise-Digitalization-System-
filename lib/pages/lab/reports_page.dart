import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/drawer_widget.dart';
import '../../utils/constants.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  
  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType;
  String? _selectedStatus;
  
  // Report data
  List<Map<String, dynamic>> _reports = [];
  
  final List<String> _testTypes = ['Tous', 'Granulats', 'Bétons', 'Sols', 'Liants', 'Enrobés'];
  final List<String> _statusOptions = ['Tous', 'Conforme', 'Non conforme'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchReports();
    
    // Initialize with last 30 days
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now();
    _selectedType = 'Tous';
    _selectedStatus = 'Tous';
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchReports() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample data
    final List<Map<String, dynamic>> sampleReports = [
      {
        'id': 'R-2023-001',
        'title': 'Analyse de résistance',
        'type': 'Bétons',
        'client': 'Société Générale de Travaux',
        'dossierId': 'D-089',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'testCount': 5,
        'status': 'Conforme',
        'technicien': 'Karim Benali',
      },
      {
        'id': 'R-2023-002',
        'title': 'Analyse granulométrique',
        'type': 'Granulats',
        'client': 'Construction Centre Commercial Marrakech',
        'dossierId': 'D-090',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'testCount': 3,
        'status': 'Non conforme',
        'technicien': 'Fatima Zahrae',
      },
      {
        'id': 'R-2023-003',
        'title': 'Limites d\'Atterberg',
        'type': 'Sols',
        'client': 'Résidence El Firdaous',
        'dossierId': 'D-091',
        'date': DateTime.now().subtract(const Duration(days: 8)),
        'testCount': 2,
        'status': 'Conforme',
        'technicien': 'Ahmed Lamrani',
      },
      {
        'id': 'R-2023-004',
        'title': 'Teneur en bitume',
        'type': 'Enrobés',
        'client': 'Réfection Route Régionale P4022',
        'dossierId': 'D-093',
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'testCount': 4,
        'status': 'Conforme',
        'technicien': 'Siham El Ouazzani',
      },
      {
        'id': 'R-2023-005',
        'title': 'Teneur en eau',
        'type': 'Sols',
        'client': 'Centre Hospitalier El Jadida',
        'dossierId': 'D-088',
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'testCount': 1,
        'status': 'Non conforme',
        'technicien': 'Karim Benali',
      },
    ];
    
    setState(() {
      _reports = sampleReports;
      _isLoading = false;
    });
  }
  
  void _applyFilters() {
    setState(() {
      _isLoading = true;
    });
    
    // In a real app, you would call API with filters
    // For now, just simulate a delay and filter existing data
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
    });
  }
  
  void _generateReport() {
    // Show dialog to create new report
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Générer un nouveau rapport'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Type de rapport:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: _testTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Période:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _startDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_startDate!)
                                  : 'Date début',
                            ),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _endDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_endDate!)
                                  : 'Date fin',
                            ),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Inclure:'),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Résultats détaillés'),
                value: true,
                onChanged: (value) {},
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Graphiques et statistiques'),
                value: true,
                onChanged: (value) {},
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Commentaires et notes'),
                value: true,
                onChanged: (value) {},
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Show a snackbar indicating success
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rapport généré avec succès')),
              );
              // In a real app, you would create a new report and add it to the list
              setState(() {
                _reports.insert(0, {
                  'id': 'R-2023-${_reports.length + 1}',
                  'title': 'Nouveau rapport',
                  'type': _selectedType ?? 'Tous',
                  'client': 'Divers clients',
                  'dossierId': 'Divers',
                  'date': DateTime.now(),
                  'testCount': 3,
                  'status': 'Conforme',
                  'technicien': 'Système',
                });
              });
            },
            child: const Text('Générer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports & Statistiques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _fetchReports();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Rapports'),
            Tab(text: 'Statistiques'),
          ],
        ),
      ),
      drawer: const DrawerWidget(
        role: UserRole.labManager,
        selectedRoute: Routes.labReports,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateReport,
        tooltip: 'Générer un rapport',
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }
  
  Widget _buildReportsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildFilters(),
              Expanded(
                child: _reports.isEmpty
                    ? const Center(child: Text('Aucun rapport trouvé'))
                    : ListView.builder(
                        itemCount: _reports.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          return _buildReportCard(_reports[index]);
                        },
                      ),
              ),
            ],
          );
  }
  
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type de test',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: _testTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _startDate != null
                              ? DateFormat('dd/MM/yyyy').format(_startDate!)
                              : 'Date début',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _endDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _endDate != null
                              ? DateFormat('dd/MM/yyyy').format(_endDate!)
                              : 'Date fin',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                ),
                child: const Text('Filtrer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildReportCard(Map<String, dynamic> report) {
    final Color statusColor = report['status'] == 'Conforme' ? Colors.green : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // View report details
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Rapport ${report['id']}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ce rapport serait affiché en détail dans une application réelle.'),
                    const SizedBox(height: 16),
                    const Text('Options:'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Rapport téléchargé')),
                            );
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('PDF'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Rapport envoyé par email')),
                            );
                          },
                          icon: const Icon(Icons.email),
                          label: const Text('Email'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    report['id'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      report['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(report['type']),
                  const SizedBox(width: 16),
                  Icon(Icons.science, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${report['testCount']} tests'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report['client'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(report['technicien']),
                    ],
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(report['date']),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Download PDF report
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Téléchargement du rapport...')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('PDF'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Send report by email
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Envoi du rapport par email...')),
                      );
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Email'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistiques générales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatsSummary(),
                
                const SizedBox(height: 24),
                const Text(
                  'Ces statistiques seraient plus détaillées dans une application réelle',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
  }
  
  Widget _buildStatsSummary() {
    // Sample statistics
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatRow('Total des tests effectués', '235'),
            const Divider(),
            _buildStatRow('Taux de conformité', '92%'),
            const Divider(),
            _buildStatRow('Temps moyen par test', '14.5 heures'),
            const Divider(),
            _buildStatRow('Tests en cours', '18'),
            const Divider(),
            _buildStatRow('Tests en retard', '3'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
} 