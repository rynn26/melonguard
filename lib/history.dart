import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF064E3B);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Detection History",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Recent Detections", primaryColor),
            const SizedBox(height: 12),
            _buildHistoryCard(
              date: "27 Sep 2025",
              result: "Powdery Mildew Detected",
              confidence: "95%",
              color: Colors.red.shade100,
              icon: Icons.warning_amber_rounded,
            ),
            _buildHistoryCard(
              date: "25 Sep 2025",
              result: "Healthy Leaf",
              confidence: "99%",
              color: Colors.green.shade100,
              icon: Icons.check_circle_rounded,
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("Tips", primaryColor),
            const SizedBox(height: 8),
            const Text(
              "You can swipe left/right to explore more detection records. "
              "Keep monitoring your plants regularly to ensure early detection of any disease.",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required String result,
    required String confidence,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: const Color(0xFF064E3B)),
        ),
        title: Text(
          result,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Confidence: $confidence\n$date"),
        isThreeLine: true,
      ),
    );
  }
}
