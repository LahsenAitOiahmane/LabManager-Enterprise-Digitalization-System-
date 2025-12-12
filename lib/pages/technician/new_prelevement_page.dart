import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:labtrack/utils/page_animations.dart';
import 'dart:math' as math;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class NewPrelevementPage extends StatefulWidget {
  const NewPrelevementPage({super.key});

  @override
  State<NewPrelevementPage> createState() => _NewPrelevementPageState();
}

class _NewPrelevementPageState extends State<NewPrelevementPage>
    with TickerProviderStateMixin, PageAnimationsMixin {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _materialController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isGeneratingQR = false;
  String? _generatedId;
  String? _technicianId;

  // Store file paths instead of just photo URLs
  final List<XFile> _photoFiles = [];
  final ImagePicker _imagePicker = ImagePicker();

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

  // Floating action button position animation
  late ScrollController _scrollController;
  bool _isFabLeft = false;

  Map<String, double> _sampleCoords = {'lat': 0.0, 'lng': 0.0};

  @override
  void initState() {
    super.initState();
    initAnimations();
    _loadTechnicianData();
    _loadDraftFormData();
    startAnimations();

    // Initialize scroll controller for FAB animation
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _saveDraftFormData();

    _materialController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    disposeAnimations();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTechnicianData() async {
    final prefs = await SharedPreferences.getInstance();
    _technicianId = prefs.getString('userId') ?? 'tech_default';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Apply app's theme to the date picker
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface:
                  isDarkMode
                      ? const Color.fromARGB(255, 30, 34, 28)
                      : Colors.white,
              onSurface: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

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

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, please enable in settings',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
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
          // Save coords in the sample data
          _sampleCoords = {'lat': position.latitude, 'lng': position.longitude};
          _isLoading = false;
        });
      } else {
        setState(() {
          _locationController.text =
              '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
          // Save coords in the sample data
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

  Future<void> _takePicture() async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _photoFiles.add(photo);
      });
    }
  }

  Future<void> _selectPicture() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _photoFiles.add(image);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoFiles.removeAt(index);
    });
  }

  String _generateUniqueId() {
    final now = DateTime.now();
    final random = math.Random();
    final randomNum = random.nextInt(10000).toString().padLeft(4, '0');

    return 'PRE-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$randomNum';
  }

  Future<void> _generateQRCode() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isGeneratingQR = true;
      });

      // Simulate API call to generate ID
      await Future.delayed(const Duration(seconds: 1));

      final generatedId = _generateUniqueId();

      setState(() {
        _generatedId = generatedId;
        _isGeneratingQR = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _savePrelevement() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_generatedId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please generate a QR code first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Create prelevement data object
        final prelevement = {
          'id': _generatedId,
          'date': _selectedDate,
          'location': _locationController.text,
          'material': _materialController.text,
          'description': _descriptionController.text,
          'status': 'Unreceptioned',
          'created_by': _technicianId,
          'has_photos': _photoFiles.isNotEmpty,
          'photos': _photoFiles.map((file) => file.path).toList(),
          'created_at': DateTime.now().toIso8601String(),
          'coords': _sampleCoords,
        };

        // In a real app, you would send this to an API
        // For now, we're simulating by storing in SharedPreferences

        final prefs = await SharedPreferences.getInstance();

        // Get existing prélèvements or initialize empty list
        List<String> savedPrelevements =
            prefs.getStringList('prelevements') ?? [];

        // Add new prélèvement ID to the list
        savedPrelevements.add(_generatedId!);

        // Save updated list
        await prefs.setStringList('prelevements', savedPrelevements);

        // Save prélèvement details
        await prefs.setString(
          'prelevement_$_generatedId',
          prelevement.toString(),
        );

        // Clear draft data since we've successfully saved
        await _clearDraftFormData();

        // Simulate API call delay
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Prélèvement $_generatedId saved successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back after saving
          Navigator.pop(context, prelevement);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving prélèvement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadDraftFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we have draft data
      if (prefs.containsKey('draft_material')) {
        setState(() {
          _materialController.text = prefs.getString('draft_material') ?? '';
          _locationController.text = prefs.getString('draft_location') ?? '';
          _descriptionController.text =
              prefs.getString('draft_description') ?? '';

          // Load selected date if available
          final savedDateMillis = prefs.getInt('draft_date');
          if (savedDateMillis != null) {
            _selectedDate = DateTime.fromMillisecondsSinceEpoch(
              savedDateMillis,
            );
          }
        });
      }
    } catch (e) {
      print('Error loading draft data: $e');
    }
  }

  Future<void> _saveDraftFormData() async {
    try {
      // Only save if there's actual data to save
      if (_materialController.text.isNotEmpty ||
          _locationController.text.isNotEmpty ||
          _descriptionController.text.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();

        // Save form fields
        await prefs.setString('draft_material', _materialController.text);
        await prefs.setString('draft_location', _locationController.text);
        await prefs.setString('draft_description', _descriptionController.text);

        // Save selected date
        await prefs.setInt('draft_date', _selectedDate.millisecondsSinceEpoch);
      }
    } catch (e) {
      print('Error saving draft data: $e');
    }
  }

  Future<void> _clearDraftFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('draft_material');
      await prefs.remove('draft_location');
      await prefs.remove('draft_description');
      await prefs.remove('draft_date');
    } catch (e) {
      print('Error clearing draft data: $e');
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // Enhanced colors for better dark mode compatibility
    // ignore: unused_local_variable
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
        title: const Text('New Prélèvement'),
        backgroundColor:
            isDarkMode ? const Color.fromARGB(255, 30, 40, 28) : null,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Picker
                      AnimatedPageItem(
                        delay: const Duration(milliseconds: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Date', accentColor),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: inputBorderColor!),
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      isDarkMode
                                          ? const Color.fromARGB(
                                            255,
                                            40,
                                            44,
                                            38,
                                          )
                                          : Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: subtleTextColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_selectedDate),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Location
                      AnimatedPageItem(
                        delay: const Duration(milliseconds: 150),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Location', accentColor),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _locationController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText:
                                    'Enter location or get current location',
                                hintStyle: TextStyle(color: subtleTextColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                  ),
                                ),
                                filled: isDarkMode,
                                fillColor:
                                    isDarkMode
                                        ? const Color.fromARGB(255, 40, 44, 38)
                                        : null,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.my_location),
                                  onPressed: _getCurrentLocation,
                                  tooltip: 'Get Current Location',
                                  color: accentColor,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a location';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Material Type
                      AnimatedPageItem(
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Material Type', accentColor),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue:
                                  _materialController.text.isEmpty
                                      ? null
                                      : _materialController.text,
                              dropdownColor:
                                  isDarkMode
                                      ? const Color.fromARGB(255, 45, 50, 43)
                                      : Colors.white,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Select material type',
                                hintStyle: TextStyle(color: subtleTextColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                  ),
                                ),
                                filled: isDarkMode,
                                fillColor:
                                    isDarkMode
                                        ? const Color.fromARGB(255, 40, 44, 38)
                                        : null,
                              ),
                              items:
                                  _materialTypes.map((String type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _materialController.text = newValue;
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a material type';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Photos
                      AnimatedPageItem(
                        delay: const Duration(milliseconds: 250),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Photos', accentColor),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: inputBorderColor),
                                borderRadius: BorderRadius.circular(8),
                                color:
                                    isDarkMode
                                        ? const Color.fromARGB(255, 40, 44, 38)
                                        : Colors.white,
                              ),
                              child: Column(
                                children: [
                                  if (_photoFiles.isEmpty)
                                    Center(
                                      child: Text(
                                        'No photos added yet',
                                        style: TextStyle(
                                          color: subtleTextColor,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  if (_photoFiles.isNotEmpty)
                                    SizedBox(
                                      height: 100,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _photoFiles.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                                              ? Colors.grey[700]
                                                              : Colors
                                                                  .grey[200],
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 32,
                                                        color:
                                                            isDarkMode
                                                                ? Colors
                                                                    .grey[400]
                                                                : Colors.grey,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Positioned(
                                                top: 4,
                                                right: 12,
                                                child: InkWell(
                                                  onTap:
                                                      () => _removePhoto(index),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          isDarkMode
                                                              ? Colors.grey[800]
                                                              : Colors.white,
                                                      shape: BoxShape.circle,
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
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _takePicture,
                                          icon: Icon(
                                            Icons.camera_alt,
                                            color: accentColor,
                                          ),
                                          label: Text(
                                            'Take Picture',
                                            style: TextStyle(
                                              color: accentColor,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            side: BorderSide(
                                              color: accentColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _selectPicture,
                                          icon: Icon(
                                            Icons.photo_library,
                                            color: accentColor,
                                          ),
                                          label: Text(
                                            'Select Picture',
                                            style: TextStyle(
                                              color: accentColor,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            side: BorderSide(
                                              color: accentColor,
                                            ),
                                          ),
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
                      const SizedBox(height: 24),

                      // Description
                      AnimatedPageItem(
                        delay: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Description', accentColor),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descriptionController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Enter sample description',
                                hintStyle: TextStyle(color: subtleTextColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                  ),
                                ),
                                filled: isDarkMode,
                                fillColor:
                                    isDarkMode
                                        ? const Color.fromARGB(255, 40, 44, 38)
                                        : null,
                              ),
                              maxLines: 4,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // QR Code Generation
                      AnimatedPageItem(
                        delay: const Duration(milliseconds: 350),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_generatedId != null)
                              Column(
                                children: [
                                  Text(
                                    'Prélèvement ID: $_generatedId',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This QR code contains a unique identifier for your prélèvement. It can be scanned by reception staff to validate and process your sample.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: subtleTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
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
                                    child: Column(
                                      children: [
                                        QrImageView(
                                          data: _generatedId!,
                                          version: QrVersions.auto,
                                          size: 200,
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Valid QR Code',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _generateQRCode,
                                    icon: const Icon(Icons.qr_code),
                                    label: Text(
                                      _isGeneratingQR
                                          ? 'Generating...'
                                          : _generatedId != null
                                          ? 'Regenerate QR Code'
                                          : 'Generate QR Code',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      backgroundColor: accentColor,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      AnimatedPageItem(
                        delay: const Duration(milliseconds: 400),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _savePrelevement,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Prélèvement'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
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
}
