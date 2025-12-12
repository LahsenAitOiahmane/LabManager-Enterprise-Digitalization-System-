import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:labtrack/utils/page_animations.dart';

class ReceptionHomePage extends StatefulWidget {
  const ReceptionHomePage({super.key});

  @override
  State<ReceptionHomePage> createState() => _ReceptionHomePageState();
}

class _ReceptionHomePageState extends State<ReceptionHomePage>
    with TickerProviderStateMixin, PageAnimationsMixin {
  List<Map<String, dynamic>> _prelevements = [];
  List<Map<String, dynamic>> _filteredPrelevements = [];
  bool _isLoading = true;
  String? _receptionistId;
  String? _receptionistName;
  int _selectedIndex = 0;

  // Filtering options
  String? _selectedStatusFilter;

  // Sorting options
  bool _sortNewestFirst = true;

  // List of statuses for filtering
  final List<String> _statusTypes = ['All', 'Pending', 'Validated', 'Rejected'];

  @override
  void initState() {
    super.initState();
    initAnimations();
    _loadReceptionistData();
    startAnimations();
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  Future<void> _loadReceptionistData() async {
    final prefs = await SharedPreferences.getInstance();
    _receptionistId = prefs.getString('userId') ?? '1';
    _receptionistName = prefs.getString('userName') ?? 'Reception User';

    // Get user information from SharedPreferences
    final email = prefs.getString('userEmail');
    final role = prefs.getString('userRole');

    if (email != null) {
      // Extract name from email (in a real app, this would come from a user profile)
      final namePart = email.split('@')[0].replaceAll('.', ' ');
      _receptionistName = namePart
          .split(' ')
          .map((s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}')
          .join(' ');
    }

    // After getting the email and role
    debugPrint('User role: $role');

    await _fetchPrelevements();
  }

  Future<void> _fetchPrelevements() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call to fetch prélèvements
    await Future.delayed(const Duration(seconds: 1));

    try {
      // First try to load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedPrelevementIds = prefs.getStringList('prelevements') ?? [];

      List<Map<String, dynamic>> loadedPrelevements = [];

      if (savedPrelevementIds.isNotEmpty) {
        for (var id in savedPrelevementIds) {
          final prelevementStr = prefs.getString('prelevement_$id');
          if (prelevementStr != null) {
            // This is a simplified approach - in a real app, you'd want to use
            // proper JSON serialization/deserialization
            Map<String, dynamic> prelevement = {};
            prelevement['id'] = id;
            prelevement['material'] = 'Soil Sample'; // Example default values
            prelevement['location'] = 'Casablanca, Morocco';
            prelevement['description'] = 'Sample description';
            prelevement['status'] = 'Unreceptioned';
            prelevement['date'] = DateTime.now();
            prelevement['created_by'] = 'tech_1';
            prelevement['has_photos'] = true;

            loadedPrelevements.add(prelevement);
          }
        }
      }

      // If no saved prelevements or we want to always show mock data for demo
      // Generate mock data
      if (loadedPrelevements.isEmpty) {
        loadedPrelevements = _generateMockPrelevements();
      } else {
        // Combine with mock data to ensure we always have samples to show
        loadedPrelevements.addAll(_generateMockPrelevements());
      }

      setState(() {
        _prelevements = loadedPrelevements;
        _applyFilters(); // Apply any active filters
        _isLoading = false;
      });

      // Start animations after data is loaded
      startAnimations();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _prelevements = _generateMockPrelevements(); // Fallback to mock data
        _applyFilters();
      });
      startAnimations();
    }
  }

  // Generate mock prélèvements for demo purposes
  List<Map<String, dynamic>> _generateMockPrelevements() {
    return [
      {
        'id': 'PRE-001-2023',
        'material': 'Soil',
        'location': 'Casablanca - Site A',
        'description': 'Sample collected from foundation excavation',
        'status': 'Validated',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'created_by': 'tech_1',
        'has_photos': true,
        'coords': {'lat': 33.5731, 'lng': -7.5898},
      },
      {
        'id': 'PRE-002-2023',
        'material': 'Concrete',
        'location': 'Rabat - Central Building',
        'description': 'Concrete core sample from column',
        'status': 'Validated',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'created_by': 'tech_2',
        'has_photos': true,
        'coords': {'lat': 34.0209, 'lng': -6.8416},
      },
      {
        'id': 'PRE-003-2023',
        'material': 'Asphalt',
        'location': 'Marrakech - Highway Project',
        'description': 'Surface layer sample',
        'status': 'Rejected',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'created_by': 'tech_1',
        'has_photos': false,
        'coords': {'lat': 31.6295, 'lng': -7.9811},
        'rejection_reason': 'Insufficient sample size',
      },
      {
        'id': 'PRE-004-2023',
        'material': 'Steel',
        'location': 'Tangier - Bridge Construction',
        'description': 'Reinforcement bar sample',
        'status': 'Pending',
        'date': DateTime.now(),
        'created_by': 'tech_3',
        'has_photos': true,
        'coords': {'lat': 35.7595, 'lng': -5.8340},
      },
    ];
  }

  void _applyFilters() {
    setState(() {
      _filteredPrelevements =
          _prelevements.where((prelevement) {
            // Apply status filter
            bool statusMatches =
                _selectedStatusFilter == null ||
                _selectedStatusFilter == 'All' ||
                prelevement['status'] == _selectedStatusFilter;

            return statusMatches;
          }).toList();

      // Apply sorting
      _sortPrelevements();
    });
  }

  void _sortPrelevements() {
    _filteredPrelevements.sort((a, b) {
      if (_sortNewestFirst) {
        return (b['date'] as DateTime).compareTo(a['date'] as DateTime);
      } else {
        return (a['date'] as DateTime).compareTo(b['date'] as DateTime);
      }
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _sortNewestFirst = !_sortNewestFirst;
      _sortPrelevements();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        String? tempStatusFilter = _selectedStatusFilter;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Prélèvements'),
              backgroundColor:
                  isDarkMode
                      ? const Color.fromARGB(255, 30, 34, 28)
                      : Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDarkMode ? Colors.grey[700]! : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<String>(
                          value: tempStatusFilter ?? 'All',
                          isExpanded: true,
                          dropdownColor:
                              isDarkMode
                                  ? const Color.fromARGB(255, 40, 44, 38)
                                  : Colors.white,
                          items:
                              _statusTypes.map((String status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              tempStatusFilter = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatusFilter = tempStatusFilter;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQRScanner() {
    // Set the selected index back to 0 (dashboard) immediately
    setState(() {
      _selectedIndex = 0;
    });

    Navigator.pushNamed(context, '/reception/scan').then((_) {
      // Refresh the list when returning from the scanning page
      _fetchPrelevements();

      // Ensure the selected index is still dashboard
      setState(() {
        _selectedIndex = 0;
      });
    });
  }

  void _viewPrelevementDetails(String id) {
    Navigator.pushNamed(context, '/reception/details/$id').then((_) {
      // Refresh the list when returning from details page
      _fetchPrelevements();
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    // Set the selected index for UI updates
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation for bottom bar items
    switch (index) {
      case 0: // Dashboard - current page
        break;
      case 1: // Scan QR
        _showQRScanner();
        break;
      case 2: // Notifications
        Navigator.pushNamed(context, '/notifications').then((_) {
          setState(() {
            _selectedIndex = 0; // Reset to dashboard tab
          });
        });
        break;
      case 3: // Settings
        Navigator.pushNamed(context, '/settings').then((_) {
          setState(() {
            _selectedIndex = 0; // Reset to dashboard tab
          });
        });
        break;
      case 4: // Profile
        Navigator.pushNamed(context, '/profile').then((_) {
          setState(() {
            _selectedIndex = 0; // Reset to dashboard tab
          });
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // Enhanced colors for better dark mode compatibility
    final cardColor =
        isDarkMode
            ? Color.fromARGB(255, 30, 34, 28)
            : Theme.of(context).cardColor;

    final accentColor =
        isDarkMode
            ? Color.fromARGB(255, 139, 195, 74) // Brighter green in dark mode
            : primaryColor;

    final textColor =
        isDarkMode
            ? Colors.white
            : Theme.of(context).textTheme.bodyMedium?.color;

    final subtleTextColor = isDarkMode ? Colors.grey[300] : Colors.grey[700];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prélèvements'),
            if (_receptionistName != null)
              Text(
                _receptionistName!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: isDarkMode ? Colors.grey[300] : null,
                ),
              ),
          ],
        ),
        backgroundColor: isDarkMode ? Color.fromARGB(255, 30, 40, 28) : null,
        actions: [
          // Filter Button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          // Sort Button
          IconButton(
            icon: Icon(
              _sortNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            onPressed: _toggleSortOrder,
            tooltip: _sortNewestFirst ? 'Newest First' : 'Oldest First',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildListView(
                cardColor,
                accentColor,
                textColor,
                subtleTextColor,
              ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: accentColor,
        unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[700],
        backgroundColor: isDarkMode ? Color.fromARGB(255, 20, 25, 20) : null,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildListView(
    Color cardColor,
    Color accentColor,
    Color? textColor,
    Color? subtleTextColor,
  ) {
    if (_filteredPrelevements.isEmpty) {
      return Center(
        child: animatedWidget(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science_outlined, size: 64, color: subtleTextColor),
              const SizedBox(height: 16),
              Text(
                'No prélèvements found',
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedStatusFilter != null
                    ? 'Try changing your filters'
                    : 'Scan a QR code to get started',
                style: TextStyle(fontSize: 14, color: subtleTextColor),
              ),
              if (_selectedStatusFilter != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedStatusFilter = null;
                        _applyFilters();
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchPrelevements,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredPrelevements.length,
        itemBuilder: (context, index) {
          final prelevement = _filteredPrelevements[index];
          return AnimatedPageItem(
            delay: Duration(milliseconds: 100 * index),
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _viewPrelevementDetails(prelevement['id']),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with ID and Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            prelevement['id'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          _buildStatusChip(prelevement['status']),
                        ],
                      ),
                    ),

                    // Prélèvement Details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date and Material Type
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: subtleTextColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(prelevement['date']),
                                style: TextStyle(color: textColor),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.category,
                                size: 16,
                                color: subtleTextColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                prelevement['material'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Location
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: subtleTextColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  prelevement['location'],
                                  style: TextStyle(color: textColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Description
                          Text(
                            prelevement['description'],
                            style: TextStyle(fontSize: 14, color: textColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Rejection reason if applicable
                          if (prelevement['status'] == 'Rejected' &&
                              prelevement['rejection_reason'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Reason: ${prelevement['rejection_reason']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Footer with Photos Indicator
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (prelevement['has_photos'])
                            Row(
                              children: [
                                Icon(
                                  Icons.photo_library,
                                  size: 16,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Photos',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          const Spacer(),
                          Text(
                            'View Details',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: accentColor,
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
    );
  }

  Widget _buildStatusChip(String status) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color chipColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = isDarkMode ? Colors.amber[300]! : Colors.amber;
        textColor = Colors.black87;
        break;
      case 'validated':
        chipColor = isDarkMode ? Colors.green[300]! : Colors.green;
        break;
      case 'rejected':
        chipColor = isDarkMode ? Colors.red[300]! : Colors.red;
        break;
      default:
        chipColor = isDarkMode ? Colors.grey[400]! : Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
