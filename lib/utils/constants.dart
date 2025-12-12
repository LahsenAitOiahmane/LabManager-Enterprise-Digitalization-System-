import 'package:flutter/material.dart';

// Constants for role management
enum UserRole {
  technician,
  receptionist,
  responsableDossier,
  labManager,
  labTechnician,
  testeur,
  admin
}

// Color constants
class AppColors {
  static const primaryColor = Color(0xFFC1F11D);
  static const darkPrimaryColor = Color(0xFF90AD16);
  static const accentColor = Color(0xFF2FDD92);
  static const textColor = Color(0xFF2C2C2C);
  static const errorColor = Color(0xFFFF4D4F);
  static const warningColor = Color(0xFFFFA940);
  static const successColor = Color(0xFF52C41A);
}

// API endpoints
class ApiEndpoints {
  static const baseUrl = 'https://api.labtrack.ma';
  static const login = '$baseUrl/auth/login';
  static const register = '$baseUrl/auth/register';
  static const prelevements = '$baseUrl/prelevements';
  static const tests = '$baseUrl/tests';
  static const users = '$baseUrl/users';
}

// Date formats
class DateFormats {
  static const date = 'dd/MM/yyyy';
  static const time = 'HH:mm';
  static const dateTime = 'dd/MM/yyyy HH:mm';
}

// Route names
class Routes {
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const onboarding = '/onboarding';
  static const roleSelection = '/role-selection';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const profile = '/profile';
  
  // Technician routes
  static const technicianHome = '/technician/home';
  static const technicianNew = '/technician/new';
  static const technicianDetails = '/technician/details';
  
  // Reception routes
  static const receptionHome = '/reception/home';
  static const receptionScan = '/reception/scan';
  static const receptionVerify = '/reception/verify';
  static const receptionDetails = '/reception/details';
  
  // Responsable routes
  static const responsableHome = '/responsable/home';
  static const responsableDossier = '/responsable/dossier';
  static const responsableAssign = '/responsable/assign';
  
  // Lab routes
  static const labHome = '/lab/home';
  static const labManage = '/lab/testers';
  static const labResources = '/lab/resources';
  static const labTests = '/lab/tests';
  static const labTestDetails = '/lab/test';
  static const labReports = '/lab/reports';
  static const labAssign = '/lab/assign';
  
  // Testeur routes
  static const testeurHome = '/testeur/home';
  static const testeurTest = '/testeur/test';
  static const testeurHistory = '/testeur/history';
}

// Shared Preferences keys
class PrefsKeys {
  static const darkMode = 'dark_mode';
  static const userRole = 'userRole';
  static const userRoleTitle = 'userRoleTitle';
  static const userEmail = 'userEmail';
  static const userId = 'userId';
  static const authToken = 'authToken';
  static const hasLoggedInBefore = 'has_logged_in_before';
  static const onboardingComplete = 'onboarding_complete';
  static const biometricEnabled = 'biometric_enabled';
  static const biometricEmail = 'biometric_email';
} 