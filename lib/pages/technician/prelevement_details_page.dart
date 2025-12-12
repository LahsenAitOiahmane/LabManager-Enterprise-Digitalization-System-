import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:labtrack/utils/page_animations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PrelevementDetailsPage extends StatefulWidget {
  final String id;

  const PrelevementDetailsPage({super.key, required this.id});

  @override
  State<PrelevementDetailsPage> createState() => _PrelevementDetailsPageState();
}

class _PrelevementDetailsPageState extends State<PrelevementDetailsPage>
    with TickerProviderStateMixin, PageAnimationsMixin {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  Map<String, dynamic>? _prelevement;

  // Floating action button position animation
  late ScrollController _scrollController;
  bool _isFabLeft = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  // Material type options
  final List<String> _materialTypes = [
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

  // Status options
  final List<String> _statusTypes = [
    'Unreceptioned',
    'Receptioned',
    'Accepted',
    'Refused',
  ];

  String? _selectedMaterial;
  String? _selectedStatus;
  List<XFile> _photoFiles = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Add a map for coordinates
  Map<String, double> _sampleCoords = {'lat': 0.0, 'lng': 0.0};

  @override
  void initState() {
    super.initState();
    initAnimations();
    _fetchPrelevementDetails();

    // Initialize scroll controller for FAB animation
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load coordinates if available
    if (_prelevement != null && _prelevement!['coords'] != null) {
      _sampleCoords = {
        'lat': _prelevement!['coords']['lat'],
        'lng': _prelevement!['coords']['lng'],
      };
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    disposeAnimations();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPrelevementDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get prelevement data from SharedPreferences using the ID
      final prefs = await SharedPreferences.getInstance();
      final prelevementDataString = prefs.getString('prelevement_${widget.id}');

      if (prelevementDataString != null) {
        // Parse the prelevement data
        // Note: In a real app, you'd use proper JSON serialization/deserialization
        // This is a simplified approach for the demo

        // Create a map to hold our prelevement data
        Map<String, dynamic> prelevementData = {};
        prelevementData['id'] = widget.id;

        // Parse location
        if (prelevementDataString.contains('location')) {
          final locationStart =
              prelevementDataString.indexOf('location') + 'location'.length + 2;
          final locationEnd = prelevementDataString.indexOf(',', locationStart);
          final locationStr = prelevementDataString.substring(
            locationStart,
            locationEnd,
          );
          prelevementData['location'] = locationStr.replaceAll("'", "").trim();
        } else {
          prelevementData['location'] = 'No location data';
        }

        // Parse material
        if (prelevementDataString.contains('material')) {
          final materialStart =
              prelevementDataString.indexOf('material') + 'material'.length + 2;
          final materialEnd = prelevementDataString.indexOf(',', materialStart);
          final materialStr = prelevementDataString.substring(
            materialStart,
            materialEnd,
          );
          prelevementData['material'] = materialStr.replaceAll("'", "").trim();
        } else {
          prelevementData['material'] = 'Unknown';
        }

        // Parse description
        if (prelevementDataString.contains('description')) {
          final descStart =
              prelevementDataString.indexOf('description') +
              'description'.length +
              2;
          final descEnd = prelevementDataString.indexOf(',', descStart);
          final descStr = prelevementDataString.substring(descStart, descEnd);
          prelevementData['description'] = descStr.replaceAll("'", "").trim();
        } else {
          prelevementData['description'] = 'No description available';
        }

        // Parse status
        if (prelevementDataString.contains('status')) {
          final statusStart =
              prelevementDataString.indexOf('status') + 'status'.length + 2;
          final statusEnd = prelevementDataString.indexOf(',', statusStart);
          final statusStr = prelevementDataString.substring(
            statusStart,
            statusEnd,
          );
          prelevementData['status'] = statusStr.replaceAll("'", "").trim();
        } else {
          prelevementData['status'] = 'Unreceptioned';
        }

        // Parse date (using current date as fallback)
        prelevementData['date'] = DateTime.now().subtract(
          const Duration(days: 1),
        );

        // Set up photos array (would need proper parsing in a real app)
        prelevementData['photos'] = <String>[];

        // Set default coords if not available
        prelevementData['coords'] = {'lat': 33.5731, 'lng': -7.5898};

        setState(() {
          _prelevement = prelevementData;
          _descriptionController.text =
              prelevementData['description'] as String;
          _locationController.text = prelevementData['location'] as String;
          _selectedMaterial = prelevementData['material'] as String;
          _selectedStatus = prelevementData['status'] as String;
          _photoFiles =
              []; // Photo files would need proper handling in a real app
          _isLoading = false;
        });
      } else {
        // Fallback to mock data if no saved data found
        final mockPrelevement = {
          'id': widget.id,
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'location': 'Casablanca - Quartier Industriel',
          'material': 'Soil',
          'description':
              'Sample collected from construction site. The soil appears to be clay-like with some gravel components. Depth: approximately 1.5 meters from surface.',
          'status': 'Unreceptioned',
          'created_by': '1', // technician ID
          'photos': <String>[],
          'coords': {'lat': 33.5731, 'lng': -7.5898},
        };

        setState(() {
          _prelevement = mockPrelevement;
          _descriptionController.text =
              mockPrelevement['description'] as String;
          _locationController.text = mockPrelevement['location'] as String;
          _selectedMaterial = mockPrelevement['material'] as String;
          _selectedStatus = mockPrelevement['status'] as String;
          _photoFiles = [];
          _isLoading = false;
        });

        // Show message that we're using mock data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No saved data found for this ID. Using mock data.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // In case of error, fall back to mock data
      final mockPrelevement = {
        'id': widget.id,
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'location': 'Error loading data',
        'material': 'Unknown',
        'description': 'There was an error loading the prelevement details.',
        'status': 'Unreceptioned',
        'created_by': '1',
        'photos': <String>[],
        'coords': {'lat': 33.5731, 'lng': -7.5898},
      };

      setState(() {
        _prelevement = mockPrelevement;
        _descriptionController.text = mockPrelevement['description'] as String;
        _locationController.text = mockPrelevement['location'] as String;
        _selectedMaterial = mockPrelevement['material'] as String;
        _selectedStatus = mockPrelevement['status'] as String;
        _photoFiles = [];
        _isLoading = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading prelevement data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    // Start animations after data is loaded
    startAnimations();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (photo != null) {
        setState(() {
          _photoFiles.add(photo);
        });

        // Provide feedback to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo captured successfully'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Show error dialog if permission denied or other error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectPicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        setState(() {
          _photoFiles.add(image);
        });

        // Provide feedback to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo selected successfully'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Show error dialog if permission denied or other error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing gallery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoFiles.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      try {
        // Simulate API call to save changes
        await Future.delayed(const Duration(seconds: 1));

        // Update local data
        setState(() {
          _prelevement!['description'] = _descriptionController.text;
          _prelevement!['location'] = _locationController.text;
          _prelevement!['material'] = _selectedMaterial;
          _prelevement!['status'] = _selectedStatus;
          _prelevement!['photos'] =
              _photoFiles.map((file) => file.path).toList();
          _prelevement!['coords'] = _sampleCoords;

          // In a real app, you would save this to SharedPreferences or an API
          final prefs = SharedPreferences.getInstance();
          prefs.then((prefs) {
            prefs.setString(
              'prelevement_${widget.id}',
              _prelevement.toString(),
            );
          });

          _isSaving = false;
          _isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Changes saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isSaving = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving changes: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Handle scroll events to animate the FAB
  void _onScroll() {
    // Check if user is near the bottom of the scroll
    if (_scrollController.hasClients) {
      if (_scrollController.offset > 200 && !_isFabLeft) {
        setState(() {
          _isFabLeft = true;
        });
      } else if (_scrollController.offset <= 200 && _isFabLeft) {
        setState(() {
          _isFabLeft = false;
        });
      }
    }
  }

  // Add a get location method
  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates using geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.locality ?? '';
        String country = place.country ?? '';
        String locationText =
            '$city, $country (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})';

        setState(() {
          _locationController.text = locationText;
          _sampleCoords = {'lat': position.latitude, 'lng': position.longitude};
          _isLoading = false;
        });
      } else {
        setState(() {
          _locationController.text =
              '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
          _sampleCoords = {'lat': position.latitude, 'lng': position.longitude};
          _isLoading = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // Enhanced colors for better dark mode compatibility
    final cardColor =
        isDarkMode
            ? const Color.fromARGB(255, 30, 34, 28)
            : Theme.of(context).cardColor;

    final accentColor =
        isDarkMode
            ? const Color.fromARGB(
              255,
              139,
              195,
              74,
            ) // Brighter green in dark mode
            : primaryColor;

    final textColor =
        isDarkMode
            ? Colors.white
            : Theme.of(context).textTheme.bodyMedium?.color;

    final subtleTextColor = isDarkMode ? Colors.grey[300] : Colors.grey[700];

    final inputBorderColor = isDarkMode ? Colors.grey[700] : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Prélèvement Details' : 'PRE: ${widget.id}'),
        backgroundColor:
            isDarkMode ? const Color.fromARGB(255, 30, 40, 28) : null,
        actions: [
          if (!_isLoading && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: 'Edit Details',
            ),
          if (!_isLoading && _isEditing) ...[
            // Confirm button
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveChanges,
              tooltip: 'Confirm Changes',
              color: Colors.green,
            ),
            // Cancel button
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleEditMode,
              tooltip: 'Cancel Editing',
            ),
          ],
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(
                isDarkMode: isDarkMode,
                cardColor: cardColor,
                accentColor: accentColor,
                textColor: textColor,
                subtleTextColor: subtleTextColor,
                inputBorderColor: inputBorderColor,
              ),
    );
  }

  Widget _buildBody({
    required bool isDarkMode,
    required Color cardColor,
    required Color accentColor,
    required Color? textColor,
    required Color? subtleTextColor,
    required Color? inputBorderColor,
  }) {
    if (_prelevement == null) {
      return const Center(child: Text('Prélèvement not found'));
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
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
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
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
                    const SizedBox(height: 8),
                    Text(
                      'ID: ${_prelevement!['id']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _isEditing
                        ? Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedStatus,
                            style: TextStyle(color: textColor),
                            dropdownColor:
                                isDarkMode
                                    ? const Color.fromARGB(255, 45, 50, 43)
                                    : Colors.white,
                            decoration: InputDecoration(
                              labelText: 'Status',
                              labelStyle: TextStyle(color: accentColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: inputBorderColor!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: inputBorderColor),
                              ),
                              filled: true,
                              fillColor:
                                  isDarkMode
                                      ? const Color.fromARGB(255, 40, 44, 38)
                                      : Colors.white,
                            ),
                            items:
                                _statusTypes.map((String type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedStatus = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a status';
                              }
                              return null;
                            },
                          ),
                        )
                        : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              _prelevement!['status'],
                              isDarkMode,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _prelevement!['status'],
                            style: TextStyle(
                              color: _getStatusTextColor(
                                _prelevement!['status'],
                                isDarkMode,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date and Location
            AnimatedPageItem(
              delay: const Duration(milliseconds: 150),
              child: Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Date', accentColor),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_prelevement!['date']),
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Location', accentColor),
                      const SizedBox(height: 8),
                      _isEditing
                          ? TextFormField(
                            controller: _locationController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: inputBorderColor!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: inputBorderColor),
                              ),
                              fillColor:
                                  isDarkMode
                                      ? const Color.fromARGB(255, 40, 44, 38)
                                      : Colors.white,
                              filled: true,
                              hintStyle: TextStyle(color: subtleTextColor),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.my_location),
                                onPressed: _getCurrentLocation,
                                color: accentColor,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter location';
                              }
                              return null;
                            },
                          )
                          : Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: subtleTextColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _locationController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Material Type
            AnimatedPageItem(
              delay: const Duration(milliseconds: 200),
              child: Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Material Type', accentColor),
                      const SizedBox(height: 8),
                      _isEditing
                          ? DropdownButtonFormField<String>(
                            initialValue: _selectedMaterial,
                            style: TextStyle(color: textColor),
                            dropdownColor:
                                isDarkMode
                                    ? const Color.fromARGB(255, 45, 50, 43)
                                    : Colors.white,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: inputBorderColor!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: inputBorderColor),
                              ),
                              fillColor:
                                  isDarkMode
                                      ? const Color.fromARGB(255, 40, 44, 38)
                                      : Colors.white,
                              filled: true,
                            ),
                            items:
                                _materialTypes.map((String type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedMaterial = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select material type';
                              }
                              return null;
                            },
                          )
                          : Row(
                            children: [
                              Icon(
                                Icons.category,
                                size: 16,
                                color: subtleTextColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedMaterial ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            AnimatedPageItem(
              delay: const Duration(milliseconds: 250),
              child: Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Description', accentColor),
                      const SizedBox(height: 8),
                      _isEditing
                          ? TextFormField(
                            controller: _descriptionController,
                            style: TextStyle(color: textColor),
                            maxLines: 5,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: inputBorderColor!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: inputBorderColor),
                              ),
                              fillColor:
                                  isDarkMode
                                      ? const Color.fromARGB(255, 40, 44, 38)
                                      : Colors.white,
                              filled: true,
                              hintStyle: TextStyle(color: subtleTextColor),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter description';
                              }
                              return null;
                            },
                          )
                          : Text(
                            _descriptionController.text,
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Photos
            AnimatedPageItem(
              delay: const Duration(milliseconds: 300),
              child: Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('Photos', accentColor),
                          if (_isEditing)
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: OutlinedButton.icon(
                                      onPressed: _takePicture,
                                      icon: Icon(
                                        Icons.camera_alt,
                                        color: accentColor,
                                        size: 16,
                                      ),
                                      label: Text(
                                        'Take',
                                        style: TextStyle(color: accentColor),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        side: BorderSide(color: accentColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: OutlinedButton.icon(
                                      onPressed: _selectPicture,
                                      icon: Icon(
                                        Icons.photo_library,
                                        color: accentColor,
                                        size: 16,
                                      ),
                                      label: Text(
                                        'Add',
                                        style: TextStyle(color: accentColor),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        side: BorderSide(color: accentColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!_isEditing && _photoFiles.isEmpty)
                        // Display message and photo buttons when in view mode with no photos
                        Column(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      size: 48,
                                      color: subtleTextColor,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No photos available',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: subtleTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (_isEditing && _photoFiles.isEmpty)
                        // Display message when in edit mode with no photos
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 48,
                                  color: subtleTextColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add photos using the buttons above',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: subtleTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        // Photo Gallery
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _photoFiles.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Show enlarged photo on tap
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => Dialog(
                                              insetPadding:
                                                  const EdgeInsets.all(16),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  AppBar(
                                                    title: Text(
                                                      'Photo ${index + 1}',
                                                    ),
                                                    leading: IconButton(
                                                      icon: const Icon(
                                                        Icons.close,
                                                      ),
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                    ),
                                                    actions: [
                                                      if (_isEditing)
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.delete,
                                                          ),
                                                          onPressed: () {
                                                            _removePhoto(index);
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                        ),
                                                    ],
                                                  ),
                                                  Flexible(
                                                    child: InteractiveViewer(
                                                      minScale: 0.5,
                                                      maxScale: 4.0,
                                                      child: Image.file(
                                                        File(
                                                          _photoFiles[index]
                                                              .path,
                                                        ),
                                                        fit: BoxFit.contain,
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Center(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  size: 64,
                                                                  color:
                                                                      isDarkMode
                                                                          ? Colors
                                                                              .grey[600]
                                                                          : Colors
                                                                              .grey[400],
                                                                ),
                                                                const SizedBox(
                                                                  height: 16,
                                                                ),
                                                                const Text(
                                                                  'Unable to load image',
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: accentColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.file(
                                        File(_photoFiles[index].path),
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color:
                                                isDarkMode
                                                    ? Colors.grey[800]
                                                    : Colors.grey[200],
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 40,
                                              color:
                                                  isDarkMode
                                                      ? Colors.grey[600]
                                                      : Colors.grey[400],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  if (_isEditing)
                                    Positioned(
                                      top: 4,
                                      right: 12,
                                      child: InkWell(
                                        onTap: () => _removePhoto(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color:
                                                isDarkMode
                                                    ? Colors.grey[900]
                                                    : Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
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

  Widget _buildSectionTitle(String title, Color accentColor) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: accentColor,
      ),
    );
  }

  Color _getStatusColor(String status, bool isDarkMode) {
    switch (status.toLowerCase()) {
      case 'receptioned':
        return isDarkMode ? Colors.blue[300]! : Colors.blue;
      case 'unreceptioned':
        return isDarkMode ? Colors.amber[300]! : Colors.amber;
      case 'accepted':
        return isDarkMode ? Colors.green[300]! : Colors.green;
      case 'refused':
        return isDarkMode ? Colors.red[300]! : Colors.red;
      // Support legacy status labels during transition
      case 'submitted':
        return isDarkMode ? Colors.blue[300]! : Colors.blue;
      case 'draft':
        return isDarkMode ? Colors.amber[300]! : Colors.amber;
      case 'processed':
        return isDarkMode ? Colors.orange[300]! : Colors.orange;
      case 'completed':
        return isDarkMode ? Colors.green[300]! : Colors.green;
      default:
        return isDarkMode ? Colors.grey[400]! : Colors.grey;
    }
  }

  Color _getStatusTextColor(String status, bool isDarkMode) {
    switch (status.toLowerCase()) {
      case 'unreceptioned':
      case 'draft':
        return Colors.black87;
      default:
        return Colors.white;
    }
  }
}
