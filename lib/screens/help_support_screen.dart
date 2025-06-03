import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help & Support"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            SizedBox(height: 20),

            _buildInfoCard(
              Icons.help_outline,
              "How to Use Gesture Recognition",
              "Learn how to control the virtual mouse using gestures detected by your device's camera.",
            ),

            _buildSectionTitle("Step 1: Activating Gesture Recognition"),
            _buildBulletPoint("Open the app and sign in."),
            _buildBulletPoint("Press 'Start Gesture Recognition' on the home page."),
            _buildBulletPoint("The camera will start tracking your hand gestures."),

            _buildSectionTitle("Step 2: Supported Gestures & Actions"),
            _buildBulletPoint("🔼 Swipe Up/Down - Move cursor vertically"),
            _buildBulletPoint("🔄 Swipe Left/Right - Move cursor horizontally"),
            _buildBulletPoint("✌️ Pinch - Click"),
            _buildBulletPoint("🖐️ Open Hand - Scroll"),
            _buildBulletPoint("✊ Fist - Right-click"),
            _buildBulletPoint("👍/👎 Thumb Up/Down - Change volume/brightness"),

            _buildSectionTitle("Step 3: Tips for Effective Gesture Control"),
            _buildBulletPoint("Ensure hands are within the camera view."),
            _buildBulletPoint("Keep lighting adequate for clear tracking."),
            _buildBulletPoint("Perform smooth and steady hand movements."),

            SizedBox(height: 20),

            _buildInfoCard(
              Icons.warning_amber_rounded,
              "Common Issues & Solutions",
              "Troubleshooting tips if you face issues with gesture recognition.",
            ),

            _buildIssueSolution("❌ Gesture recognition not working?", [
              "✔️ Check camera permissions.",
              "✔️ Ensure no obstruction to the camera."
            ]),
            _buildIssueSolution("⚠️ Gestures not responding?", [
              "✔️ Recalibrate gestures.",
              "✔️ Restart the app for reset."
            ]),

            SizedBox(height: 20),

            _buildInfoCard(
              Icons.support_agent,
              "Need Help? Contact Us!",
              "Reach out to our support team for assistance.",
            ),

            SizedBox(height: 10),

            _buildContactOption(Icons.chat, "Live Chat Support", "Chat with our team (9 AM - 6 PM)"),
            _buildContactOption(Icons.email, "Email Support", "support@virtualmouse.com"),
            _buildContactOption(Icons.phone, "Phone Support", "+123 456 7890"),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.support, color: Colors.white, size: 40),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Need Help? Find all the information here.",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String description) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent, size: 30),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(description, style: TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildIssueSolution(String issue, List<String> solutions) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(issue, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ...solutions.map((solution) => _buildBulletPoint(solution)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String title, String subtitle) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent, size: 30),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
