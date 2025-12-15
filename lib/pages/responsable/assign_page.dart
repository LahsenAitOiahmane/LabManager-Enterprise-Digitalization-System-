import 'package:flutter/material.dart';

class ResponsableAssignPage extends StatefulWidget {
  final String dossierId;
  
  const ResponsableAssignPage({
    super.key,
    required this.dossierId,
  });

  @override
  State<ResponsableAssignPage> createState() => _ResponsableAssignPageState();
}

class _ResponsableAssignPageState extends State<ResponsableAssignPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _availableTests = [];
  List<Map<String, dynamic>> _availableTechnicians = [];
  
  // Selected values
  final List<String> _selectedTestIds = [];
  String? _selectedTechnicianId;
  String _testUrgency = 'Normale';
  final TextEditingController _notesController = TextEditingController();
  DateTime _estimatedCompletion = DateTime.now().add(const Duration(days: 3));
  
  final List<String> _urgencyOptions = ['Normale', 'Urgente', 'Très urgente'];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample tests data
    final tests = [
      {'id': 'T-001', 'name': 'Analyse granulométrique', 'duration': '48h', 'price': 1200, 'category': 'Physique'},
      {'id': 'T-002', 'name': 'Limites d\'Atterberg', 'duration': '24h', 'price': 900, 'category': 'Physique'},
      {'id': 'T-003', 'name': 'Teneur en eau', 'duration': '24h', 'price': 400, 'category': 'Physique'},
      {'id': 'T-004', 'name': 'Essai Proctor modifié', 'duration': '72h', 'price': 1800, 'category': 'Mécanique'},
      {'id': 'T-005', 'name': 'CBR (California Bearing Ratio)', 'duration': '120h', 'price': 2200, 'category': 'Mécanique'},
      {'id': 'T-006', 'name': 'Essai de compressibilité', 'duration': '168h', 'price': 3500, 'category': 'Mécanique'},
      {'id': 'T-007', 'name': 'Analyse de carbonate', 'duration': '48h', 'price': 1000, 'category': 'Chimique'},
      {'id': 'T-008', 'name': 'pH du sol', 'duration': '24h', 'price': 450, 'category': 'Chimique'},
    ];
    
    // Sample technicians data
    final technicians = [
      {'id': 'LAB-001', 'name': 'Fatima Zahra', 'specialty': 'Sols et Matériaux', 'workload': 'Faible'},
      {'id': 'LAB-002', 'name': 'Hassan Ouadoudi', 'specialty': 'Chimie et Eaux', 'workload': 'Modérée'},
      {'id': 'LAB-003', 'name': 'Karim Idrissi', 'specialty': 'Sols et Bétons', 'workload': 'Élevée'},
      {'id': 'LAB-004', 'name': 'Nora Bensouda', 'specialty': 'Analyses Chimiques', 'workload': 'Faible'},
    ];
    
    setState(() {
      _availableTests = tests;
      _availableTechnicians = technicians;
      _isLoading = false;
    });
  }
  
  void _toggleTestSelection(String testId) {
    setState(() {
      if (_selectedTestIds.contains(testId)) {
        _selectedTestIds.remove(testId);
      } else {
        _selectedTestIds.add(testId);
      }
      _updateEstimatedCompletion();
    });
  }
  
  void _updateEstimatedCompletion() {
    if (_selectedTestIds.isEmpty) {
      _estimatedCompletion = DateTime.now().add(const Duration(days: 3));
      return;
    }
    
    // Calculate the longest test duration
    int maxHours = 0;
    for (final testId in _selectedTestIds) {
      final test = _availableTests.firstWhere((t) => t['id'] == testId);
      final durationText = test['duration'];
      final hours = int.parse(durationText.replaceAll('h', ''));
      if (hours > maxHours) {
        maxHours = hours;
      }
    }
    
    // Apply urgency factor
    double urgencyFactor = 1.0;
    switch (_testUrgency) {
      case 'Urgente':
        urgencyFactor = 0.75; // 25% faster
        break;
      case 'Très urgente':
        urgencyFactor = 0.5; // 50% faster
        break;
      default:
        urgencyFactor = 1.0;
    }
    
    final adjustedHours = (maxHours * urgencyFactor).round();
    _estimatedCompletion = DateTime.now().add(Duration(hours: adjustedHours));
  }
  
  void _assignTests() {
    if (_selectedTestIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un test'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedTechnicianId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un technicien de laboratoire'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // In a real app, this would make an API call
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      
      // Show success and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tests assignés avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to previous page
      Navigator.pop(context, true); // Return true to indicate successful assignment
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assigner des Tests - ${widget.dossierId}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tests selection section
                  _buildSectionHeader('Sélectionner les Tests à Réaliser'),
                  _buildTestList(),
                  
                  const SizedBox(height: 24),
                  
                  // Technician selection section
                  _buildSectionHeader('Assigner à un Technicien'),
                  _buildTechnicianSelection(),
                  
                  const SizedBox(height: 24),
                  
                  // Test parameters
                  _buildSectionHeader('Paramètres d\'Exécution'),
                  _buildTestParameters(),
                  
                  const SizedBox(height: 24),
                  
                  // Additional notes
                  _buildSectionHeader('Notes Supplémentaires'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          hintText: 'Entrez des instructions spécifiques pour le technicien...',
                          border: InputBorder.none,
                        ),
                        maxLines: 4,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Summary card
                  _buildAssignmentSummary(),
                  
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  _buildActionButtons(),
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
  
  Widget _buildTestList() {
    // Group tests by category
    final Map<String, List<Map<String, dynamic>>> testsByCategory = {};
    for (final test in _availableTests) {
      final category = test['category'] as String;
      if (!testsByCategory.containsKey(category)) {
        testsByCategory[category] = [];
      }
      testsByCategory[category]!.add(test);
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: testsByCategory.entries.map((entry) {
            final category = entry.key;
            final tests = entry.value;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...tests.map((test) => _buildTestCheckbox(test)),
                const Divider(height: 24),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildTestCheckbox(Map<String, dynamic> test) {
    final isSelected = _selectedTestIds.contains(test['id']);
    
    return CheckboxListTile(
      value: isSelected,
      onChanged: (bool? value) {
        if (value != null) {
          _toggleTestSelection(test['id']);
        }
      },
      title: Text(test['name']),
      subtitle: Text('Durée: ${test['duration']} - Prix: ${test['price']} MAD'),
      secondary: CircleAvatar(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
        child: Icon(
          Icons.science,
          color: isSelected ? Colors.white : Colors.grey[600],
        ),
      ),
      activeColor: Theme.of(context).primaryColor,
    );
  }
  
  Widget _buildTechnicianSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Technicien de Laboratoire',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Sélectionner un technicien'),
              initialValue: _selectedTechnicianId,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTechnicianId = newValue;
                });
              },
              items: _availableTechnicians.map<DropdownMenuItem<String>>((Map<String, dynamic> technician) {
                return DropdownMenuItem<String>(
                  value: technician['id'],
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getWorkloadColor(technician['workload']),
                        radius: 12,
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${technician['name']} - ${technician['specialty']}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (_selectedTechnicianId != null)
              _buildTechnicianInfo(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTechnicianInfo() {
    final technician = _availableTechnicians.firstWhere(
      (tech) => tech['id'] == _selectedTechnicianId,
    );
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Informations sur le technicien',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('ID', technician['id']),
          _buildInfoRow('Nom Complet', technician['name']),
          _buildInfoRow('Spécialité', technician['specialty']),
          _buildInfoRow(
            'Charge de Travail',
            technician['workload'],
            valueColor: _getWorkloadColor(technician['workload']),
          ),
        ],
      ),
    );
  }
  
  Color _getWorkloadColor(String workload) {
    switch (workload) {
      case 'Faible':
        return Colors.green;
      case 'Modérée':
        return Colors.orange;
      case 'Élevée':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTestParameters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Niveau d\'Urgence',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _urgencyOptions.map((option) {
                final isSelected = _testUrgency == option;
                final color = {
                  'Normale': Colors.green,
                  'Urgente': Colors.orange,
                  'Très urgente': Colors.red,
                }[option] ?? Colors.grey;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _testUrgency = option;
                        _updateEstimatedCompletion();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            {
                              'Normale': Icons.schedule,
                              'Urgente': Icons.timelapse,
                              'Très urgente': Icons.priority_high,
                            }[option] ?? Icons.schedule,
                            color: isSelected ? color : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? color : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Date d\'achèvement estimée',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date d\'achèvement estimée',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '${_estimatedCompletion.day}/${_estimatedCompletion.month}/${_estimatedCompletion.year} à ${_estimatedCompletion.hour}:${_estimatedCompletion.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAssignmentSummary() {
    final totalSelectedTests = _selectedTestIds.length;
    int totalPrice = 0;
    int maxDuration = 0;
    
    for (final testId in _selectedTestIds) {
      final test = _availableTests.firstWhere((t) => t['id'] == testId);
      totalPrice += test['price'] as int;
      
      final durationText = test['duration'];
      final hours = int.parse(durationText.replaceAll('h', ''));
      if (hours > maxDuration) {
        maxDuration = hours;
      }
    }
    
    return Card(
      elevation: 3,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Résumé de l\'Assignation',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Prélèvement ID',
              widget.dossierId,
              icon: Icons.folder,
            ),
            _buildSummaryRow(
              'Tests Sélectionnés',
              '$totalSelectedTests tests',
              icon: Icons.science,
            ),
            _buildSummaryRow(
              'Technicien Assigné',
              _selectedTechnicianId != null
                  ? _availableTechnicians.firstWhere((t) => t['id'] == _selectedTechnicianId)['name']
                  : 'Non sélectionné',
              icon: Icons.person,
              valueColor: _selectedTechnicianId != null ? null : Colors.red,
            ),
            _buildSummaryRow(
              'Niveau d\'Urgence',
              _testUrgency,
              icon: Icons.priority_high,
              valueColor: {
                'Normale': Colors.green,
                'Urgente': Colors.orange,
                'Très urgente': Colors.red,
              }[_testUrgency],
            ),
            _buildSummaryRow(
              'Coût Total (MAD)',
              totalPrice.toString(),
              icon: Icons.attach_money,
            ),
            _buildSummaryRow(
              'Date d\'Achèvement',
              '${_estimatedCompletion.day}/${_estimatedCompletion.month}/${_estimatedCompletion.year}',
              icon: Icons.event,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {IconData? icon, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
          ],
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    final bool canAssign = _selectedTestIds.isNotEmpty && _selectedTechnicianId != null;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: canAssign ? _assignTests : null,
          icon: const Icon(Icons.check_circle),
          label: const Text('Assigner les Tests'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            disabledBackgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.cancel),
          label: const Text('Annuler'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
} 