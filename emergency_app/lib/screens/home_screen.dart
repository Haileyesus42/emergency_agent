import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'contacts_screen.dart';
import '../widgets/emergency_button.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProfileScreen(),
    const ContactsScreen(),
  ];

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<ApiService>(context, listen: false).logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  void _triggerEmergency() {
    Provider.of<ApiService>(context, listen: false).triggerEmergencySOS().then((result) {
      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency signal sent successfully! Help is on the way.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to send emergency signal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF9FAFB), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          children: [
            // Header - matches HTML app-header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Logo and Title
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              '🚨',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Umojee',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'Emergency Management System',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Emergency SOS Button - matches HTML emergency-section
                  GestureDetector(
                    onTap: _triggerEmergency,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Color(0xFFDC2626)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Tabs - matches HTML app-nav
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _currentIndex == 0 ? const Color(0xFF667eea) : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '👤',
                              style: TextStyle(
                                fontSize: 20,
                                color: _currentIndex == 0 ? const Color(0xFF667eea) : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _currentIndex == 0 ? FontWeight.w600 : FontWeight.normal,
                                color: _currentIndex == 0 ? const Color(0xFF667eea) : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _currentIndex == 1 ? const Color(0xFF667eea) : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '📞',
                              style: TextStyle(
                                fontSize: 20,
                                color: _currentIndex == 1 ? const Color(0xFF667eea) : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Contacts',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _currentIndex == 1 ? FontWeight.w600 : FontWeight.normal,
                                color: _currentIndex == 1 ? const Color(0xFF667eea) : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleLogout,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '🚪',
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area - matches HTML app-content
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
      ),
    );
  }
}
