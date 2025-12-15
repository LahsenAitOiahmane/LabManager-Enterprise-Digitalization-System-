import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/drawer_widget.dart';
import '../../utils/constants.dart';

class TestAssignmentPage extends StatefulWidget {
  final String? testId;
  
  const TestAssignmentPage({
    super.key,
    this.testId,
  });

  @override
  State<TestAssignmentPage> createState() => _TestAssignmentPageState();
}

class _TestAssignmentPageState extends State<TestAssignmentPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _availableTests = [];
  List<Map<String, dynamic>> _availableTesters = [];
  
  // Selected values
  String? _selectedTestId;
  String? _selectedTesterId;
  String _priority = 'Normal';
  final TextEditingController _notesController = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 2));
  
  final List<String> _priorityOptions = ['Low', 'Normal', 'High', 'Urgent'];
  
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
      {
        'id': 'T-1234',
        'name': 'Résistance à la compression',
        'type': 'Bétons',
        'duration': '12h',
        'status': 'pending',
        'equipment': ['Presse hydraulique', 'Moules cubiques'],
        'sample_id': 'S-5678',
        'sample_name': 'Échantillon béton B25',
        'dossier_id': 'D-089',
        'dossier_name': 'Projet Autoroute Rabat-Casablanca',
      },
      {
        'id': 'T-1235',
        'name': 'Analyse granulométrique',
        'type': 'Granulats',
        'duration': '5h',
        'status': 'pending',
        'equipment': ['Tamiseuse électrique', 'Balance de précision'],
        'sample_id': 'S-5679',
        'sample_name': 'Granulats 0/31.5',
        'dossier_id': 'D-090',
        'dossier_name': 'Construction Centre Commercial Marrakech',
      },
      {
        'id': 'T-1236',
        'name': 'Limites d\'Atterberg',
        'type': 'Sols',
        'duration': '6h', 
        'status': 'pending',
        'equipment': ['Appareil de Casagrande', 'Outil à rainurer'],
        'sample_id': 'S-5680',
        'sample_name': 'Sol argileux',
        'dossier_id': 'D-091',
        'dossier_name': 'Résidence El Firdaous',
      },
      {
        'id': 'T-1237',
        'name': 'Proctor Modifié',
        'type': 'Sols',
        'duration': '9h',
        'status': 'pending',
        'equipment': ['Dame Proctor', 'Moule CBR'],
        'sample_id': 'S-5681',
        'sample_name': 'Sol compacté',
        'dossier_id': 'D-092',
        'dossier_name': 'Barrage Oued Laou',
      },
    ];
    
    // Sample testers data
    final testers = [
      {
        'id': 'TECH001',
        'name': 'Amal Bousquet',
        'specialty': 'Microbiologie',
        'workload': 68,
        'avatar': 'assets/avatars/avatar1.jpg',
        'status': 'Active',
      },
      {
        'id': 'TECH002',
        'name': 'Lucas Moreau',
        'specialty': 'Chimie analytique',
        'workload': 42,
        'avatar': 'assets/avatars/avatar2.jpg',
        'status': 'Active',
      },
      {
        'id': 'TECH003',
        'name': 'Sophie Dupont',
        'specialty': 'Biologie moléculaire',
        'workload': 75,
        'avatar': 'assets/avatars/avatar3.jpg',
        'status': 'Congé',
      },
      {
        'id': 'TECH004',
        'name': 'Mohamed Lahlou',
        'specialty': 'Hématologie',
        'workload': 55,
        'avatar': 'assets/avatars/avatar4.jpg',
        'status': 'Active',
      },
    ];
    
    setState(() {
      _availableTests = tests;
      _availableTesters = testers;
      
      // If a test ID was provided, preselect it
      if (widget.testId != null) {
        _selectedTestId = widget.testId;
      }
      
      _isLoading = false;
    });
  }
  
  void _updateDeadline() {
    if (_selectedTestId == null) {
      _deadline = DateTime.now().add(const Duration(days: 2));
      return;
    }
    
    // Get the test duration
    final test = _availableTests.firstWhere((t) => t['id'] == _selectedTestId);
    final durationText = test['duration'] as String;
    final hours = int.parse(durationText.replaceAll('h', ''));
    
    // Apply priority factor
    double priorityFactor = 1.0;
    switch (_priority) {
      case 'Urgent':
        priorityFactor = 0.5; // 50% faster
        break;
      case 'High':
        priorityFactor = 0.75; // 25% faster
        break;
      case 'Low':
        priorityFactor = 1.5; // 50% slower
        break;
      default:
        priorityFactor = 1.0;
    }
    
    final adjustedHours = (hours * priorityFactor).round();
    _deadline = DateTime.now().add(Duration(hours: adjustedHours));
  }
  
  void _assignTest() {
    if (_selectedTestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a test to assign'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedTesterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a tester to assign the test to'),
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
          content: Text('Test assigned successfully'),
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
        title: const Text('Assign Test'),
      ),
      drawer: DrawerWidget(
        role: UserRole.labManager,
        selectedRoute: Routes.labTests,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Test selection section
                  _buildSectionHeader('Select Test to Assign'),
                  _buildTestSelection(),
                  
                  const SizedBox(height: 24),
                  
                  // Tester selection section
                  _buildSectionHeader('Assign to Tester'),
                  _buildTesterSelection(),
                  
                  const SizedBox(height: 24),
                  
                  // Test parameters
                  _buildSectionHeader('Execution Parameters'),
                  _buildTestParameters(),
                  
                  const SizedBox(height: 24),
                  
                  // Additional notes
                  _buildSectionHeader('Additional Notes'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          hintText: 'Enter specific instructions for the tester...',
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
  
  Widget _buildTestSelection() {
    // Get the selected test if available
    Map<String, dynamic>? selectedTest;
    if (_selectedTestId != null) {
      try {
        selectedTest = _availableTests.firstWhere(
          (t) => t['id'] == _selectedTestId, 
        );
      } catch (e) {
        // If test not found, return an empty map
        selectedTest = <String, dynamic>{};
      }
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If a test was preselected, show its details
            if (selectedTest != null && selectedTest.isNotEmpty) 
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.science, color: Colors.white),
                ),
                title: Text(
                  selectedTest['name'], 
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedTest['type'],
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Duration: ${selectedTest['duration']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Sample: ${selectedTest['sample_name']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedTestId = null;
                    });
                  },
                ),
              )
            else
              // If no test was preselected, show a dropdown
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select Test',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedTestId,
                items: _availableTests.map((test) {
                  return DropdownMenuItem<String>(
                    value: test['id'] as String,
                    child: Text(
                      '${test['id']} - ${test['name']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTestId = value;
                    _updateDeadline(); // Update deadline based on test duration
                  });
                },
              ),
              
            // Show additional test details if a test is selected
            if (_selectedTestId != null && selectedTest != null && selectedTest.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Type: ${selectedTest['type']}',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Duration: ${selectedTest['duration']}',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Equipment: ${(selectedTest['equipment'] as List).join(', ')}',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Sample: ${selectedTest['sample_id']} - ${selectedTest['sample_name']}',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Dossier: ${selectedTest['dossier_id']} - ${selectedTest['dossier_name']}',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTesterSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._availableTesters.map((tester) {
              final isSelected = _selectedTesterId == tester['id'];
              final workload = tester['workload'] as int;
              
              // Determine workload color
              Color workloadColor;
              if (workload < 50) {
                workloadColor = Colors.green;
              } else if (workload < 75) {
                workloadColor = Colors.orange;
              } else {
                workloadColor = Colors.red;
              }
              
              // Disable testers on leave
              final bool isEnabled = tester['status'] != 'Congé';
              
              return Opacity(
                opacity: isEnabled ? 1.0 : 0.5,
                child: ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(tester['avatar']),
                        backgroundColor: Colors.grey[200],
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: isEnabled ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    tester['name'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${tester['specialty']} • Workload: ${tester['workload']}%',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: workloadColor, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              '${tester['workload']}%',
                              style: TextStyle(
                                color: workloadColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Radio<String>(
                          value: tester['id'] as String,
                          groupValue: _selectedTesterId,
                          onChanged: isEnabled
                              ? (value) {
                                  setState(() {
                                    _selectedTesterId = value;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  onTap: isEnabled
                      ? () {
                          setState(() {
                            _selectedTesterId = tester['id'] as String;
                          });
                        }
                      : null,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestParameters() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority selection
            DropdownButtonFormField<String>(
              isExpanded: true,
              menuMaxHeight: 300,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              initialValue: _priority,
              items: _priorityOptions.map((priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(
                    priority,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                  _updateDeadline(); // Update deadline based on priority
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Deadline selection
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) {
                  // After picking the date, show time picker
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_deadline),
                  );
                  
                  if (pickedTime != null) {
                    setState(() {
                      _deadline = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy - HH:mm').format(_deadline),
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAssignmentSummary() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assignment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSummaryItem(
              'Test',
              _selectedTestId != null
                  ? _availableTests
                      .firstWhere((t) => t['id'] == _selectedTestId)['name']
                  : 'None selected',
            ),
            _buildSummaryItem(
              'Tester',
              _selectedTesterId != null
                  ? _availableTesters
                      .firstWhere((t) => t['id'] == _selectedTesterId)['name']
                  : 'None selected',
            ),
            _buildSummaryItem('Priority', _priority),
            _buildSummaryItem(
              'Deadline',
              DateFormat('dd/MM/yyyy - HH:mm').format(_deadline),
            ),
            if (_notesController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(_notesController.text),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _assignTest,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Assign Test'),
          ),
        ),
      ],
    );
  }
} 