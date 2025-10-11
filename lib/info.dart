import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF064E3B);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Tentang & Bantuan",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // About App Section
            _buildSectionTitle("Tentang Aplikasi", primaryColor),
            const SizedBox(height: 8),
            const Text(
              "This app helps detect melon leaf diseases using AI to support farmers’ crop health. "
              "Our advanced technology analyzes leaf conditions and provides instant diagnosis with "
              "treatment recommendations.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // How to Use Section
            _buildSectionTitle("Cara Menggunakan", primaryColor),
            const SizedBox(height: 8),
            _buildStep(Icons.camera_alt, "Step 1", "Take a photo of the melon leaf with the camera"),
            _buildStep(Icons.hourglass_empty, "Step 2", "Wait for the AI detection results"),
            _buildStep(Icons.medical_services, "Step 3", "Follow the treatment suggestions that appear"),
            const SizedBox(height: 20),

            // Key Features Section
            _buildSectionTitle("Key Features", primaryColor),
            const SizedBox(height: 8),
            _buildFeature(Icons.bolt, "Real-time disease detection"),
            _buildFeature(Icons.medical_information, "Treatment recommendations"),
            _buildFeature(Icons.history, "History tracking"),
            _buildFeature(Icons.wifi_off, "Offline functionality"),
            const SizedBox(height: 20),

            // Contact & Support Section
            _buildSectionTitle("Contact & Support", primaryColor),
            const SizedBox(height: 8),
            const Text(
              "Contact the development team for further assistance. We’re here to help "
              "you get the most out of your melon disease detection app.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Tambahkan aksi untuk tombol Contact Us
                },
                child: const Text("Contact Us", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),

            // App Information Section
            _buildSectionTitle("App Information", primaryColor),
            const SizedBox(height: 8),
            _buildInfoRow("Version", "1.2.0"),
            _buildInfoRow("Size", "45.2 MB"),
            _buildInfoRow("Last Updated", "November 15, 2025"),
            _buildInfoRow("Developer", "AgriTech Solutions"),
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

  Widget _buildStep(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal[700]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(feature)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
