import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:labtrack/utils/page_animations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin, PageAnimationsMixin {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initAnimations();
    _fetchUserData();
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    // Simulate API call to fetch user data
    await Future.delayed(const Duration(seconds: 1));

    // Get role from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail') ?? 'user@lpee.ma';
    final roleTitle = prefs.getString('userRoleTitle') ?? 'Technician';

    // Simulate user data
    setState(() {
      _userData = {
        'name': 'Mohammed Alami',
        'email': email,
        'role': roleTitle,
        'department': 'Soil Analysis',
        'joinDate': '15/06/2022',
        'avatar': null, // Null means we'll use initials
      };
      _isLoading = false;
    });

    // Start animations after data is loaded
    startAnimations();
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
      // Replace with pushNamedAndRemoveUntil to clear all routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false, // This predicate means "remove all routes"
      );
    }
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

  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  int min(int a, int b) => a < b ? a : b;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // User avatar
                    animatedWidget(
                      child: Hero(
                        tag: 'profile-avatar',
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).primaryColor,
                          backgroundImage:
                              _userData!['avatar'] != null
                                  ? NetworkImage(_userData!['avatar'])
                                  : null,
                          child:
                              _userData!['avatar'] == null
                                  ? Text(
                                    _getInitials(_userData!['name']),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                  : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // User name
                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        _userData!['name'],
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // User role
                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 150),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _userData!['role'],
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Info card
                    AnimatedPageItem(
                      delay: const Duration(milliseconds: 200),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.email_outlined,
                                'Email',
                                _userData!['email'],
                              ),
                              const Divider(height: 32),
                              _buildInfoRow(
                                Icons.business_outlined,
                                'Department',
                                _userData!['department'],
                              ),
                              const Divider(height: 32),
                              _buildInfoRow(
                                Icons.calendar_today_outlined,
                                'Joined',
                                _userData!['joinDate'],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Edit button
                        Expanded(
                          child: AnimatedPageItem(
                            delay: const Duration(milliseconds: 250),
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit Profile'),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Edit profile functionality coming soon',
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Logout button
                        Expanded(
                          child: AnimatedPageItem(
                            delay: const Duration(milliseconds: 300),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.logout),
                              label: const Text('Logout'),
                              onPressed: _showLogoutConfirmation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
