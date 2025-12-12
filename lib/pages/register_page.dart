import 'package:flutter/material.dart';
import 'package:labtrack/utils/page_animations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin, PageAnimationsMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _selectedRole = 'Technician';

  // Add focus nodes for smooth animations
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final List<String> _roles = ['Technician', 'Lab Manager', 'Client'];

  @override
  void initState() {
    super.initState();
    // Initialize the animations
    initAnimations();

    // Add listeners to update UI when focus changes
    _nameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
    _confirmPasswordFocusNode.addListener(() => setState(() {}));

    // Add listeners to update password strength in real-time
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));

    // Start animations
    startAnimations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    disposeAnimations();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate registration delay
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        // Navigate to login page after successful registration
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  String _getPasswordStrength(String password) {
    if (password.isEmpty) return 'Empty';
    if (password.length < 6) return 'Weak';
    if (password.length < 10) return 'Medium';
    if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Strong';
    }
    return 'Medium';
  }

  Color _getPasswordStrengthColor(String strength) {
    switch (strength) {
      case 'Weak':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Check if passwords match without showing error
  bool _passwordsMatch() {
    return _confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text == _passwordController.text;
  }

  // Check if email is valid without showing error
  bool _isEmailValid() {
    return _emailController.text.isNotEmpty &&
        RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              autovalidateMode:
                  AutovalidateMode.disabled, // Prevent automatic validation
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  animatedWidget(
                    child: Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  animatedWidget(
                    child: Text(
                      'Join LabTrack to streamline your lab workflow',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name field with animation
                  AnimatedPageItem(
                    delay: const Duration(milliseconds: 100),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(
                        0,
                        _nameFocusNode.hasFocus ? -10 : 0,
                        0,
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor:
                              _nameFocusNode.hasFocus ||
                                      _nameController.text.isNotEmpty
                                  ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color:
                                  _nameController.text.isNotEmpty
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.withOpacity(0.3),
                              width:
                                  _nameController.text.isNotEmpty ? 1.5 : 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email field with animation
                  AnimatedPageItem(
                    delay: const Duration(milliseconds: 150),
                    child: AnimatedContainer(
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
                              width:
                                  _emailController.text.isNotEmpty ? 1.5 : 1.0,
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
                                    _isEmailValid()
                                        ? Icons.check_circle
                                        : Icons.info_outline,
                                    color:
                                        _isEmailValid()
                                            ? Colors.green
                                            : Colors.orange,
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
                          if (!value.endsWith('lpee.ma')) {
                            return 'Only lpee.ma email addresses are allowed';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field with animation
                  AnimatedPageItem(
                    delay: const Duration(milliseconds: 200),
                    child: AnimatedContainer(
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
                          hintText: 'Create a password',
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
                                  _passwordController.text.isNotEmpty
                                      ? 1.5
                                      : 1.0,
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
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  // Password strength indicator (only show when password has content)
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 250),
                      child: Row(
                        children: [
                          Text(
                            'Password strength: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            _getPasswordStrength(_passwordController.text),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getPasswordStrengthColor(
                                _getPasswordStrength(_passwordController.text),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Animated progress indicator
                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 270),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 0,
                          end:
                              _passwordController.text.isEmpty
                                  ? 0
                                  : _getPasswordStrength(
                                        _passwordController.text,
                                      ) ==
                                      'Weak'
                                  ? 0.3
                                  : _getPasswordStrength(
                                        _passwordController.text,
                                      ) ==
                                      'Medium'
                                  ? 0.6
                                  : 1.0,
                        ),
                        builder:
                            (context, value, _) => LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getPasswordStrengthColor(
                                  _getPasswordStrength(
                                    _passwordController.text,
                                  ),
                                ),
                              ),
                              minHeight: 5,
                              borderRadius: BorderRadius.circular(10),
                            ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Confirm password field with animation
                  AnimatedPageItem(
                    delay: const Duration(milliseconds: 300),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(
                        0,
                        _confirmPasswordFocusNode.hasFocus ? -10 : 0,
                        0,
                      ),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Confirm your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor:
                              _confirmPasswordFocusNode.hasFocus ||
                                      _confirmPasswordController.text.isNotEmpty
                                  ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color:
                                  _confirmPasswordController.text.isNotEmpty
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.withOpacity(0.3),
                              width:
                                  _confirmPasswordController.text.isNotEmpty
                                      ? 1.5
                                      : 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0,
                            ),
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_confirmPasswordController.text.isNotEmpty)
                                Icon(
                                  _passwordsMatch()
                                      ? Icons.check_circle
                                      : Icons.error_outline,
                                  color:
                                      _passwordsMatch()
                                          ? Colors.green
                                          : Colors.orange,
                                  size: 20,
                                ),
                              IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Role selection with new design
                  AnimatedPageItem(
                    delay: const Duration(milliseconds: 350),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            bottom: 8.0,
                          ),
                          child: Text(
                            'Select your role',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children:
                              _roles.map((role) {
                                bool isSelected = _selectedRole == role;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedRole = role;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Theme.of(
                                                    context,
                                                  ).primaryColor
                                                  : Colors.grey.withOpacity(
                                                    0.3,
                                                  ),
                                        ),
                                        boxShadow:
                                            isSelected
                                                ? [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.4),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                                : null,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            role == 'Technician'
                                                ? Icons.science
                                                : role == 'Lab Manager'
                                                ? Icons.manage_accounts
                                                : Icons.person_outline,
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            role,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Theme.of(
                                                        context,
                                                      ).colorScheme.onSurface,
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Register button with animation
                  AnimatedPageItem(
                    delay: const Duration(milliseconds: 400),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
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
                                'Register',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login link
                  AnimatedPageItem(
                    delay: const Duration(milliseconds: 450),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
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
