import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:labtrack/utils/page_animations.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _TechnicianHomePageState extends State<TechnicianHomePage>
    with TickerProviderStateMixin, PageAnimationsMixin {
  List<Map<String, dynamic>> _prelevement = [];
  List<Map<String, dynamic>> _filteredPrelevement = [];
  bool _isLoading = true;
  bool _isMapView = false;
  String? _technicianId;
  String? _technicianName;
  int _selectedIndex = 0;

  // Floating action button position animation
  late ScrollController _scrollController;
  bool _isFabExtended = true;
  bool _isFabLeft = false;

  // Filtering options
  String? _selectedMaterialFilter;
  String? _selectedStatusFilter;

  // Sorting options
  bool _sortNewestFirst = true;

  // List of material types and statuses for filtering
  final List<String> _materialTypes = [
    'All',
    'Soil',
    'Concrete',
    'Asphalt',
    'Steel',
    'Aggregate',
    'Water',
    'Wood',
    'Brick',
    'Other',
  ];

  final List<String> _statusTypes = [
    'All',
    'Unreceptioned',
    'Receptioned',
    'Accepted',
    'Refused',
  ];

  // Map controller for stopping requests when leaving map view
  MapController? _mapController;

  @override
  void initState() {
    super.initState();
    initAnimations();
    _loadTechnicianData();

    // Initialize scroll controller for FAB animation
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Initialize map controller
    _mapController = MapController();
  }

  @override
  void dispose() {
    disposeAnimations();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // Dispose map controller
    _mapController = null;
    super.dispose();
  }

  Future<void> _loadTechnicianData() async {
    final prefs = await SharedPreferences.getInstance();
    _technicianId = prefs.getString('userId') ?? '1';
    _technicianName = prefs.getString('userName') ?? 'Mohammed Alami';

    // Get user information from SharedPreferences
    final email = prefs.getString('userEmail');
    final role = prefs.getString('userRole');

    if (email != null) {
      // Extract name from email (in a real app, this would come from a user profile)
      final namePart = email.split('@')[0].replaceAll('.', ' ');
      _technicianName = namePart
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

    // Simulate API call to fetch technician's prélèvements
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
            prelevement['created_by'] = _technicianId;
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
        _prelevement = loadedPrelevements;
        _applyFilters(); // Apply any active filters
        _isLoading = false;
      });

      // Start animations after data is loaded
      startAnimations();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _prelevement = _generateMockPrelevements(); // Fallback to mock data
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
        'status': 'Receptioned',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'created_by': _technicianId,
        'has_photos': true,
        'coords': {'lat': 33.5731, 'lng': -7.5898},
      },
      {
        'id': 'PRE-002-2023',
        'material': 'Concrete',
        'location': 'Rabat - Central Building',
        'description': 'Concrete core sample from column',
        'status': 'Accepted',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'created_by': _technicianId,
        'has_photos': true,
        'coords': {'lat': 34.0209, 'lng': -6.8416},
      },
      {
        'id': 'PRE-003-2023',
        'material': 'Asphalt',
        'location': 'Marrakech - Highway Project',
        'description': 'Surface layer sample',
        'status': 'Refused',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'created_by': _technicianId,
        'has_photos': false,
        'coords': {'lat': 31.6295, 'lng': -7.9811},
        'rejection_reason': 'Insufficient sample size',
      },
      {
        'id': 'PRE-004-2023',
        'material': 'Steel',
        'location': 'Tangier - Bridge Construction',
        'description': 'Reinforcement bar sample',
        'status': 'Unreceptioned',
        'date': DateTime.now(),
        'created_by': _technicianId,
        'has_photos': true,
        'coords': {'lat': 35.7595, 'lng': -5.8340},
      },
    ];
  }

  void _applyFilters() {
    setState(() {
      _filteredPrelevement =
          _prelevement.where((prelevement) {
            // Apply material filter
            bool materialMatches =
                _selectedMaterialFilter == null ||
                _selectedMaterialFilter == 'All' ||
                prelevement['material'] == _selectedMaterialFilter;

            // Apply status filter
            bool statusMatches =
                _selectedStatusFilter == null ||
                _selectedStatusFilter == 'All' ||
                prelevement['status'] == _selectedStatusFilter;

            return materialMatches && statusMatches;
          }).toList();

      // Apply sorting
      _sortPrelevements();
    });
  }

  void _sortPrelevements() {
    _filteredPrelevement.sort((a, b) {
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
        String? tempMaterialFilter = _selectedMaterialFilter;
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
                  const Text('Material Type'),
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
                          value: tempMaterialFilter ?? 'All',
                          isExpanded: true,
                          dropdownColor:
                              isDarkMode
                                  ? const Color.fromARGB(255, 40, 44, 38)
                                  : Colors.white,
                          items:
                              _materialTypes.map((String material) {
                                return DropdownMenuItem<String>(
                                  value: material,
                                  child: Text(
                                    material,
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
                              tempMaterialFilter = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      _selectedMaterialFilter = tempMaterialFilter;
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

  void _toggleView() {
    setState(() {
      // If we're switching from map view to list view
      if (_isMapView) {
        // Stop any ongoing map requests
        if (_mapController != null) {
          // The next line doesn't actually stop ongoing tile requests
          // but helps prevent any new ones until we fully exit the map
          _mapController = MapController();
        }
      }
      _isMapView = !_isMapView;
    });
  }

  void _navigateToNewPrelevement() {
    Navigator.pushNamed(context, '/technician/new').then((result) {
      // Always refresh the list when returning from creating a new prélèvement
      _fetchPrelevements();
    });
  }

  void _viewPrelevementDetails(String id) {
    Navigator.pushNamed(context, '/technician/details/$id').then((_) {
      // Refresh the list when returning from details page
      _fetchPrelevements();
    });
  }

  void _onItemTapped(int index) {
    // Special case for the center "New" button (index 2)
    if (index == 2) {
      _navigateToNewPrelevement();
      return;
    }

    // Adjust index for the nav bar items since we inserted the "New" button at index 2
    int adjustedIndex = index;
    if (index > 2) {
      adjustedIndex = index - 1;
    }

    if (adjustedIndex == _selectedIndex) return;

    // Set the selected index for UI updates
    setState(() {
      _selectedIndex = adjustedIndex;
    });

    // Handle navigation for bottom bar items
    switch (adjustedIndex) {
      case 0: // Dashboard - current page
        break;
      case 1: // Notifications
        // We need to reset _selectedIndex when we return to this page
        Navigator.pushNamed(context, '/notifications').then((_) {
          setState(() {
            _selectedIndex = 0; // Reset to dashboard tab
          });
        });
        break;
      case 2: // Settings
        Navigator.pushNamed(context, '/settings').then((_) {
          setState(() {
            _selectedIndex = 0; // Reset to dashboard tab
          });
        });
        break;
      case 3: // Profile
        Navigator.pushNamed(context, '/profile').then((_) {
          setState(() {
            _selectedIndex = 0; // Reset to dashboard tab
          });
        });
        break;
    }
  }

  // Handle scroll events to animate the FAB
  void _onScroll() {
    // Check if user is near the bottom of the scroll
    if (_scrollController.hasClients) {
      if (_scrollController.offset > 200 && _isFabExtended) {
        setState(() {
          _isFabExtended = false;
          _isFabLeft = true;
        });
      } else if (_scrollController.offset <= 200 && !_isFabExtended) {
        setState(() {
          _isFabExtended = true;
          _isFabLeft = false;
        });
      }
    }
  }

  void _showPrelevementDetails(Map<String, dynamic> prelevement) {
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final date = prelevement['date'] as DateTime;
        final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

        return AlertDialog(
          title: Text('Prélèvement Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ID: ${prelevement['id']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Material: ${prelevement['material']}'),
                const SizedBox(height: 4),
                Text('Location: ${prelevement['location']}'),
                const SizedBox(height: 4),
                Text('Description: ${prelevement['description']}'),
                const SizedBox(height: 4),
                Text('Date: $formattedDate'),
                const SizedBox(height: 4),
                Text('Status: ${prelevement['status']}'),
                if (prelevement['status'] == 'Refused')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Rejection Reason: ${prelevement['rejection_reason'] ?? 'Not specified'}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.red[300] : Colors.red[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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
            if (_technicianName != null)
              Text(
                _technicianName!,
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
          // Map/List View Toggle
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: _toggleView,
            tooltip: _isMapView ? 'List View' : 'Map View',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isMapView
              ? _buildMapView()
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
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          // Center item for new prelevement
          BottomNavigationBarItem(
            icon: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor,
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
            label: 'New',
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
    if (_filteredPrelevement.isEmpty) {
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
                _selectedMaterialFilter != null || _selectedStatusFilter != null
                    ? 'Try changing your filters'
                    : 'Create a new prélèvement to get started',
                style: TextStyle(fontSize: 14, color: subtleTextColor),
              ),
              if (_selectedMaterialFilter != null ||
                  _selectedStatusFilter != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedMaterialFilter = null;
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
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _filteredPrelevement.length,
        itemBuilder: (context, index) {
          final prelevement = _filteredPrelevement[index];
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

  Widget _buildMapView() {
    if (_filteredPrelevement.isEmpty) {
      return Center(child: Text('No samples to display on map'));
    }

    // Calculate the center of the map based on markers
    final latitudes =
        _filteredPrelevement
            .map((p) => p['coords']?['lat'] ?? 33.5731)
            .toList();
    final longitudes =
        _filteredPrelevement
            .map((p) => p['coords']?['lng'] ?? -7.5898)
            .toList();

    final avgLat = latitudes.reduce((a, b) => a + b) / latitudes.length;
    final avgLng = longitudes.reduce((a, b) => a + b) / longitudes.length;

    // Convert to LatLng from latlong2 package
    final center = LatLng(avgLat, avgLng);

    // Create markers for each prelevement using flutter_map
    final markers =
        _filteredPrelevement.map((prelevement) {
          // Extract coordinates - with fallback if not available
          final lat = prelevement['coords']?['lat'] ?? 33.5731;
          final lng = prelevement['coords']?['lng'] ?? -7.5898;

          return Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(lat, lng),
            builder:
                (context) => GestureDetector(
                  onTap: () => _viewPrelevementDetails(prelevement['id']),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.all(4),
                        child: Text(
                          prelevement['id'],
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(Icons.location_on, color: Colors.red, size: 30),
                    ],
                  ),
                ),
          );
        }).toList();

    // Create a new MapController if needed
    _mapController ??= MapController();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: center,
        zoom: 10.0,
        interactiveFlags: InteractiveFlag.all,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.labtrack',
          maxZoom: 19,
          tileProvider: NetworkTileProvider(),
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color chipColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'receptioned':
        chipColor = isDarkMode ? Colors.blue[300]! : Colors.blue;
        break;
      case 'unreceptioned':
        chipColor = isDarkMode ? Colors.amber[300]! : Colors.amber;
        textColor = Colors.black87;
        break;
      case 'accepted':
        chipColor = isDarkMode ? Colors.green[300]! : Colors.green;
        break;
      case 'refused':
        chipColor = isDarkMode ? Colors.red[300]! : Colors.red;
        break;
      // Keep fallbacks for old status types during transition
      case 'submitted':
        chipColor = isDarkMode ? Colors.blue[300]! : Colors.blue;
        break;
      case 'draft':
        chipColor = isDarkMode ? Colors.amber[300]! : Colors.amber;
        textColor = Colors.black87;
        break;
      case 'processed':
        chipColor = isDarkMode ? Colors.orange[300]! : Colors.orange;
        break;
      case 'completed':
        chipColor = isDarkMode ? Colors.green[300]! : Colors.green;
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
