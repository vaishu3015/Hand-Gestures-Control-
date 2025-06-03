import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';
import 'gesture_control_screen.dart';
import 'help_support_screen.dart';
import 'login_screen.dart'; // Import the login screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String loginTime = DateFormat('hh:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[100], // Soft background color
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Text(
                "Login: $loginTime",
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black54),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔵 **Profile Section**
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueAccent,
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome, ${user?.displayName ?? 'User'}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user?.email ?? "No Email Available",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.verified, color: Colors.blue, size: 24),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔵 **Grid Menu Section**
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.2, // Improves button balance
                children: [
                  _buildMenuItem(context, Icons.person, "Profile", ProfileScreen(), Colors.blue),
                  _buildMenuItem(context, Icons.settings, "Settings", const SettingsScreen(), Colors.orange),
                  _buildMenuItem(context, Icons.notifications, "Notifications", const NotificationScreen(), Colors.green),
                  _buildMenuItem(context, Icons.gesture, "Gesture Control",GestureControlScreen(), Colors.purple),
                  _buildMenuItem(context, Icons.help_outline, "Help & Support", const HelpSupportScreen(), Colors.redAccent),
                ],
              ),
            ),

            // 🔴 **Updated Logout Button**
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false, // Removes all previous routes
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  // 🔹 **Updated Grid Menu Item with Gradient Background**
  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Widget screen, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
