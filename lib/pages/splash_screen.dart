import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start animation
    _controller.forward();

    // Check biometrics and navigate
    _checkBiometricsAndNavigate();
  }

  Future<void> _checkBiometricsAndNavigate() async {
    // Wait longer for animations and loading resources
    await Future.delayed(const Duration(seconds: 10));

    // Always show onboarding during development
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    // The code below is temporarily bypassed for development
    /*
    // Check if biometric login is enabled
    final isBiometricEnabled = await BiometricService.isBiometricEnabled();
    final prefs = await SharedPreferences.getInstance();
    final hasLoggedInBefore = prefs.getBool('has_logged_in_before') ?? false;

    if (mounted) {
      if (!hasLoggedInBefore) {
        // First time user, show onboarding
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else if (isBiometricEnabled) {
        // Biometrics enabled, try to authenticate
        final email = await BiometricService.getSavedEmail();
        if (email != null) {
          // Navigate to login with biometric info
          Navigator.pushReplacementNamed(
            context, 
            '/login',
            arguments: {'showBiometric': true, 'email': email}
          );
        } else {
          // Navigate to normal login
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // No biometrics, normal login
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
    */
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animation
            FadeTransition(
              opacity: _opacityAnimation,
              child: Lottie.asset(
                'assets/animations/lab-animation.json',
                width: 200,
                height: 200,
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                },
              ),
            ),
            const SizedBox(height: 40),

            // App name
            FadeTransition(
              opacity: _opacityAnimation,
              child: Text(
                'LabTrack',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tagline
            FadeTransition(
              opacity: _opacityAnimation,
              child: Text(
                'Efficient Laboratory Sample Management',
                style: TextStyle(
                  fontSize: 16,
                  // color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),

            const SizedBox(height: 64),

            // Loading indicator
            FadeTransition(
              opacity: _opacityAnimation,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
