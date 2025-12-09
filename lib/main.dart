import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/splash_screen.dart';
import 'pages/settings_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/role_selection_page.dart';
import 'pages/notifications_page.dart';
import 'pages/profile_page.dart';
import 'pages/onboarding_page.dart';
import 'utils/page_transition.dart';

// Add imports for the technician pages
import 'pages/technician/home_page.dart';
import 'pages/technician/new_prelevement_page.dart';
import 'pages/technician/prelevement_details_page.dart';

// Add imports for the receptionist pages
import 'pages/reception/home_page.dart';
import 'pages/reception/scanning_page.dart';
import 'pages/reception/verify_page.dart';
import 'pages/reception/details_page.dart';

// Add imports for the responsable de dossier pages
import 'pages/responsable/home_page.dart';
import 'pages/responsable/dossier_page.dart';
import 'pages/responsable/assign_page.dart';

// Add imports for the responsable de laboratoire pages
import 'pages/lab/home_page.dart';
import 'pages/lab/test_details_page.dart';
import 'pages/lab/manage_testers_page.dart';
import 'pages/lab/resources_page.dart';
import 'pages/lab/reports_page.dart';
import 'pages/lab/tests_overview_page.dart';
import 'pages/lab/test_assignment_page.dart';

// Add imports for the testeur pages
import 'pages/testeur/home_page.dart';
import 'pages/testeur/test_execution_page.dart';
import 'pages/testeur/my_tests_page.dart';
import 'pages/testeur/history_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'LabTrack',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/reset-password': (context) => const ResetPasswordPage(),
        '/role-selection': (context) => const RoleSelectionPage(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/profile': (context) => const ProfilePage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/technician/home': (context) => const TechnicianHomePage(),
        '/technician/new': (context) => const NewPrelevementPage(),
        '/reception/home': (context) => const ReceptionHomePage(),
        '/reception/scan': (context) => const ScanningPage(),
        '/responsable/home': (context) => const ResponsableHomePage(),
        '/lab/home': (context) => const LabHomePage(),
        '/lab/testers': (context) => const ManageTestersPage(),
        '/lab/resources': (context) => const ResourcesPage(),
        '/lab/reports': (context) => const ReportsPage(),
        '/lab/tests': (context) => const TestsOverviewPage(),
        '/lab/assign': (context) => const TestAssignmentPage(),
        '/testeur/home': (context) => const TesteurHomePage(),
        '/testeur/test': (context) => const MyTestsPage(),
        '/testeur/history': (context) => const HistoryPage(),
      },
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return PageTransition(page: const SplashScreen());
      case '/login':
        return PageTransition(page: const LoginPage());
      case '/register':
        return PageTransition(page: const RegisterPage());
      case '/forgot-password':
        return PageTransition(page: const ForgotPasswordPage());
      case '/reset-password':
        return PageTransition(page: const ResetPasswordPage());
      case '/role-selection':
        return PageTransition(page: const RoleSelectionPage());
      case '/home':
        return PageTransition(page: const HomePage());
      case '/settings':
        return PageTransition(page: const SettingsPage());
      case '/notifications':
        return PageTransition(page: const NotificationsPage());
      case '/profile':
        return PageTransition(page: const ProfilePage());
      case '/onboarding':
        return PageTransition(page: const OnboardingPage());
      case '/technician/home':
        return PageTransition(page: const TechnicianHomePage());
      case '/technician/new':
        return PageTransition(page: const NewPrelevementPage());
      case '/reception/home':
        return PageTransition(page: const ReceptionHomePage());
      case '/reception/scan':
        return PageTransition(page: const ScanningPage());
      case '/responsable/home':
        return PageTransition(page: const ResponsableHomePage());
      case '/lab/home':
        return PageTransition(page: const LabHomePage());
      case '/lab/testers':
        return PageTransition(page: const ManageTestersPage());
      case '/lab/resources':
        return PageTransition(page: const ResourcesPage());
      case '/lab/reports':
        return PageTransition(page: const ReportsPage());
      case '/lab/tests':
        return PageTransition(page: const TestsOverviewPage());
      case '/lab/assign':
        return PageTransition(page: const TestAssignmentPage());
      case '/testeur/home':
        return PageTransition(page: const TesteurHomePage());
      case '/testeur/test':
        return PageTransition(page: const MyTestsPage());
      case '/testeur/history':
        return PageTransition(page: const HistoryPage());
      default:
        // Handle dynamic routes like '/technician/details/:id'
        if (settings.name?.startsWith('/technician/details/') ?? false) {
          final id = settings.name!.replaceFirst('/technician/details/', '');
          return PageTransition(page: PrelevementDetailsPage(id: id));
        }
        
        // Handle dynamic routes like '/reception/verify/:id'
        if (settings.name?.startsWith('/reception/verify/') ?? false) {
          final id = settings.name!.replaceFirst('/reception/verify/', '');
          return PageTransition(page: ReceptionVerifyPage(prelevementId: id));
        }
        
        // Handle dynamic routes like '/reception/details/:id'
        if (settings.name?.startsWith('/reception/details/') ?? false) {
          final id = settings.name!.replaceFirst('/reception/details/', '');
          return PageTransition(page: ReceptionDetailsPage(prelevementId: id));
        }
        
        // Handle dynamic routes like '/responsable/dossier/:id'
        if (settings.name?.startsWith('/responsable/dossier/') ?? false) {
          final id = settings.name!.replaceFirst('/responsable/dossier/', '');
          return PageTransition(page: ResponsableDossierPage(dossierId: id));
        }
        
        // Handle dynamic routes like '/responsable/assign/:id'
        if (settings.name?.startsWith('/responsable/assign/') ?? false) {
          final id = settings.name!.replaceFirst('/responsable/assign/', '');
          return PageTransition(page: ResponsableAssignPage(dossierId: id));
        }
        
        // Handle dynamic routes like '/lab/test/:id'
        if (settings.name?.startsWith('/lab/test/') ?? false) {
          final id = settings.name!.replaceFirst('/lab/test/', '');
          return PageTransition(page: TestDetailsPage(testId: id));
        }
        
        // Handle dynamic routes like '/lab/assign/:id'
        if (settings.name?.startsWith('/lab/assign/') ?? false) {
          final id = settings.name!.replaceFirst('/lab/assign/', '');
          return PageTransition(page: TestAssignmentPage(testId: id));
        }
        
        // Handle dynamic routes like '/testeur/test/:id'
        if (settings.name?.startsWith('/testeur/test/') ?? false) {
          final id = settings.name!.replaceFirst('/testeur/test/', '');
          return PageTransition(page: TestExecutionPage(testId: id));
        }
        
        // Return a not found page
        return PageTransition(page: const _NotFoundPage());
    }
  }
}

// Simple not found page
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('The requested page does not exist.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
