import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:labtrack/utils/page_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReceptionScanPage extends StatefulWidget {
  const ReceptionScanPage({super.key});

  @override
  State<ReceptionScanPage> createState() => _ReceptionScanPageState();
}

class _ReceptionScanPageState extends State<ReceptionScanPage>
    with TickerProviderStateMixin, PageAnimationsMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isProcessing = false;
  String? _lastScannedCode;
  DateTime _lastScanTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    initAnimations();
    startAnimations();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    try {
      print('Initializing scanner...');
      await _scannerController.start();
      print('Scanner initialized successfully');
    } catch (e) {
      print('Error initializing scanner: $e');
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    disposeAnimations();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      print('No barcodes detected');
      return;
    }

    if (_isProcessing) {
      print('Already processing a barcode');
      return;
    }

    final String? code = barcodes.first.rawValue;
    if (code == null) {
      print('Barcode has no raw value');
      return;
    }

    print('Detected barcode: $code');
    _isProcessing = true;

    // Check for duplicate scans within 2 seconds
    if (_lastScannedCode == code &&
        DateTime.now().difference(_lastScanTime) < const Duration(seconds: 2)) {
      print('Duplicate scan detected');
      _isProcessing = false;
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = DateTime.now();

    _processScannedCode(code);
  }

  Future<void> _processScannedCode(String code) async {
    try {
      print('Processing scanned code: $code');

      // Simulate API call to verify the code
      await Future.delayed(const Duration(seconds: 1));

      // Get saved prélèvements from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? prelevementsJson = prefs.getString('prelevements');
      print('Retrieved prelevements from storage: ${prelevementsJson != null}');

      if (prelevementsJson == null) {
        print('No prelevements found in storage');
        _showError('No prélèvements found');
        return;
      }

      final List<dynamic> prelevements = json.decode(prelevementsJson);
      print('Found ${prelevements.length} prelevements');

      final prelevement = prelevements.firstWhere(
        (p) => p['id'] == code,
        orElse: () => null,
      );

      if (prelevement == null) {
        print('No matching prelevement found for code: $code');
        _showError('Invalid QR code');
        return;
      }

      print('Found matching prelevement: ${prelevement['id']}');

      // Update the status to "Pending"
      prelevement['status'] = 'Pending';
      await prefs.setString('prelevements', json.encode(prelevements));
      print('Updated prelevement status to Pending');

      _showSuccess('Prélèvement status updated to Pending');

      // Navigate back to the previous screen
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error processing scanned code: $e');
      _showError('Error processing QR code');
    } finally {
      _isProcessing = false;
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: isDarkMode ? Color.fromARGB(255, 30, 40, 28) : null,
        actions: [
          // Toggle Flash
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() {
                _isFlashOn = !_isFlashOn;
                _scannerController.toggleTorch();
              });
            },
          ),
          // Switch Camera
          IconButton(
            icon: Icon(_isFrontCamera ? Icons.camera_front : Icons.camera_rear),
            onPressed: () {
              setState(() {
                _isFrontCamera = !_isFrontCamera;
                _scannerController.switchCamera();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner View
          MobileScanner(controller: _scannerController, onDetect: _onDetect),

          // Overlay
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Stack(
              children: [
                // Scanner Window
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Scanning Animation
                if (_isProcessing)
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Processing...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Instructions
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            color: primaryColor,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Position the QR code within the frame',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The scanner will automatically detect and process the code',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
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
      ),
    );
  }
}
