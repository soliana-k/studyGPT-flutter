import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _studyReminders = true;
  bool _progressNotifications = true;
  bool _quizFeedback = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF007BFF),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007BFF), Color(0xFF00B4FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'K',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'kidusan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _darkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'Grade 10',
                        style: TextStyle(
                          fontSize: 14,
                          color: _darkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Learning Preferences Section
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8),
              child: Text(
                'LEARNING PREFERENCES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _darkMode ? Colors.grey[500] : Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
            ),
            _buildSettingsCard(
              children: [
                _buildSettingsItem(
                  icon: Icons.language,
                  title: 'Language',
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: Container(),
                    dropdownColor: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    style: TextStyle(
                      color: _darkMode ? Colors.white : Colors.black,
                    ),
                    items: ['English', 'Amharic', 'Oromiffa', 'Tigrinya']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                      });
                    },
                  ),
                  darkMode: _darkMode,
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.color_lens,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                    activeColor: const Color(0xFF007BFF),
                    activeTrackColor: const Color(0xFF007BFF).withOpacity(0.5),
                  ),
                  darkMode: _darkMode,
                  onTap: () {},
                ),
              ],
              darkMode: _darkMode,
            ),

            const SizedBox(height: 16),

            // Notification Settings Section
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8),
              child: Text(
                'NOTIFICATION SETTINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _darkMode ? Colors.grey[500] : Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
            ),
            _buildSettingsCard(
              children: [
                _buildSettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'Study Reminders',
                  trailing: Switch(
                    value: _studyReminders,
                    onChanged: (value) {
                      setState(() {
                        _studyReminders = value;
                      });
                    },
                    activeColor: const Color(0xFF007BFF),
                    activeTrackColor: const Color(0xFF007BFF).withOpacity(0.5),
                  ),
                  darkMode: _darkMode,
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.analytics_outlined,
                  title: 'Progress Notifications',
                  trailing: Switch(
                    value: _progressNotifications,
                    onChanged: (value) {
                      setState(() {
                        _progressNotifications = value;
                      });
                    },
                    activeColor: const Color(0xFF007BFF),
                    activeTrackColor: const Color(0xFF007BFF).withOpacity(0.5),
                  ),
                  darkMode: _darkMode,
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.quiz_outlined,
                  title: 'Quiz Feedback',
                  trailing: Switch(
                    value: _quizFeedback,
                    onChanged: (value) {
                      setState(() {
                        _quizFeedback = value;
                      });
                    },
                    activeColor: const Color(0xFF007BFF),
                    activeTrackColor: const Color(0xFF007BFF).withOpacity(0.5),
                  ),
                  darkMode: _darkMode,
                  onTap: () {},
                ),
              ],
              darkMode: _darkMode,
            ),

            const SizedBox(height: 16),

            // Learning Goals Section
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8),
              child: Text(
                'LEARNING GOALS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _darkMode ? Colors.grey[500] : Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
            ),
            _buildSettingsCard(
              children: [
                _buildSettingsItem(
                  icon: Icons.school_outlined,
                  title: 'Update Learning Goals',
                  darkMode: _darkMode,
                  onTap: () {
                    // Navigate to learning goals screen
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.timer_outlined,
                  title: 'Study Time Preferences',
                  darkMode: _darkMode,
                  onTap: () {
                    // Navigate to study time preferences screen
                  },
                ),
              ],
              darkMode: _darkMode,
            ),

            const SizedBox(height: 16),

            // Account Actions Section
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8),
              child: Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _darkMode ? Colors.grey[500] : Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
            ),
            _buildSettingsCard(
              children: [
                _buildSettingsItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  darkMode: _darkMode,
                  onTap: _showLogoutDialog,
                ),
                _buildSettingsItem(
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  darkMode: _darkMode,
                  isDestructive: true,
                  onTap: _showDeleteAccountDialog,
                ),
              ],
              darkMode: _darkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required List<Widget> children,
    required bool darkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
              top: entry.key == 0 ? 0 : 1,
            ),
            child: entry.value,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required bool darkMode,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? Colors.red
                    : darkMode
                    ? const Color(0xFF007BFF)
                    : const Color(0xFF007BFF),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? Colors.red
                            : darkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: darkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ?? Icon(
                Icons.chevron_right,
                color: darkMode ? Colors.grey[500] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _darkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  color: _darkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: _darkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Logged out successfully!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This action cannot be undone. All your data will be permanently deleted.',
                style: TextStyle(
                  color: _darkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: _darkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Account deleted successfully!'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}