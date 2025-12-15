import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResponsableHomePage extends StatefulWidget {
  const ResponsableHomePage({super.key});

  @override
  State<ResponsableHomePage> createState() => _ResponsableHomePageState();
}

class _ResponsableHomePageState extends State<ResponsableHomePage> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _validatedDossiers = [];
  String _filterStatus = 'Tous';
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _statusFilters = ['Tous', 'En attente', 'Assigné', 'En test'];
  
  @override
  void initState() {
    super.initState();
    _loadDossiers();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDossiers() async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample data - in a real app, this would come from an API
    final dossiers = [
      {
        'id': 'PRE-20230412-001',
        'type': 'Sol',
        'clientName': 'Société Générale de Travaux',
        'dateReceived': '2023-04-12',
        'status': 'En attente',
        'urgency': 'Normale',
        'technician': 'Mohammed Alami',
        'receptor': 'Nadia Benjelloun',
      },
      {
        'id': 'PRE-20230411-002',
        'type': 'Béton',
        'clientName': 'Bouygues Construction',
        'dateReceived': '2023-04-11',
        'status': 'En attente',
        'urgency': 'Urgente',
        'technician': 'Karim Bennani',
        'receptor': 'Nadia Benjelloun',
      },
      {
        'id': 'PRE-20230410-003',
        'type': 'Acier',
        'clientName': 'Moroccan Steel',
        'dateReceived': '2023-04-10',
        'status': 'Assigné',
        'urgency': 'Très urgente',
        'technician': 'Omar Mahmoud',
        'receptor': 'Ahmed Tazi',
        'assignedTo': 'Youssef Amine',
        'tests': ['Traction', 'Dureté', 'Composition'],
      },
      {
        'id': 'PRE-20230410-004',
        'type': 'Eau',
        'clientName': 'ONEE',
        'dateReceived': '2023-04-10',
        'status': 'En test',
        'urgency': 'Normale',
        'technician': 'Sara Bakkali',
        'receptor': 'Ahmed Tazi',
        'assignedTo': 'Leila Farhi',
        'tests': ['Acidité', 'Turbidité', 'Composition chimique'],
      },
      {
        'id': 'PRE-20230409-005',
        'type': 'Sol',
        'clientName': 'Ministère de l\'Agriculture',
        'dateReceived': '2023-04-09',
        'status': 'En attente',
        'urgency': 'Normale',
        'technician': 'Mohammed Alami',
        'receptor': 'Nadia Benjelloun',
      },
    ];
    
    setState(() {
      _validatedDossiers = dossiers;
      _isLoading = false;
    });
  }
  
  List<Map<String, dynamic>> get _filteredDossiers {
    return _validatedDossiers.where((dossier) {
      // Apply status filter if not 'All'
      if (_filterStatus != 'Tous' && dossier['status'] != _filterStatus) {
        return false;
      }
      
      // Apply search filter if search term is present
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        return dossier['id'].toLowerCase().contains(searchTerm) ||
               dossier['clientName'].toLowerCase().contains(searchTerm) ||
               dossier['type'].toLowerCase().contains(searchTerm);
      }
      
      return true;
    }).toList();
  }
  
  void _viewDossierDetails(String dossierId) {
    Navigator.pushNamed(context, '/responsable/dossier/$dossierId');
  }
  
  void _assignTests(String dossierId) {
    Navigator.pushNamed(context, '/responsable/assign/$dossierId');
  }
  
  void _onItemTapped(int index) {
    if (index == 4) {
      // Navigate to profile page when profile tab is selected
      Navigator.pushNamed(context, '/profile');
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsable de Dossier'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          // Notifications icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search bar
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un dossier...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Status filter dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      icon: const Icon(Icons.filter_list),
                      onChanged: (String? newValue) {
                        setState(() {
                          _filterStatus = newValue!;
                        });
                      },
                      items: _statusFilters.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Dossiers list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDossiers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_off,
                              size: 64,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucun dossier trouvé',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Modifiez vos critères de recherche ou vérifiez plus tard',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _filteredDossiers.length,
                        itemBuilder: (context, index) {
                          final dossier = _filteredDossiers[index];
                          return _buildDossierCard(dossier);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_copy),
            label: 'Dossiers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'Tests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reload dossiers
          setState(() {
            _isLoading = true;
          });
          _loadDossiers();
        },
        tooltip: 'Rafraîchir',
        child: const Icon(Icons.refresh),
      ),
    );
  }
  
  Widget _buildDossierCard(Map<String, dynamic> dossier) {
    final Color statusColor = {
      'En attente': Colors.orange,
      'Assigné': Colors.blue,
      'En test': Colors.green,
    }[dossier['status']] ?? Colors.grey;
    
    final Color urgencyColor = {
      'Normale': Colors.green,
      'Urgente': Colors.orange,
      'Très urgente': Colors.red,
    }[dossier['urgency']] ?? Colors.grey;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ID and type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dossier['id'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Type: ${dossier['type']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Status chip
                Chip(
                  label: Text(dossier['status']),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Client name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Client:',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        dossier['clientName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Date received
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reçu le:',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      dossier['dateReceived'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Urgency label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Urgence:',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      dossier['urgency'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: urgencyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Technician and receiver info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.engineering, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dossier['technician'],
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dossier['receptor'],
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  children: [
                    // View details button
                    ElevatedButton.icon(
                      onPressed: () => _viewDossierDetails(dossier['id']),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Détails'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Assign tests button (only for 'En attente' status)
                    if (dossier['status'] == 'En attente')
                      ElevatedButton.icon(
                        onPressed: () => _assignTests(dossier['id']),
                        icon: const Icon(Icons.assignment, size: 16),
                        label: const Text('Assigner'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.green,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            // Show assigned tests if available
            if (dossier['status'] != 'En attente' && dossier['tests'] != null) ...[
              const Divider(),
              Row(
                children: [
                  const Text(
                    'Tests assignés: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      (dossier['tests'] as List).join(', '),
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (dossier['assignedTo'] != null)
                Row(
                  children: [
                    const Text(
                      'Assigné à: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      dossier['assignedTo'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
} 