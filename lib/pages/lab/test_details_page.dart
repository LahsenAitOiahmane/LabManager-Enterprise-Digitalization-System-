import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/drawer_widget.dart';
import '../../utils/constants.dart';

class TestDetailsPage extends StatefulWidget {
  final String testId;
  
  const TestDetailsPage({
    super.key,
    required this.testId,
  });

  @override
  State<TestDetailsPage> createState() => _TestDetailsPageState();
}

class _TestDetailsPageState extends State<TestDetailsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _testData;
  List<Map<String, dynamic>> _testeurs = [];
  String? _selectedTesteurId;
  DateTime? _selectedDeadline;
  final _notesController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _fetchTestDetails();
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchTestDetails() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample data - in a real app this would come from an API based on the test ID
    final Map<String, dynamic> testData = {
      'id': widget.testId,
      'name': 'Analyse granulométrique',
      'status': 'en_cours', // pending, en_cours, completed, delayed
      'dossierId': 'DOS-2023-001',
      'dossierType': 'Sol',
      'dossierName': 'Prélèvement Site Route Nationale 1',
      'testerId': 'OP-001',
      'testerName': 'Karim Benali',
      'testerEmail': 'karim.benali@lpee.ma',
      'testerPhone': '+212 6 61 23 45 67',
      'deadline': DateTime.now().add(const Duration(days: 1)),
      'assignedDate': DateTime.now().subtract(const Duration(days: 1)),
      'startDate': DateTime.now().subtract(const Duration(hours: 8)),
      'estimatedCompletionDate': DateTime.now().add(const Duration(days: 1)),
      'priority': 'haute', // basse, normale, haute
      'resource': 'Machine A-32',
      'resourceLocation': 'Laboratoire Central - Salle 3',
      'progress': 60,
      'estimatedDuration': '48 heures',
      'standardMethod': 'NM 13.1.008',
      'client': 'Société Générale de Travaux',
      'clientReference': 'SGT-2023-0542',
      'notes': 'Aucun problème identifié. Progression normale.',
      'history': [
        {
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'action': 'Assigné',
          'user': 'Mohammed Alami',
          'notes': 'Test assigné à Karim Benali'
        },
        {
          'date': DateTime.now().subtract(const Duration(hours: 12)),
          'action': 'Préparation',
          'user': 'Karim Benali',
          'notes': 'Démarrage de la préparation des échantillons'
        },
        {
          'date': DateTime.now().subtract(const Duration(hours: 8)),
          'action': 'Démarrage',
          'user': 'Karim Benali',
          'notes': 'Début du test'
        },
        {
          'date': DateTime.now().subtract(const Duration(hours: 4)),
          'action': 'Progrès',
          'user': 'Karim Benali',
          'notes': 'Test à 60% de progression'
        }
      ],
    };
    
    // Sample testeurs data
    final testeurs = [
      {
        'id': 'OP-001',
        'name': 'Karim Benali',
        'specialty': 'Sols et Granulats',
        'workload': 'medium', // low, medium, high
        'availability': true,
      },
      {
        'id': 'OP-002',
        'name': 'Fatima Zahrae',
        'specialty': 'Sols et Bétons',
        'workload': 'low',
        'availability': true,
      },
      {
        'id': 'OP-003',
        'name': 'Ahmed Lamrani',
        'specialty': 'Eau et Chimie',
        'workload': 'high',
        'availability': false,
      },
      {
        'id': 'OP-004',
        'name': 'Siham El Ouazzani',
        'specialty': 'Bétons et Matériaux',
        'workload': 'medium',
        'availability': true,
      },
    ];
    
    setState(() {
      _testData = testData;
      _testeurs = testeurs;
      _selectedTesteurId = testData['testerId'];
      _selectedDeadline = testData['deadline'];
      _notesController.text = testData['notes'];
      _isLoading = false;
    });
  }
  
  void _showReassignDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réassigner le Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sélectionner un testeur:'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.maxFinite,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedTesteurId,
                isExpanded: true,
                items: _testeurs.map((testeur) {
                  final workloadColor = {
                    'low': Colors.green,
                    'medium': Colors.orange,
                    'high': Colors.red,
                  }[testeur['workload']] ?? Colors.grey;
                  
                  return DropdownMenuItem<String>(
                    value: testeur['id'],
                    enabled: testeur['availability'] == true,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: workloadColor.withOpacity(0.2),
                          radius: 12,
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: workloadColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${testeur['name']} (${testeur['specialty']})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (testeur['availability'] != true)
                          const Icon(Icons.block, color: Colors.red, size: 16),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTesteurId = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Note de réassignation:'),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Raison de la réassignation',
              ),
            ),
          ],
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
              // In a real app, you'd call an API to reassign the test
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test réassigné avec succès')),
              );
            },
            child: const Text('Réassigner'),
          ),
        ],
      ),
    );
  }
  
  void _showRescheduleDialog() {
    DateTime? tempSelectedDate = _selectedDeadline;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reprogrammer la Date Limite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nouvelle date limite:'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                // Show date picker
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: tempSelectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                
                if (picked != null) {
                  setState(() {
                    tempSelectedDate = picked;
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
                      tempSelectedDate != null 
                          ? DateFormat('dd/MM/yyyy').format(tempSelectedDate!)
                          : 'Sélectionner une date',
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Raison du changement:'),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Raison du changement de date',
              ),
            ),
          ],
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
              // In a real app, you'd call an API to reschedule the test
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Date limite modifiée avec succès')),
              );
            },
            child: const Text('Reprogrammer'),
          ),
        ],
      ),
    );
  }
  
  void _saveNotes() {
    // In a real app, you'd call an API to save the notes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notes enregistrées avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test ${widget.testId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _fetchTestDetails();
            },
          ),
        ],
      ),
      drawer: const DrawerWidget(
        role: UserRole.labManager,
        selectedRoute: Routes.labTestDetails,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _testData == null
              ? const Center(child: Text('Erreur lors du chargement des détails du test'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Test header with status and actions
                      _buildTestHeader(),
                      
                      const Divider(height: 32),
                      
                      // Dossier info
                      _buildSectionHeader('Informations Dossier'),
                      _buildDossierInfo(),
                      
                      const SizedBox(height: 24),
                      
                      // Testeur info
                      _buildSectionHeader('Testeur Assigné'),
                      _buildTesteurInfo(),
                      
                      const SizedBox(height: 24),
                      
                      // Test details
                      _buildSectionHeader('Détails du Test'),
                      _buildTestDetails(),
                      
                      const SizedBox(height: 24),
                      
                      // Resource info
                      _buildSectionHeader('Ressources'),
                      _buildResourceInfo(),
                      
                      const SizedBox(height: 24),
                      
                      // Notes
                      _buildSectionHeader('Notes'),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _notesController,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Ajouter des notes sur ce test...',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: _saveNotes,
                                  icon: const Icon(Icons.save),
                                  label: const Text('Enregistrer'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Test history
                      _buildSectionHeader('Historique'),
                      _buildHistoryTimeline(),
                      
                      const SizedBox(height: 32),
                      
                      // Action buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildTestHeader() {
    final Color statusColor = {
      'pending': Colors.blue,
      'en_cours': Colors.amber,
      'completed': Colors.green,
      'delayed': Colors.red,
    }[_testData!['status']] ?? Colors.grey;
    
    final String statusText = {
      'pending': 'En attente',
      'en_cours': 'En cours',
      'completed': 'Terminé',
      'delayed': 'Retardé',
    }[_testData!['status']] ?? 'Inconnu';
    
    final Color priorityColor = {
      'basse': Colors.green,
      'normale': Colors.blue,
      'haute': Colors.red,
    }[_testData!['priority']] ?? Colors.grey;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Test ID and name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _testData!['id'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _testData!['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status chip
                Chip(
                  label: Text(statusText),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: statusColor),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progression: ${_testData!['progress']}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag,
                            size: 16,
                            color: priorityColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Priorité ${_testData!['priority']}',
                            style: TextStyle(
                              color: priorityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: _testData!['progress'] / 100,
                  backgroundColor: Colors.grey[300],
                  color: statusColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Date info
            Column(
              children: [
                // Assignment date
                Row(
                  children: [
                    const Icon(Icons.assignment_turned_in, size: 16),
                    const SizedBox(width: 8),
                    const Text('Assigné le: '),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_testData!['assignedDate']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Start date
                if (_testData!['startDate'] != null)
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline, size: 16),
                      const SizedBox(width: 8),
                      const Text('Démarré le: '),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_testData!['startDate']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 4),
                
                // Deadline
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 16, 
                      color: _testData!['deadline'].isBefore(DateTime.now()) && 
                             _testData!['status'] != 'completed'
                          ? Colors.red
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Date limite: '),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_testData!['deadline']),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _testData!['deadline'].isBefore(DateTime.now()) && 
                               _testData!['status'] != 'completed'
                            ? Colors.red
                            : null,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Estimated completion
                Row(
                  children: [
                    const Icon(Icons.update, size: 16),
                    const SizedBox(width: 8),
                    const Text('Achèvement estimé: '),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_testData!['estimatedCompletionDate']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDossierInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ID Dossier'),
                      Text(
                        _testData!['dossierId'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Type'),
                      Text(
                        _testData!['dossierType'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.business, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Client: ${_testData!['client']}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.description, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Référence: ${_testData!['clientReference']}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.folder, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Nom: ${_testData!['dossierName']}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTesteurInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.person, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _testData!['testerName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'ID: ${_testData!['testerId']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _showReassignDialog,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Réassigner'),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.email, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Email: ${_testData!['testerEmail']}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Téléphone: ${_testData!['testerPhone']}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestDetails() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Durée Estimée'),
                      Text(
                        _testData!['estimatedDuration'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Méthode Standard'),
                      Text(
                        _testData!['standardMethod'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showRescheduleDialog,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Reprogrammer'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResourceInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.science, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ressource'),
                      Text(
                        _testData!['resource'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Emplacement: ${_testData!['resourceLocation']}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHistoryTimeline() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (var i = 0; i < _testData!['history'].length; i++)
              _buildHistoryItem(_testData!['history'][i], i == _testData!['history'].length - 1),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHistoryItem(Map<String, dynamic> item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 64,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['action'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Par ${item['user']} le ${DateFormat('dd/MM/yyyy HH:mm').format(item['date'])}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(item['notes']),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _testData!['status'] != 'completed' ? _showReassignDialog : null,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Réassigner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _testData!['status'] != 'completed' ? _showRescheduleDialog : null,
            icon: const Icon(Icons.event),
            label: const Text('Reprogrammer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
} 