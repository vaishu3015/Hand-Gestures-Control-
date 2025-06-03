import 'package:flutter/material.dart';
import 'package:my_flutter_app/screens/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  double _gestureSensitivity = 0.5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool("notifications") ?? true;
      _gestureSensitivity = prefs.getDouble("gesture_sensitivity") ?? 0.5;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    }
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("English"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Language changed to English")));
              },
            ),
            ListTile(
              title: Text("Hindi"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("भाषा हिंदी में बदल दी गई")));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _changePassword() {
    FirebaseAuth.instance.sendPasswordResetEmail(
      email: FirebaseAuth.instance.currentUser!.email!,
    );
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent")));
  }

  void _openPrivacyPolicy() async {
    const url = "https://www.example.com/privacy-policy";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Could not open privacy policy")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: themeProvider.isDarkMode ? Colors.black87 : Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildSectionTitle("General"),
          _buildSwitchTile(
            "Enable Notifications",
            "Turn app notifications on or off",
            Icons.notifications_active,
            _notificationsEnabled,
            (value) {
              setState(() => _notificationsEnabled = value);
              _saveSetting("notifications", value);
            },
          ),
          _buildListTile("Language", "Change app language", Icons.language, _changeLanguage),

          SizedBox(height: 20),
          _buildSectionTitle("Gestures"),
          _buildListTile("Configure Gestures", "Customize hand gestures", Icons.gesture, () {}),
          _buildSlider("Gesture Sensitivity", Icons.speed),

          SizedBox(height: 20),
          _buildSectionTitle("Appearance"),
          _buildSwitchTile(
            "Theme",
            "Light / Dark mode",
            Icons.dark_mode,
            themeProvider.isDarkMode,
            (value) {
              themeProvider.toggleTheme(value);
            },
          ),

          SizedBox(height: 20),
          _buildSectionTitle("Account"),
          _buildListTile("Change Password", "Update your password", Icons.lock, _changePassword),
          _buildListTile("Privacy Policy", "Read our policies", Icons.privacy_tip, _openPrivacyPolicy),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.black54)),
      secondary: Icon(icon, color: Colors.blueAccent),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.black54)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSlider(String title, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.blueAccent),
          title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
        Slider(
          value: _gestureSensitivity,
          onChanged: (value) {
            setState(() => _gestureSensitivity = value);
            _saveSetting("gesture_sensitivity", value);
          },
          min: 0,
          max: 1,
          activeColor: Colors.blue,
          inactiveColor: Colors.grey.shade300,
        ),
      ],
    );
  }
}
