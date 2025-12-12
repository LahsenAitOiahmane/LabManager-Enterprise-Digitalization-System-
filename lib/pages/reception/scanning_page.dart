import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:lottie/lottie.dart';

class ScanningPage extends StatefulWidget {
  const ScanningPage({super.key});

  @override
  State<ScanningPage> createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage> with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isProcessing = false;
  String? _lastScannedCode;
  DateTime _lastScanTime = DateTime.now();
  bool _isScannerActive = true;
  bool _showHistory = false;
  List<Map<String, dynamic>> _scanHistory = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeScanner();
    _loadScanHistory();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _animationController.forward();
  }

  Future<void> _initializeScanner() async {
    try {
      debugPrint('Initializing scanner...');
      await _scannerController.start();
      debugPrint('Scanner initialized successfully');
    } catch (e) {
      debugPrint('Error initializing scanner: $e');
      _showError('Failed to initialize scanner: $e');
    }
  }

  Future<void> _loadScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('scan_history');
      if (historyJson != null) {
        setState(() {
          _scanHistory = List<Map<String, dynamic>>.from(json.decode(historyJson));
        });
      }
    } catch (e) {
      debugPrint('Error loading scan history: $e');
    }
  }

  Future<void> _saveScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('scan_history', json.encode(_scanHistory));
    } catch (e) {
      debugPrint('Error saving scan history: $e');
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScannerActive) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      debugPrint('No barcodes detected');
      return;
    }

    if (_isProcessing) {
      debugPrint('Already processing a barcode');
      return;
    }

    final String? code = barcodes.first.rawValue;
    if (code == null) {
      debugPrint('Barcode has no raw value');
      return;
    }

    debugPrint('Detected barcode: $code');
    _isProcessing = true;

    // Check for duplicate scans within 2 seconds
    if (_lastScannedCode == code && 
        DateTime.now().difference(_lastScanTime) < const Duration(seconds: 2)) {
      debugPrint('Duplicate scan detected');
      _isProcessing = false;
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = DateTime.now();

    _processScannedCode(code);
  }
  
  Future<void> _processScannedCode(String code) async {
    try {
      debugPrint('Processing scanned code: $code');
      
      // Add to scan history
      setState(() {
        _scanHistory.insert(0, {
          'code': code,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'Processing'
        });
      });
      _saveScanHistory();
      
      // Automatically pause the scanner after a scan
      setState(() {
        _isScannerActive = false;
        _scannerController.stop();
      });
      
      // Simulate API call to verify the code
      await Future.delayed(const Duration(seconds: 1));
      
      // Check if the code has the correct format for a prelevement ID
      bool isValidPrelevement = code.startsWith('PRE-');
      
      if (!isValidPrelevement) {
        debugPrint('Invalid code format: $code');
        _updateScanHistory(code, 'Error', 'Invalid code format - not a prelevement');
        _showError('Invalid code format - not a prelevement');
        
        // Don't navigate if it's not a valid prelevement format
        _isProcessing = false;
        return;
      }
      
      // Show success message and animation
      _updateScanHistory(code, 'Success', 'Prelevement QR code scanned successfully');
      _showSuccess('Prelevement QR code scanned successfully');
      
      // Show success animation before navigating
      _showSuccessAnimation();
      
      // Navigate to verify page after a short delay
      if (mounted) {
        await Future.delayed(const Duration(seconds: 1));
        // Navigate to the verify page with the scanned code
        Navigator.pushReplacementNamed(
          context,
          '/reception/verify/$code',
        );
      }
    } catch (e) {
      debugPrint('Error processing scanned code: $e');
      _updateScanHistory(code, 'Error', 'Error processing QR code');
      _showError('Error processing QR code');
      
      // Don't navigate if there was an error
      _isProcessing = false;
    } finally {
      if (_isProcessing) {
        _isProcessing = false;
      }
    }
  }

  void _updateScanHistory(String code, String status, String message) {
    setState(() {
      final index = _scanHistory.indexWhere((item) => item['code'] == code);
      if (index != -1) {
        _scanHistory[index]['status'] = status;
        _scanHistory[index]['message'] = message;
      }
    });
    _saveScanHistory();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/success.json',
              width: 200,
              height: 200,
              repeat: false,
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan Successful!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleScanner() {
    setState(() {
      _isScannerActive = !_isScannerActive;
      if (_isScannerActive) {
        _scannerController.start();
      } else {
        _scannerController.stop();
      }
    });
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Scan History'),
        content: const Text('Are you sure you want to clear all scan history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _scanHistory.clear();
              });
              _saveScanHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    // Define a subtle green color for light mode
    final lightModeColor = const Color(0xFFECF5E7); // Cloudy white with subtle green tint
    final accentColor = isDarkMode ? primaryColor : const Color(0xFF4A8642); // Darker green for accents in light mode
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode 
                    ? [Colors.black, Color(0xFF1A1A1A)]
                    : [lightModeColor, Colors.white.withOpacity(0.9)], // Cloudy white with subtle green gradient
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom app bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Scan QR Code',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isFlashOn ? Icons.flash_on : Icons.flash_off,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            onPressed: () {
                              setState(() {
                                _isFlashOn = !_isFlashOn;
                                _scannerController.toggleTorch();
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            onPressed: () {
                              setState(() {
                                _isFrontCamera = !_isFrontCamera;
                                _scannerController.switchCamera();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Scanner view or history
                Expanded(
                  child: _showHistory
                      ? _buildHistoryView(isDarkMode, accentColor)
                      : _buildScannerView(screenSize, accentColor, isDarkMode),
                ),
                
                // Bottom controls
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: _isScannerActive ? Icons.pause : Icons.play_arrow,
                        label: _isScannerActive ? 'Pause' : 'Resume',
                        onPressed: _toggleScanner,
                        isDarkMode: isDarkMode,
                        accentColor: accentColor,
                      ),
                      _buildControlButton(
                        icon: _showHistory ? Icons.qr_code_scanner : Icons.history,
                        label: _showHistory ? 'Scanner' : 'History',
                        onPressed: () {
                          setState(() {
                            _showHistory = !_showHistory;
                          });
                        },
                        isDarkMode: isDarkMode,
                        accentColor: accentColor,
                      ),
                      _buildControlButton(
                        icon: Icons.delete,
                        label: 'Clear',
                        onPressed: _clearHistory,
                        showOnlyWhenHistory: true,
                        isDarkMode: isDarkMode,
                        accentColor: accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Processing QR Code...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please wait while we verify the code',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerView(Size screenSize, Color accentColor, bool isDarkMode) {
    return Stack(
      children: [
        // Scanner View
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
        ),
        
        // Scanner overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.4), // Slightly more transparent in light mode
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Scanner frame
              Center(
                child: Container(
                  width: screenSize.width * 0.7,
                  height: screenSize.width * 0.7,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: accentColor,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              
              // Corner markers
              ..._buildCornerMarkers(screenSize, accentColor),
              
              // Scanning line animation
              Center(
                child: Container(
                  width: screenSize.width * 0.7,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        accentColor,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Instructions
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: accentColor,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Position the QR code within the frame',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The scanner will automatically detect and process the code',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCornerMarkers(Size screenSize, Color accentColor) {
    final size = screenSize.width * 0.7;
    final markerSize = 20.0;
    
    return [
      // Top left
      Positioned(
        top: (screenSize.height - size) / 2,
        left: (screenSize.width - size) / 2,
        child: _buildCornerMarker(accentColor, markerSize, true, true),
      ),
      
      // Top right
      Positioned(
        top: (screenSize.height - size) / 2,
        right: (screenSize.width - size) / 2,
        child: _buildCornerMarker(accentColor, markerSize, false, true),
      ),
      
      // Bottom left
      Positioned(
        bottom: (screenSize.height - size) / 2,
        left: (screenSize.width - size) / 2,
        child: _buildCornerMarker(accentColor, markerSize, true, false),
      ),
      
      // Bottom right
      Positioned(
        bottom: (screenSize.height - size) / 2,
        right: (screenSize.width - size) / 2,
        child: _buildCornerMarker(accentColor, markerSize, false, false),
      ),
    ];
  }

  Widget _buildCornerMarker(Color color, double size, bool isLeft, bool isTop) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: color,
            width: isLeft ? 3 : 0,
          ),
          top: BorderSide(
            color: color,
            width: isTop ? 3 : 0,
          ),
          right: BorderSide(
            color: color,
            width: !isLeft ? 3 : 0,
          ),
          bottom: BorderSide(
            color: color,
            width: !isTop ? 3 : 0,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryView(bool isDarkMode, Color accentColor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: _scanHistory.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black26,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No scan history',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _scanHistory.length,
                itemBuilder: (context, index) {
                  final item = _scanHistory[index];
                  final timestamp = DateTime.parse(item['timestamp']);
                  final formattedTime = '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
                  final formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
                    elevation: isDarkMode ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDarkMode ? Colors.transparent : accentColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(item['status']),
                        child: Icon(
                          _getStatusIcon(item['status']),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        item['code'],
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '$formattedDate at $formattedTime',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _scanHistory.removeAt(index);
                          });
                          _saveScanHistory();
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Success':
        return Colors.green;
      case 'Error':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Success':
        return Icons.check;
      case 'Error':
        return Icons.error;
      default:
        return Icons.hourglass_empty;
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool showOnlyWhenHistory = false,
    required bool isDarkMode,
    required Color accentColor,
  }) {
    if (showOnlyWhenHistory && !_showHistory) {
      return const SizedBox.shrink();
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withOpacity(0.2) : accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDarkMode ? Colors.transparent : accentColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(icon, color: isDarkMode ? Colors.white : accentColor),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 