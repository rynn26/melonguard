import 'package:flutter/material.dart';

// Kelas untuk membawa hasil dari Gemini
class DetectionResult {
  final String rawGeminiOutput;
  // Anda bisa menambahkan properti lain di sini jika Anda ingin mem-parsing hasil AI

  DetectionResult({required this.rawGeminiOutput});
}

class HasilPage extends StatelessWidget {
  final DetectionResult result;

  const HasilPage({super.key, required this.result});

  // Helper untuk memformat output Gemini agar mudah dibaca
  // Ini adalah pendekatan sederhana. Untuk hasil yang lebih terstruktur,
  // Anda harus menggunakan response schema (JSON) atau parsing yang lebih canggih.
  String _formatGeminiOutput(String text) {
    // Ganti newline dengan dua newline untuk paragraf di UI
    text = text.replaceAll('\n', '\n\n');
    // Hilangkan spasi berlebih
    text = text.trim();
    return text;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF064E3B);
    final formattedResult = _formatGeminiOutput(result.rawGeminiOutput);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Hasil Deteksi", // Ganti ke Bahasa Indonesia
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Diagnosa AI", primaryColor),
            const SizedBox(height: 12),
            
            // --- Menampilkan Output Gemini Mentah ---
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Analisis dari Model Gemini 2.5 Flash:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const Divider(height: 20),
                    // Tampilkan hasil teks yang diformat
                    Text(
                      formattedResult,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            // ----------------------------------------
            
            const SizedBox(height: 20),
            _buildSectionTitle("Catatan", primaryColor),
            const SizedBox(height: 8),
            const Text(
              "Hasil ini dihasilkan oleh model AI dan harus digunakan sebagai referensi. Konsultasikan dengan ahli pertanian untuk konfirmasi.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods tetap sama
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
}

// Hapus widget _buildResultCard, _buildStep, dan konten lama karena sudah diganti
// dengan tampilan hasil Gemini mentah.
// (Tidak perlu menyertakan kode yang dihapus di sini, hanya sebagai catatan)