import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricEmailKey = 'biometric_email';
  
  // Check if biometrics are available
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      
      // Debug output
      debugPrint('Can authenticate with biometrics: $canAuthenticateWithBiometrics');
      debugPrint('Device supported: ${await _localAuth.isDeviceSupported()}');
      debugPrint('Can authenticate: $canAuthenticate');
      
      return canAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Error checking biometric availability: ${e.message}');
      return false;
    }
  }
  
  // Get available biometrics
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      
      // Debug output
      debugPrint('Available biometrics: $biometrics');
      
      return biometrics;
    } on PlatformException catch (e) {
      debugPrint('Error getting available biometrics: ${e.message}');
      return [];
    }
  }
  
  // Authenticate with biometrics
  static Future<bool> authenticate() async {
    try {
      debugPrint('Starting biometric authentication...');
      
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Changed to false to allow PIN/pattern as fallback
        ),
      );
      
      debugPrint('Authentication result: $didAuthenticate');
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Error during authentication: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error during authentication: $e');
      return false;
    }
  }
  
  // Save email for biometric login
  static Future<bool> saveForBiometricLogin(String email) async {
    try {
      if (email.isEmpty) {
        debugPrint('Cannot save empty email for biometric login');
        return false;
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, true);
      await prefs.setString(_biometricEmailKey, email);
      
      debugPrint('Biometric login enabled for email: $email');
      return true;
    } catch (e) {
      debugPrint('Error saving biometric login data: $e');
      return false;
    }
  }
  
  // Check if biometric login is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_biometricEnabledKey) ?? false;
      final email = prefs.getString(_biometricEmailKey);
      
      // Only consider enabled if we have both the flag and an email
      final isEnabled = enabled && email != null && email.isNotEmpty;
      
      debugPrint('Biometric login enabled: $isEnabled (flag: $enabled, email: ${email != null})');
      
      return isEnabled;
    } catch (e) {
      debugPrint('Error checking if biometric login is enabled: $e');
      return false;
    }
  }
  
  // Get saved email for biometric login
  static Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_biometricEmailKey);
      
      debugPrint('Retrieved saved email for biometric login: $email');
      
      return email;
    } catch (e) {
      debugPrint('Error getting saved email: $e');
      return null;
    }
  }
  
  // Clear biometric login data
  static Future<void> clearBiometricData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_biometricEnabledKey);
      await prefs.remove(_biometricEmailKey);
      
      debugPrint('Biometric login data cleared');
    } catch (e) {
      debugPrint('Error clearing biometric data: $e');
    }
  }
  
  // Enable biometric login with the current email
  static Future<bool> enableBiometricLogin(String email) async {
    try {
      // First check if biometrics are available
      final biometricsAvailable = await isBiometricAvailable();
      if (!biometricsAvailable) {
        debugPrint('Biometrics not available on this device');
        return false;
      }
      
      // Authenticate the user
      final authenticated = await authenticate();
      if (!authenticated) {
        debugPrint('Authentication failed');
        return false;
      }
      
      // Save the email for biometric login
      final saved = await saveForBiometricLogin(email);
      return saved;
    } catch (e) {
      debugPrint('Error enabling biometric login: $e');
      return false;
    }
  }
} 