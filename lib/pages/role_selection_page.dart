import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:labtrack/utils/page_animations.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? _selectedRole;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roles = [
    {
      'id': 'admin',
      'title': 'Admin',
      'icon': Icons.admin_panel_settings,
      'description': 'Manage users and system settings',
    },
    {
      'id': 'technician',
      'title': 'Technician',
      'icon': Icons.engineering,
      'description': 'Perform tests and analyze samples',
    },
    {
      'id': 'receptionist',
      'title': 'Receptionist',
      'icon': Icons.person_outline,
      'description': 'Receive samples and client requests',
    },
    {
      'id': 'responsable_dossier',
      'title': 'Responsable Dossier',
      'icon': Icons.folder_outlined,
      'description': 'Manage and organize case files',
    },
    {
      'id': 'responsable_laboratoire',
      'title': 'Responsable Laboratoire',
      'icon': Icons.science_outlined,
      'description': 'Oversee laboratory operations',
    },
    {
      'id': 'operateur',
      'title': 'Operateur',
      'icon': Icons.precision_manufacturing_outlined,
      'description': 'Operate laboratory equipment',
    },
  ];

  Future<void> _continueWithRole() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role to continue'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Save the selected role to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', _selectedRole!);

    // Also save the role title for display purposes
    final selectedRoleData = _roles.firstWhere(
      (role) => role['id'] == _selectedRole,
    );
    await prefs.setString('userRoleTitle', selectedRoleData['title']);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isLoading = false;
    });

    // Navigate based on selected role
    if (mounted) {
      switch (_selectedRole) {
        case 'technician':
          // Clear all navigation history when entering a role's area
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/technician/home',
            (route) => false, // This removes all previous routes
          );
          break;
        case 'receptionist':
          // Navigate to receptionist home page
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/reception/home',
            (route) => false,
          );
          break;
        case 'responsable_dossier':
          // Navigate to responsable de dossier home page
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/responsable/home',
            (route) => false,
          );
          break;
        case 'responsable_laboratoire':
          // Navigate to lab manager home page
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/lab/home',
            (route) => false,
          );
          break;
        case 'operateur':
          // Navigate to testeur home page
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/testeur/home',
            (route) => false,
          );
          break;

        case 'admin':
          // For now, navigate to general home until admin pages are implemented
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          break;
        default:
          // Default navigation for other roles
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Single large title at the top
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  final isSelected = _selectedRole == role['id'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRole = role['id'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                                : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            role['icon'],
                            size: 48,
                            color:
                                isSelected
                                    ? const Color(0xFF2C2C2C)
                                    : Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          // Properly center multi-word titles
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              role['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? const Color(0xFF2C2C2C)
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              role['description'],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isSelected
                                        ? const Color(
                                          0xFF2C2C2C,
                                        ).withOpacity(0.8)
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _continueWithRole,
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(0xFF2C2C2C),
                            ),
                          )
                          : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
