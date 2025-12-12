import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:labtrack/services/biometric_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _biometricsAvailable = false;
  bool _biometricsEnabled = false;
  List<BiometricType> _availableBiometrics = [];
  bool _shouldShowBiometric = false;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _checkBiometrics();
    _loadRememberedEmail();

    // Schedule the argument check for after the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForBiometricArguments();
    });
  }

  void _checkForBiometricArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final showBiometric = args['showBiometric'] as bool?;
      final email = args['email'] as String?;

      if (showBiometric == true && email != null) {
        setState(() {
          _emailController.text = email;
          _shouldShowBiometric = true;
        });

        // Automatically trigger biometric authentication
        _authenticateWithBiometrics();
      }
    }
  }

  // Method to save email for remember me feature
  Future<void> _saveRememberedEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('remembered_email', email);
    } catch (e) {
      debugPrint('Error saving remembered email: $e');
    }
  }

  // Method to load remembered email
  Future<void> _loadRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('remembered_email');
      if (email != null && email.isNotEmpty) {
        setState(() {
          _emailController.text = email;
          _rememberMe = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading remembered email: $e');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!_biometricsEnabled || !_biometricsAvailable) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authenticated = await BiometricService.authenticate();

      if (authenticated) {
        final email = await BiometricService.getSavedEmail();
        if (email != null && email.isNotEmpty) {
          // Save user info to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', email);
          await prefs.setBool('has_logged_in_before', true);

          String? userRole;
          String? userRoleTitle;

          if (email.startsWith('tech.')) {
            userRole = 'technician';
            userRoleTitle = 'Technician';
            await prefs.setString('userRole', userRole);
            await prefs.setString('userRoleTitle', userRoleTitle);

            // Navigate to technician home page - clear navigation history
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/technician/home',
                (route) => false,
              );
            }
          } else {
            // Default for other roles - clear navigation history
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/role-selection',
                (route) => false,
              );
            }
          }
        } else {
          // No email stored, can't log in with biometrics
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Biometric login is not properly set up. Please log in with email and password first.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Authentication failed
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Error during authentication
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during biometric authentication: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkBiometrics() async {
    final isAvailable = await BiometricService.isBiometricAvailable();
    final isEnabled = await BiometricService.isBiometricEnabled();
    final biometrics = await BiometricService.getAvailableBiometrics();

    setState(() {
      _biometricsAvailable = isAvailable;
      _biometricsEnabled = isEnabled;
      _availableBiometrics = biometrics;

      // If biometrics are enabled, pre-fill the email
      if (_biometricsEnabled) {
        BiometricService.getSavedEmail().then((email) {
          if (email != null && email.isNotEmpty) {
            _emailController.text = email;
          }
        });
      }
    });

    // Debug information
    debugPrint('Biometrics available: $_biometricsAvailable');
    debugPrint('Biometrics enabled: $_biometricsEnabled');
    debugPrint('Available biometrics: $_availableBiometrics');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Save email if remember me is checked
      if (_rememberMe) {
        // Just save email, don't enable biometrics
        _saveRememberedEmail(_emailController.text);
      }

      // Get user email for role determination
      final email = _emailController.text;

      // Simulate login delay
      Future.delayed(const Duration(seconds: 2), () async {
        setState(() {
          _isLoading = false;
        });

        // Save user info to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email);
        await prefs.setBool('has_logged_in_before', true);

        // Determine user role based on email (in a real app, this would come from backend)
        String? userRole;
        String? userRoleTitle;

        // Simple role determination based on email prefix
        if (email.startsWith('tech.')) {
          userRole = 'technician';
          userRoleTitle = 'Technician';
          await prefs.setString('userRole', userRole);
          await prefs.setString('userRoleTitle', userRoleTitle);

          // Navigate to technician home page - clear navigation history
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/technician/home',
              (route) => false,
            );
          }
        } else if (email.startsWith('recept.')) {
          userRole = 'receptionist';
          userRoleTitle = 'Receptionist';
          await prefs.setString('userRole', userRole);
          await prefs.setString('userRoleTitle', userRoleTitle);

          // Navigate to receptionist page - clear navigation history
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/role-selection',
              (route) => false,
            );
          }
        } else if (email.startsWith('lab.')) {
          userRole = 'lab_technician';
          userRoleTitle = 'Lab Technician';
          await prefs.setString('userRole', userRole);
          await prefs.setString('userRoleTitle', userRoleTitle);

          // Navigate to lab technician page - clear navigation history
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/role-selection',
              (route) => false,
            );
          }
        } else if (email.startsWith('admin.')) {
          userRole = 'admin';
          userRoleTitle = 'Administrator';
          await prefs.setString('userRole', userRole);
          await prefs.setString('userRoleTitle', userRoleTitle);

          // Navigate to admin page - clear navigation history
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/role-selection',
              (route) => false,
            );
          }
        } else {
          // Default role or unknown
          userRole = 'user';
          userRoleTitle = 'User';
          await prefs.setString('userRole', userRole);
          await prefs.setString('userRoleTitle', userRoleTitle);

          // Navigate to role selection page - clear navigation history
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/role-selection',
              (route) => false,
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  SvgPicture.asset(
                    'assets/images/lab-icon.svg',
                    width: 80,
                    height: 80,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // App name
                  Text(
                    'LabTrack',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Email field with animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(
                      0,
                      _emailFocusNode.hasFocus ? -10 : 0,
                      0,
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor:
                            _emailFocusNode.hasFocus ||
                                    _emailController.text.isNotEmpty
                                ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color:
                                _emailController.text.isNotEmpty
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.withOpacity(0.3),
                            width: _emailController.text.isNotEmpty ? 1.5 : 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2.0,
                          ),
                        ),
                        suffixIcon:
                            _emailController.text.isNotEmpty
                                ? Icon(
                                  RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(_emailController.text)
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color:
                                      RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          ).hasMatch(_emailController.text)
                                          ? Colors.green
                                          : Colors.red,
                                )
                                : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        // Add domain validation for lpee.ma
                        if (!value.endsWith('lpee.ma')) {
                          return 'Only lpee.ma email addresses are allowed';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field with animation - FIXED to match email styling
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(
                      0,
                      _passwordFocusNode.hasFocus ? -10 : 0,
                      0,
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor:
                            _passwordFocusNode.hasFocus ||
                                    _passwordController.text.isNotEmpty
                                ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color:
                                _passwordController.text.isNotEmpty
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.withOpacity(0.3),
                            width:
                                _passwordController.text.isNotEmpty ? 1.5 : 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2.0,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Remember me checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      const Text('Remember me'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Login button with animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Theme.of(context).primaryColor.withOpacity(.1),
                      //     blurRadius: _isLoading ? 8 : 4,
                      //     offset: const Offset(0, 4),
                      //   ),
                      // ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),

                  if (_biometricsAvailable && _biometricsEnabled) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          final authenticated =
                              await BiometricService.authenticate();

                          if (authenticated) {
                            final email =
                                await BiometricService.getSavedEmail();
                            if (email != null && email.isNotEmpty) {
                              // Save user info to SharedPreferences
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('userEmail', email);

                              String? userRole;
                              String? userRoleTitle;

                              if (email.startsWith('tech.')) {
                                userRole = 'technician';
                                userRoleTitle = 'Technician';
                                await prefs.setString('userRole', userRole);
                                await prefs.setString(
                                  'userRoleTitle',
                                  userRoleTitle,
                                );

                                // Navigate to technician home page - clear navigation history
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/technician/home',
                                    (route) => false,
                                  );
                                }
                              } else {
                                // Default for other roles - clear navigation history
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/role-selection',
                                    (route) => false,
                                  );
                                }
                              }
                            } else {
                              // No email stored, can't log in with biometrics
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Biometric login is not properly set up. Please log in with email and password first.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } else {
                            // Authentication failed
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Biometric authentication failed',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          // Error during authentication
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error during biometric authentication: $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        _availableBiometrics.contains(BiometricType.face)
                            ? Icons.face
                            : _availableBiometrics.contains(
                              BiometricType.fingerprint,
                            )
                            ? Icons.fingerprint
                            : Icons.security,
                        size: 24,
                      ),
                      label: const Text(
                        'Biometric Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
