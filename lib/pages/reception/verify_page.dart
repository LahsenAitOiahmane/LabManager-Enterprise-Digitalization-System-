import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labtrack/utils/page_animations.dart';
import 'package:lottie/lottie.dart';

class ReceptionVerifyPage extends StatefulWidget {
  final String prelevementId;

  const ReceptionVerifyPage({super.key, required this.prelevementId});

  @override
  State<ReceptionVerifyPage> createState() => _ReceptionVerifyPageState();
}

class _ReceptionVerifyPageState extends State<ReceptionVerifyPage>
    with TickerProviderStateMixin, PageAnimationsMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _prelevement;
  Map<String, dynamic>? _scanInfo;
  bool _isVerified = false;
  bool _isRejected = false;
  String _rejectionReason = '';

  @override
  void initState() {
    super.initState();
    initAnimations();
    _loadPrelevementData();
    _loadScanInfo();
    startAnimations();
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  Future<void> _loadScanInfo() async {
    // In a real app, this would come from the scanning session or an API
    // Here we're just mocking the data

    _scanInfo = {
      'scan_id': 'SCAN-${DateTime.now().millisecondsSinceEpoch}',
      'scan_time': DateTime.now(),
      'scan_location': 'Reception Desk',
      'scanned_by': 'Current User',
      'scan_device': 'Mobile Scanner',
    };
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
        'status': 'pending',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'created_by': 'tech_1',
        'has_photos': true,
        'coords': {'lat': 33.5731, 'lng': -7.5898},
        'photos': [
          'https://example.com/photo1.jpg',
          'https://example.com/photo2.jpg',
        ],
        'notes':
            'Sample appears to be in good condition. Collected from depth of 1.5m.',
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

  void _verifyPrelevement() {
    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );
      },
    );

    // Simulate verification process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog

      setState(() {
        _isVerified = true;
        _isRejected = false;

        // Update the prelevement status
        if (_prelevement != null) {
          _prelevement!['status'] = 'Validated';
        }
      });

      // Show success animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Dialog(
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
                    'Verification Successful!',
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

      // Close animation dialog after delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    });
  }

  void _showRefuseDialog() {
    final TextEditingController reasonController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                isDarkMode ? Color.fromARGB(255, 30, 34, 28) : null,
            title: const Text('Refuse Prélèvement'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please provide a reason for refusing this prélèvement:',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter reason',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.black26 : Colors.grey[100],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _refusePrelevement(reasonController.text);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Refuse'),
              ),
            ],
          ),
    );
  }

  void _refusePrelevement(String reason) {
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason for refusing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );
      },
    );

    // Simulate verification process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog

      setState(() {
        _isRejected = true;
        _isVerified = false;
        _rejectionReason = reason;

        // Update the prelevement status and add rejection reason
        if (_prelevement != null) {
          _prelevement!['status'] = 'Rejected';
          _prelevement!['rejection_reason'] = reason;
        }
      });

      // Show refused animation/dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Prélèvement Refused',
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

      // Close animation dialog after delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    });
  }

  void _viewFullDetails() {
    if (mounted && _prelevement != null) {
      Navigator.pushNamed(context, '/reception/details/${_prelevement!['id']}');
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
        title: const Text('Verify Prélèvement'),
        backgroundColor: isDarkMode ? Color.fromARGB(255, 30, 40, 28) : null,
        actions: [
          if (!_isLoading &&
              _prelevement != null &&
              !_isVerified &&
              !_isRejected) ...[
            TextButton.icon(
              onPressed: _showRefuseDialog,
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Refuse', style: TextStyle(color: Colors.red)),
            ),
            TextButton.icon(
              onPressed: _verifyPrelevement,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                'Verify',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _prelevement == null
              ? Center(
                child: Text(
                  'Prélèvement not found',
                  style: TextStyle(color: textColor, fontSize: 18),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scan verification banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            _isRejected
                                ? Colors.red
                                : _isVerified
                                ? Colors.green
                                : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isRejected
                                ? Icons.cancel
                                : _isVerified
                                ? Icons.verified
                                : Icons.pending,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isRejected
                                      ? 'Rejected'
                                      : _isVerified
                                      ? 'Verified'
                                      : 'Awaiting Verification',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isRejected
                                      ? 'This prélèvement has been rejected'
                                      : _isVerified
                                      ? 'This prélèvement has been verified'
                                      : 'Please verify this prélèvement',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                if (_isRejected && _rejectionReason.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Reason: $_rejectionReason',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Scan information section
                    Text(
                      'Scan Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Scan ID:',
                                  style: TextStyle(
                                    color: subtleTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _scanInfo?['scan_id'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Scan Time:',
                                  style: TextStyle(
                                    color: subtleTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _scanInfo?['scan_time'] != null
                                      ? DateFormat(
                                        'dd/MM/yyyy HH:mm',
                                      ).format(_scanInfo!['scan_time'])
                                      : 'Unknown',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Scanned By:',
                                  style: TextStyle(
                                    color: subtleTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _scanInfo?['scanned_by'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Location:',
                                  style: TextStyle(
                                    color: subtleTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _scanInfo?['scan_location'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Prelevement information section
                    Text(
                      'Prélèvement Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ID Card
                    Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ID and Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _prelevement!['id'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                    fontSize: 18,
                                  ),
                                ),
                                _buildStatusChip(_prelevement!['status']),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Date and Material
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
                                  ).format(_prelevement!['date']),
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
                                  _prelevement!['material'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location Card
                    Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                    _prelevement!['location'],
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // View full details button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _viewFullDetails,
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Full Details'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
