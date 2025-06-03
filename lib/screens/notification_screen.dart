import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> notifications = [
      "🔔 New update available!",
      "✅ Your profile was updated",
      "🎮 Gesture control settings changed"
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.blueAccent,
        elevation: 1,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No notifications yet!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(), // 🔹 Adds separation
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active, color: Colors.blue),
                    title: Text(
                      notifications[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () {
                        // Future enhancement: Remove notification when pressed
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
