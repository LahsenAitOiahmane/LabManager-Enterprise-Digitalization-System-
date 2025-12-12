import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/page_animations.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceptionDetailsPage extends StatefulWidget {
  final String prelevementId;
  
  const ReceptionDetailsPage({
    super.key,
    required this.prelevementId,
  });

  @override
  State<ReceptionDetailsPage> createState() => _ReceptionDetailsPageState();
}

class _ReceptionDetailsPageState extends State<ReceptionDetailsPage> 
    with TickerProviderStateMixin, PageAnimationsMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _prelevement;
  
  @override
  void initState() {
    super.initState();
    initAnimations();
    _loadPrelevementData();
    startAnimations();
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }
  
  Future<void> _loadPrelevementData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Simulate API call to fetch prélèvement details
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, we'll use mock data
      _prelevement = {
        'id': widget.prelevementId,
        'material': 'Soil',
        'location': 'Casablanca - Site A',
        'description': 'Sample collected from foundation excavation',
        'status': 'Validated',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'created_by': 'tech_1',
        'has_photos': true,
        'coords': {'lat': 33.5731, 'lng': -7.5898},
        'photos': [
          'https://example.com/photo1.jpg',
          'https://example.com/photo2.jpg',
        ],
        'notes': 'Sample appears to be in good condition. Collected from depth of 1.5m.',
        'tests': [
          {
            'test_id': 'TEST-001',
            'name': 'pH Analysis',
            'status': 'Pending',
            'assigned_to': 'lab_tech_1',
          },
          {
            'test_id': 'TEST-002',
            'name': 'Moisture Content',
            'status': 'Completed',
            'assigned_to': 'lab_tech_2',
            'results': {
              'moisture': '12.5%',
              'date_completed': DateTime.now().subtract(const Duration(hours: 12)),
            },
          },
        ],
      };
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading prélèvement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    // Enhanced colors for better dark mode compatibility
    final cardColor = isDarkMode 
        ? Color.fromARGB(255, 30, 34, 28) 
        : Theme.of(context).cardColor;
    
    final accentColor = isDarkMode
        ? Color.fromARGB(255, 139, 195, 74) // Brighter green in dark mode
        : primaryColor;
        
    final textColor = isDarkMode
        ? Colors.white
        : Theme.of(context).textTheme.bodyMedium?.color;
        
    final subtleTextColor = isDarkMode
        ? Colors.grey[300]
        : Colors.grey[700];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Prélèvement Details'),
        backgroundColor: isDarkMode ? Color.fromARGB(255, 30, 40, 28) : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prelevement == null
              ? Center(
                  child: Text(
                    'Prélèvement not found',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QR Code and ID
                      AnimatedPageItem(
                        delay: const Duration(milliseconds: 100),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data: _prelevement!['id'],
                                  version: QrVersions.auto,
                                  size: 150,
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _prelevement!['id'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildStatusChip(_prelevement!['status']),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Details Section
                      AnimatedPageItem(
                        delay: const Duration(milliseconds: 150),
                        child: Card(
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Date', accentColor),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(_prelevement!['date']),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSectionTitle('Material', accentColor),
                                const SizedBox(height: 8),
                                Text(
                                  _prelevement!['material'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSectionTitle('Location', accentColor),
                                const SizedBox(height: 8),
                                Text(
                                  _prelevement!['location'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Description and Notes
                      AnimatedPageItem(
                        delay: const Duration(milliseconds: 200),
                        child: Card(
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Description', accentColor),
                                const SizedBox(height: 8),
                                Text(
                                  _prelevement!['description'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                if (_prelevement!['notes'] != null) ...[
                                  const SizedBox(height: 16),
                                  _buildSectionTitle('Notes', accentColor),
                                  const SizedBox(height: 8),
                                  Text(
                                    _prelevement!['notes'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Photos
                      if (_prelevement!['has_photos'] && _prelevement!['photos'] != null)
                        AnimatedPageItem(
                          delay: const Duration(milliseconds: 250),
                          child: Card(
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Photos', accentColor),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: (_prelevement!['photos'] as List).length,
                                      itemBuilder: (context, index) {
                                        // In a real app, load images from URLs
                                        return Container(
                                          width: 120,
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.image,
                                              size: 32,
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      
                      // Tests
                      if (_prelevement!['tests'] != null)
                        AnimatedPageItem(
                          delay: const Duration(milliseconds: 300),
                          child: Card(
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Tests', accentColor),
                                  const SizedBox(height: 16),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: (_prelevement!['tests'] as List).length,
                                    separatorBuilder: (context, index) => const Divider(),
                                    itemBuilder: (context, index) {
                                      final test = (_prelevement!['tests'] as List)[index];
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                test['name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                              _buildStatusChip(test['status']),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Test ID: ${test['test_id']}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: subtleTextColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Assigned to: ${test['assigned_to']}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: subtleTextColor,
                                            ),
                                          ),
                                          if (test['results'] != null) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: isDarkMode 
                                                  ? Colors.green.withOpacity(0.2) 
                                                  : Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.green.withOpacity(0.3),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Results:',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Moisture: ${test['results']['moisture']}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Completed: ${DateFormat('dd/MM/yyyy HH:mm').format(test['results']['date_completed'])}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: subtleTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String label;
    
    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        label = 'Pending';
        break;
      case 'received':
      case 'receptioned':
        chipColor = Colors.blue;
        label = 'Received';
        break;
      case 'processing':
        chipColor = Colors.purple;
        label = 'Processing';
        break;
      case 'completed':
      case 'validated':
        chipColor = Colors.green;
        label = status.toLowerCase() == 'completed' ? 'Completed' : 'Validated';
        break;
      case 'rejected':
      case 'refused':
        chipColor = Colors.red;
        label = 'Rejected';
        break;
      default:
        chipColor = Colors.grey;
        label = 'Unknown';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        border: Border.all(color: chipColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
} 