import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class DrawerWidget extends StatelessWidget {
  final String selectedRoute;
  final UserRole role;

  const DrawerWidget({
    Key? key,
    required this.selectedRoute,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          _buildDrawerItems(context, isDarkMode),
          const Divider(),
          _buildSettingsItems(context, isDarkMode),
          const Divider(),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return DrawerHeader(
      decoration: BoxDecoration(
        color: primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              _getUserInitials(),
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<String>(
            future: _getUserName(),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'User Name',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              );
            },
          ),
          FutureBuilder<String>(
            future: _getUserRole(),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? _getRoleTitle(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItems(BuildContext context, bool isDarkMode) {
    switch (role) {
      case UserRole.technician:
        return _buildTechnicianItems(context, isDarkMode);
      case UserRole.receptionist:
        return _buildReceptionistItems(context, isDarkMode);
      case UserRole.responsableDossier:
        return _buildResponsableItems(context, isDarkMode);
      case UserRole.labManager:
        return _buildLabItems(context, isDarkMode);
      case UserRole.labTechnician:
        return _buildLabTechnicianItems(context, isDarkMode);
      case UserRole.testeur:
        return _buildTesteurItems(context, isDarkMode);
      case UserRole.admin:
        return _buildAdminItems(context, isDarkMode);
      default:
        return _buildLabItems(context, isDarkMode);
    }
  }

  Widget _buildTechnicianItems(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Tableau de Bord'),
          selected: selectedRoute == Routes.technicianHome,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            if (selectedRoute != Routes.technicianHome) {
              Navigator.pushReplacementNamed(context, Routes.technicianHome);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.science),
          title: const Text('Nouveau Prélèvement'),
          selected: selectedRoute == Routes.technicianNew,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.technicianNew);
          },
        ),
      ],
    );
  }

  Widget _buildReceptionistItems(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Tableau de Bord'),
          selected: selectedRoute == Routes.receptionHome,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            if (selectedRoute != Routes.receptionHome) {
              Navigator.pushReplacementNamed(context, Routes.receptionHome);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.qr_code_scanner),
          title: const Text('Scanner'),
          selected: selectedRoute == Routes.receptionScan,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.receptionScan);
          },
        ),
      ],
    );
  }

  Widget _buildResponsableItems(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Tableau de Bord'),
          selected: selectedRoute == Routes.responsableHome,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            if (selectedRoute != Routes.responsableHome) {
              Navigator.pushReplacementNamed(context, Routes.responsableHome);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  Widget _buildLabItems(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Tableau de Bord'),
          selected: selectedRoute == Routes.labHome,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            if (selectedRoute != Routes.labHome) {
              Navigator.pushReplacementNamed(context, Routes.labHome);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Gérer les Testeurs'),
          selected: selectedRoute == Routes.labManage,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.labManage);
          },
        ),
        ListTile(
          leading: const Icon(Icons.inventory),
          title: const Text('Ressources & Équipements'),
          selected: selectedRoute == Routes.labResources,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.labResources);
          },
        ),
        ListTile(
          leading: const Icon(Icons.science),
          title: const Text('Tests en cours'),
          selected: selectedRoute == Routes.labTests,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.labTests);
          },
        ),
        ListTile(
          leading: const Icon(Icons.insert_chart),
          title: const Text('Rapports & Statistiques'),
          selected: selectedRoute == Routes.labReports,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.labReports);
          },
        ),
      ],
    );
  }

  Widget _buildLabTechnicianItems(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Tableau de Bord'),
          selected: selectedRoute == Routes.labHome,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            if (selectedRoute != Routes.labHome) {
              Navigator.pushReplacementNamed(context, Routes.labHome);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.science),
          title: const Text('Mes Tests'),
          selected: selectedRoute == Routes.labTests,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.labTests);
          },
        ),
      ],
    );
  }

  Widget _buildTesteurItems(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Tableau de Bord'),
          selected: selectedRoute == Routes.testeurHome,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            if (selectedRoute != Routes.testeurHome) {
              Navigator.pushReplacementNamed(context, Routes.testeurHome);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.science),
          title: const Text('Mes Tests'),
          selected: selectedRoute == Routes.testeurTest,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.testeurTest);
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Historique'),
          selected: selectedRoute == Routes.testeurHistory,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.testeurHistory);
          },
        ),
      ],
    );
  }

  Widget _buildAdminItems(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Tableau de Bord'),
          selected: selectedRoute == Routes.home,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            if (selectedRoute != Routes.home) {
              Navigator.pushReplacementNamed(context, Routes.home);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSettingsItems(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Paramètres'),
          selected: selectedRoute == Routes.settings,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.settings);
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          selected: selectedRoute == Routes.notifications,
          selectedColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          selectedTileColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.notifications);
          },
        ),
      ],
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        'Déconnexion',
        style: TextStyle(color: Colors.red),
      ),
      onTap: () {
        Navigator.pop(context);
        _showLogoutConfirmation(context);
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
        (route) => false,
      );
    }
  }

  String _getRoleTitle() {
    switch (role) {
      case UserRole.technician:
        return 'Technicien';
      case UserRole.receptionist:
        return 'Réceptionniste';
      case UserRole.responsableDossier:
        return 'Responsable de Dossier';
      case UserRole.labManager:
        return 'Responsable de Laboratoire';
      case UserRole.labTechnician:
        return 'Technicien de Laboratoire';
      case UserRole.testeur:
        return 'Testeur';
      case UserRole.admin:
        return 'Administrateur';
      default:
        return 'Utilisateur';
    }
  }

  String _getUserInitials() {
    return 'RL'; // This would be dynamic in a real app
  }

  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'Mohamed El Fassi';
  }

  Future<String> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefsKeys.userRoleTitle) ?? _getRoleTitle();
  }
} 