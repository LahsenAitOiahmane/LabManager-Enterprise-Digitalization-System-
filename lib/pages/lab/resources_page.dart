import 'package:flutter/material.dart';
import '../../widgets/drawer_widget.dart';
import '../../utils/constants.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> with TickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _equipment = [];
  List<Map<String, dynamic>> _consumables = [];
  List<Map<String, dynamic>> _filteredEquipment = [];
  List<Map<String, dynamic>> _filteredConsumables = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchResourcesData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _fetchResourcesData() async {
    // Simulate API call with a delay
    await Future.delayed(const Duration(seconds: 1));
    
    final equipment = [
      {
        'id': 'EQ001',
        'name': 'Microscope électronique',
        'status': 'En service',
        'lastMaintenance': '2023-12-10',
        'nextMaintenance': '2024-06-10',
        'location': 'Laboratoire A',
        'responsible': 'Dr. Martin',
      },
      {
        'id': 'EQ002',
        'name': 'Spectromètre de masse',
        'status': 'En service',
        'lastMaintenance': '2023-11-15',
        'nextMaintenance': '2024-05-15',
        'location': 'Laboratoire B',
        'responsible': 'Dr. Dubois',
      },
      {
        'id': 'EQ003',
        'name': 'Centrifugeuse réfrigérée',
        'status': 'Maintenance',
        'lastMaintenance': '2024-01-20',
        'nextMaintenance': '2024-07-20',
        'location': 'Laboratoire C',
        'responsible': 'Dr. Chen',
      },
    ];
    
    final consumables = [
      {
        'id': 'CON001',
        'name': 'Réactifs PCR',
        'currentStock': 15,
        'minStock': 5,
        'lastOrdered': '2024-01-05',
        'supplier': 'BioTech Solutions',
        'location': 'Stock principal',
      },
      {
        'id': 'CON002',
        'name': 'Kits d\'extraction ADN',
        'currentStock': 3,
        'minStock': 5,
        'lastOrdered': '2023-12-01',
        'supplier': 'GeneExpress',
        'location': 'Stock principal',
      },
      {
        'id': 'CON003',
        'name': 'Plaques de culture 96 puits',
        'currentStock': 50,
        'minStock': 20,
        'lastOrdered': '2024-02-10',
        'supplier': 'LabSupplies',
        'location': 'Stock secondaire',
      },
    ];
    
    setState(() {
      _equipment = equipment;
      _consumables = consumables;
      _filteredEquipment = equipment;
      _filteredConsumables = consumables;
      _isLoading = false;
    });
  }
  
  void _applyFilters(String query) {
    setState(() {
      _filteredEquipment = _equipment.where((item) => 
        item['name'].toLowerCase().contains(query.toLowerCase()) ||
        item['id'].toLowerCase().contains(query.toLowerCase()) ||
        item['status'].toLowerCase().contains(query.toLowerCase())
      ).toList();
      
      _filteredConsumables = _consumables.where((item) => 
        item['name'].toLowerCase().contains(query.toLowerCase()) ||
        item['id'].toLowerCase().contains(query.toLowerCase()) ||
        item['supplier'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }
  
  void _orderConsumable(Map<String, dynamic> item) {
    // Show dialog to confirm order
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Commander ${item['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stock actuel: ${item['currentStock']}'),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Quantité à commander',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Commande de ${item['name']} envoyée'))
              );
            },
            child: const Text('Commander'),
          ),
        ],
      ),
    );
  }
  
  void _scheduleMaintenance(Map<String, dynamic> item) {
    // Show dialog to schedule maintenance
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Programmer la maintenance de ${item['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dernière maintenance: ${item['lastMaintenance']}'),
            Text('Prochaine maintenance prévue: ${item['nextMaintenance']}'),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nouvelle date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () {
                // Date picker would be shown here
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Maintenance programmée pour ${item['name']}'))
              );
            },
            child: const Text('Programmer'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Ressources'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Équipements'),
            Tab(text: 'Consommables'),
          ],
        ),
      ),
      drawer: DrawerWidget(
        selectedRoute: Routes.labResources,
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
                    labelText: 'Rechercher',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters('');
                      },
                    ),
                  ),
                  onChanged: _applyFilters,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Equipment tab
                    _buildEquipmentList(),
                    // Consumables tab
                    _buildConsumablesList(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une ressource'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    // Show dialog to add new resource
                  },
                ),
              ),
            ],
          ),
    );
  }
  
  Widget _buildEquipmentList() {
    return _filteredEquipment.isEmpty
        ? const Center(child: Text('Aucun équipement trouvé'))
        : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: _filteredEquipment.length,
            itemBuilder: (context, index) {
              final item = _filteredEquipment[index];
              final isMaintenanceSoon = DateTime.parse(item['nextMaintenance']).difference(DateTime.now()).inDays < 30;
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ExpansionTile(
                  title: Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID: ${item['id']} • ${item['status']}'),
                  leading: Icon(
                    Icons.science,
                    color: item['status'] == 'En service' ? Colors.green : Colors.orange,
                    size: 36,
                  ),
                  trailing: isMaintenanceSoon ? 
                    const Chip(
                      label: Text('Maintenance prévue'),
                      backgroundColor: Colors.amber,
                    ) : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Emplacement', item['location']),
                          _infoRow('Responsable', item['responsible']),
                          _infoRow('Dernière maintenance', item['lastMaintenance']),
                          _infoRow('Prochaine maintenance', item['nextMaintenance']),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.history),
                                label: const Text('Historique'),
                                onPressed: () {
                                  // Show maintenance history
                                },
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Maintenance'),
                                onPressed: () => _scheduleMaintenance(item),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
  
  Widget _buildConsumablesList() {
    return _filteredConsumables.isEmpty
        ? const Center(child: Text('Aucun consommable trouvé'))
        : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: _filteredConsumables.length,
            itemBuilder: (context, index) {
              final item = _filteredConsumables[index];
              final bool isLowStock = item['currentStock'] <= item['minStock'];
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ExpansionTile(
                  title: Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID: ${item['id']} • Stock: ${item['currentStock']}'),
                  leading: Icon(
                    Icons.inventory,
                    color: isLowStock ? Colors.red : Colors.blue,
                    size: 36,
                  ),
                  trailing: isLowStock ? 
                    const Chip(
                      label: Text('Stock bas'),
                      backgroundColor: Colors.red,
                    ) : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Stock actuel', '${item['currentStock']}'),
                          _infoRow('Stock minimum', '${item['minStock']}'),
                          _infoRow('Emplacement', item['location']),
                          _infoRow('Fournisseur', item['supplier']),
                          _infoRow('Dernière commande', item['lastOrdered']),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.history),
                                label: const Text('Historique'),
                                onPressed: () {
                                  // Show order history
                                },
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.shopping_cart),
                                label: const Text('Commander'),
                                onPressed: () => _orderConsumable(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLowStock ? Colors.red : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
  
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
} 