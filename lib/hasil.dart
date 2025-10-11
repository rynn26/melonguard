import 'package:flutter/material.dart';

class HasilPage extends StatelessWidget {
  const HasilPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF064E3B);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Detection Result",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Result Summary", primaryColor),
            const SizedBox(height: 12),
            _buildResultCard(
              title: "Powdery Mildew Detected",
              confidence: "95%",
              description:
                  "The leaf shows signs of powdery mildew. Apply fungicide and ensure good air circulation.",
              color: Colors.red.shade100,
              icon: Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("Next Steps", primaryColor),
            const SizedBox(height: 8),
            _buildStep(Icons.medical_services, "Treatment",
                "Use organic or chemical fungicide to control mildew."),
            _buildStep(Icons.sunny, "Environment",
                "Avoid overwatering and increase sunlight exposure."),
            _buildStep(Icons.refresh, "Recheck",
                "Scan again after 3-5 days to monitor leaf recovery."),

            const SizedBox(height: 20),
            _buildSectionTitle("Tips", primaryColor),
            const SizedBox(height: 8),
            const Text(
              "For accurate detection, ensure the leaf image is clear and taken in good lighting conditions.",
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

  Widget _buildResultCard({
    required String title,
    required String confidence,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: const Color(0xFF064E3B)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Confidence: $confidence",
                      style:
                          const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF064E3B)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
