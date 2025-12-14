import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/drawer_widget.dart';

class ManageTestersPage extends StatefulWidget {
  const ManageTestersPage({super.key});

  @override
  _ManageTestersPageState createState() => _ManageTestersPageState();
}

class _ManageTestersPageState extends State<ManageTestersPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _testers = [];
  List<Map<String, dynamic>> _filteredTesters = [];
  
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    _loadTesters();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTesters() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    final testers = [
      {
        'id': 'TECH001',
        'name': 'Amal Bousquet',
        'specialty': 'Microbiologie',
        'workload': 68,
        'assignedTests': 12,
        'completedTests': 192,
        'efficiency': 94,
        'avatar': 'assets/avatars/avatar1.jpg',
        'contactInfo': 'amal.bousquet@labtrack.com',
        'status': 'Active',
        'joinDate': '2020-05-15',
      },
      {
        'id': 'TECH002',
        'name': 'Lucas Moreau',
        'specialty': 'Chimie analytique',
        'workload': 42,
        'assignedTests': 8,
        'completedTests': 143,
        'efficiency': 89,
        'avatar': 'assets/avatars/avatar2.jpg',
        'contactInfo': 'lucas.moreau@labtrack.com',
        'status': 'Active',
        'joinDate': '2021-01-10',
      },
      {
        'id': 'TECH003',
        'name': 'Sophie Dupont',
        'specialty': 'Biologie moléculaire',
        'workload': 75,
        'assignedTests': 15,
        'completedTests': 210,
        'efficiency': 97,
        'avatar': 'assets/avatars/avatar3.jpg',
        'contactInfo': 'sophie.dupont@labtrack.com',
        'status': 'Congé',
        'joinDate': '2019-08-22',
      },
      {
        'id': 'TECH004',
        'name': 'Mohamed Lahlou',
        'specialty': 'Hématologie',
        'workload': 55,
        'assignedTests': 10,
        'completedTests': 178,
        'efficiency': 91,
        'avatar': 'assets/avatars/avatar4.jpg',
        'contactInfo': 'mohamed.lahlou@labtrack.com',
        'status': 'Active',
        'joinDate': '2022-03-01',
      },
    ];
    
    setState(() {
      _testers = testers;
      _filteredTesters = testers;
      _isLoading = false;
    });
  }
  
  void _filterTesters(String query) {
    setState(() {
      _filteredTesters = _testers.where((tester) {
        return tester['name'].toLowerCase().contains(query.toLowerCase()) ||
               tester['id'].toLowerCase().contains(query.toLowerCase()) ||
               tester['specialty'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }
  
  void _showTesterDetail(Map<String, dynamic> tester) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(tester['avatar']),
                backgroundColor: Colors.grey[200],
                child: tester['avatar'].startsWith('assets/') 
                  ? null 
                  : Icon(Icons.person, size: 50, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Text(
                tester['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                tester['specialty'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('ID', tester['id']),
              _buildDetailRow('Statut', tester['status']),
              _buildDetailRow('Contact', tester['contactInfo']),
              _buildDetailRow('Date d\'embauche', tester['joinDate']),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: _buildStatItem('Tests assignés', '${tester['assignedTests']}', Colors.orange),
                  ),
                  Flexible(
                    child: _buildStatItem('Tests complétés', '${tester['completedTests']}', Colors.green),
                  ),
                  Flexible(
                    child: _buildStatItem('Efficacité', '${tester['efficiency']}%', Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Show edit form
                    },
                    child: const Text('Modifier'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
  
  Widget _buildWorkloadIndicator(int workload) {
    Color color;
    if (workload < 50) {
      color = Colors.green;
    } else if (workload < 75) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }
    
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: workload / 100,
          strokeWidth: 6,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        Text(
          '$workload%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Gestion des Techniciens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      drawer: DrawerWidget(
        selectedRoute: Routes.labManage,
        role: UserRole.labManager,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Rechercher un technicien',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterTesters('');
                        },
                      ),
                    ),
                    onChanged: _filterTesters,
                  ),
                ),
                Expanded(
                  child: _filteredTesters.isEmpty
                      ? const Center(child: Text('Aucun technicien trouvé'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: _filteredTesters.length,
                          itemBuilder: (context, index) {
                            final tester = _filteredTesters[index];
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: InkWell(
                                onTap: () => _showTesterDetail(tester),
                                borderRadius: BorderRadius.circular(12.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundImage: AssetImage(tester['avatar']),
                                            backgroundColor: Colors.grey[200],
                                            child: tester['avatar'].startsWith('assets/') 
                                              ? null 
                                              : Icon(Icons.person, size: 22, color: Colors.grey[700]),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  tester['name'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  tester['specialty'],
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 11,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Eff: ${tester['efficiency']}%',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        tester['status'] == 'Active' ? Icons.check_circle : Icons.cancel,
                                                        color: tester['status'] == 'Active' ? Colors.green : Colors.orange,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Expanded(
                                                        child: Text(
                                                          tester['status'],
                                                          style: TextStyle(
                                                            color: tester['status'] == 'Active' ? Colors.green : Colors.orange,
                                                            fontSize: 11,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: SizedBox(
                                                height: 40,
                                                width: 40,
                                                child: _buildWorkloadIndicator(tester['workload']),
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
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un technicien'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      // Show form to add new technician
                    },
                  ),
                ),
              ],
            ),
    );
  }
} 