import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:labtrack/services/biometric_service.dart';
import 'package:labtrack/utils/page_animations.dart';
import 'package:labtrack/utils/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin, PageAnimationsMixin {
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  // Animation controller for dark mode toggle
  late AnimationController _darkModeAnimController;
  Animation<double>? _darkModeAnimation;
  double? _tapPositionX;
  double? _tapPositionY;
  bool _animatingDarkMode = false;

  @override
  void initState() {
    super.initState();
    initAnimations();
    _loadSettings();

    // Initialize dark mode animation controller with shorter duration
    _darkModeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 800,
      ), // Longer duration for wave effect
    );

    _darkModeAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animatingDarkMode = false;
        });
        _darkModeAnimController.reset();
      }
    });
  }

  @override
  void dispose() {
    disposeAnimations();
    _darkModeAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
      _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _isLoading = false;
    });

    startAnimations();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme section
                    animatedWidget(
                      child: _buildSectionHeader(
                        Icons.palette_outlined,
                        'Appearance',
                      ),
                    ),

                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 100),
                      child: _buildSettingCard(
                        child: Stack(
                          children: [
                            // Dark mode animation overlay - using a wave effect
                            if (_animatingDarkMode &&
                                _darkModeAnimation != null)
                              AnimatedBuilder(
                                animation: _darkModeAnimation!,
                                builder: (context, child) {
                                  final screenSize =
                                      MediaQuery.of(context).size;

                                  // Create a wave-like animation that ripples across the screen
                                  return Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CustomPaint(
                                        painter: WaveAnimationPainter(
                                          animation: _darkModeAnimation!.value,
                                          color:
                                              _darkModeEnabled
                                                  ? Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black
                                                  : Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.black
                                                  : Colors.white,
                                          tapPosition: Offset(
                                            _tapPositionX ??
                                                screenSize.width / 2,
                                            _tapPositionY ??
                                                screenSize.height / 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                            // Dark mode switch
                            SwitchListTile(
                              title: const Text('Dark Mode'),
                              subtitle: const Text(
                                'Toggle between light and dark themes',
                              ),
                              value: _darkModeEnabled,
                              onChanged: (value) {
                                // Get tap position from the RenderBox
                                final renderBox =
                                    context.findRenderObject() as RenderBox;
                                final center = renderBox.size.center(
                                  renderBox.localToGlobal(Offset.zero),
                                );

                                setState(() {
                                  _tapPositionX = center.dx;
                                  _tapPositionY = center.dy;
                                  _animatingDarkMode = true;
                                  _darkModeEnabled = value;

                                  // Create animation with a more interesting curve
                                  _darkModeAnimation = Tween<double>(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _darkModeAnimController,
                                      curve:
                                          Curves
                                              .easeInOut, // Smooth curve for wave effect
                                    ),
                                  );
                                });

                                // Start animation
                                _darkModeAnimController.forward();

                                // Update theme immediately for better responsiveness
                                themeProvider.toggleTheme();

                                // Save preference after a short delay
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool('darkMode', value);
                                  },
                                );
                              },
                              secondary: Icon(
                                _darkModeEnabled
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Security section
                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 150),
                      child: _buildSectionHeader(
                        Icons.security_outlined,
                        'Security',
                      ),
                    ),

                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 200),
                      child: _buildSettingCard(
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Biometric Authentication'),
                              subtitle: const Text(
                                'Use your biometrics to log in quickly',
                              ),
                              value: _biometricEnabled,
                              onChanged: (value) async {
                                if (value) {
                                  // First check if biometrics are available
                                  final biometricsAvailable =
                                      await BiometricService.isBiometricAvailable();
                                  if (!biometricsAvailable) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Biometric authentication is not available on this device',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  // Get current user email
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final email = prefs.getString('userEmail');

                                  if (email == null || email.isEmpty) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please log in first to enable biometrics',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  // Try to enable biometric login
                                  final success =
                                      await BiometricService.enableBiometricLogin(
                                        email,
                                      );

                                  if (success) {
                                    setState(() {
                                      _biometricEnabled = true;
                                    });

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Biometric authentication enabled',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Failed to enable biometric authentication',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  // Disable biometric
                                  await BiometricService.clearBiometricData();
                                  setState(() {
                                    _biometricEnabled = false;
                                  });

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Biometric authentication disabled',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }

                                // Save preference
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool(
                                  'biometricEnabled',
                                  _biometricEnabled,
                                );
                              },
                              secondary: Icon(
                                Icons.fingerprint,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: Icon(
                                Icons.password_outlined,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: const Text('Change Password'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password change functionality coming soon',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Notifications section
                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 250),
                      child: _buildSectionHeader(
                        Icons.notifications_outlined,
                        'Notifications',
                      ),
                    ),

                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 300),
                      child: _buildSettingCard(
                        child: SwitchListTile(
                          title: const Text('Push Notifications'),
                          subtitle: const Text('Receive updates and alerts'),
                          value: _notificationsEnabled,
                          onChanged: (value) async {
                            setState(() {
                              _notificationsEnabled = value;
                            });

                            // Save preference
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('notificationsEnabled', value);
                          },
                          secondary: Icon(
                            _notificationsEnabled
                                ? Icons.notifications_active_outlined
                                : Icons.notifications_off_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Account section
                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 350),
                      child: _buildSectionHeader(
                        Icons.account_circle_outlined,
                        'Account',
                      ),
                    ),

                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 400),
                      child: _buildSettingCard(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.person_outline,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: const Text('View Profile'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: Icon(Icons.logout, color: Colors.red),
                              title: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: _showLogoutConfirmation,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // About section
                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 450),
                      child: _buildSectionHeader(Icons.info_outline, 'About'),
                    ),

                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 500),
                      child: _buildSettingCard(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.help_outline,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: const Text('Help & Support'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Help & Support coming soon'),
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: Icon(
                                Icons.description_outlined,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: const Text('Terms & Privacy Policy'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Terms & Privacy Policy coming soon',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: Icon(
                                Icons.info_outline,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: const Text('App Version'),
                              subtitle: const Text('1.0.0'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
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

  Widget _buildSettingCard({required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout Confirmation'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _logout();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    // Clear user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}

class WaveAnimationPainter extends CustomPainter {
  final double animation;
  final Color color;
  final Offset tapPosition;

  WaveAnimationPainter({
    required this.animation,
    required this.color,
    required this.tapPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withOpacity(0.7)
          ..style = PaintingStyle.fill;

    // Create a wave-like effect with multiple sine waves
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Start from the tap position
    final startX = tapPosition.dx;
    final startY = tapPosition.dy;

    // Create a wave that expands from the tap point
    final waveRadius = animation * (width + height);

    // Draw multiple waves with different phases and amplitudes
    for (int i = 0; i < 3; i++) {
      final waveOpacity = (1.0 - animation) * (1.0 - i * 0.2);
      final wavePaint =
          Paint()
            ..color = color.withOpacity(waveOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;

      // Create a circular wave
      canvas.drawCircle(Offset(startX, startY), waveRadius - i * 20, wavePaint);
    }

    // Add a ripple effect with a gradient
    final gradient = RadialGradient(
      center: Alignment((startX / width) * 2 - 1, (startY / height) * 2 - 1),
      radius: animation,
      colors: [color.withOpacity(0.5), color.withOpacity(0.0)],
    );

    final gradientPaint =
        Paint()
          ..shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawCircle(Offset(startX, startY), waveRadius * 0.8, gradientPaint);
  }

  @override
  bool shouldRepaint(WaveAnimationPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.color != color ||
        oldDelegate.tapPosition != tapPosition;
  }
}
