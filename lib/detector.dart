import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart'; 
import 'package:google_generative_ai/google_generative_ai.dart';
import 'hasil_page.dart'; // Import HasilPage

// --- PENTING: GANTI DENGAN API KEY ANDA ---
const apiKey = "AIzaSyDhmVv9E88sPBeYB3mem28yUPVg_EnrDHw"; 

// Asumsi: cameras diinisialisasi di main/sebelum navigasi
late List<CameraDescription> cameras;

class DetectorPage extends StatefulWidget {
  const DetectorPage({super.key});

  @override
  State<DetectorPage> createState() => _DetectorPageState();
}

class _DetectorPageState extends State<DetectorPage> with WidgetsBindingObserver {
  File? _image; // Gambar yang sedang dipratinjau
  final ImagePicker _picker = ImagePicker();
  
  // Camera & Gemini State
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isAnalyzing = false; // Status untuk loading saat AI bekerja
  final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey); // Model Gemini

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  // --- 1. Inisialisasi Kamera ---
  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      final CameraDescription backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium, 
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } on CameraException catch (e) {
      print("Camera Error: $e");
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }
  
  // --- 2. Fungsi Deteksi Gemini & Navigasi (Dipanggil oleh Tombol Diagnosa) ---
  Future<void> _performDetection() async {
    if (_image == null || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      const String prompt = 
          "Identifikasi penyakit pada daun ini (melon/tanaman terkait). Jelaskan gejalanya, penyebabnya, dan berikan saran penanganan/pencegahan secara detail dan terstruktur. Gunakan Bahasa Indonesia.";

      final Uint8List bytes = await _image!.readAsBytes();
      final String fileExtension = _image!.path.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (fileExtension == 'png') {
        mimeType = 'image/png';
      }
      
      final List<Part> parts = [
        TextPart(prompt),
        DataPart(mimeType, bytes),
      ];
      
      final content = Content.multi(parts);
      
      // Panggil Gemini API
      final response = await model.generateContent([content]);
      final geminiResultText = response.text ?? "Maaf, diagnosis gagal mendapatkan respon.";
      
      // Navigasi ke Halaman Hasil
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HasilPage(
              result: DetectionResult(rawGeminiOutput: geminiResultText),
            ),
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error Deteksi AI: $e")),
        );
      }
    } finally {
      setState(() {
        _isAnalyzing = false;

        
        _image = null; // Hapus preview setelah navigasi
      });
    }
  }


  // --- 3. Ambil Gambar (Kamera) - Hanya untuk Preview ---
  Future<void> _takePhoto() async {
    if (!_isCameraInitialized || _cameraController == null || _cameraController!.value.isTakingPicture || _isAnalyzing) {
      return;
    }

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      // Hanya update state untuk menampilkan preview, tidak langsung deteksi
      setState(() {
        _image = File(imageFile.path);
      });
    } catch (e) {
      print(e);
    }
  }

  // --- 4. Ambil Gambar (Galeri) - Hanya untuk Preview ---
  Future<void> _pickFromGallery() async {
    if (_isAnalyzing) return;
    
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Hanya update state untuk menampilkan preview, tidak langsung deteksi
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // --- 5. Widget Build ---
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF064E3B);
    final w = MediaQuery.of(context).size.width;
    final circleSize = w * 0.55;

    // Tampilkan Indikator Loading di tengah
    if (_isAnalyzing) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text("Detektor Daun Melon", style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryColor),
              SizedBox(height: 12),
              Text("Menganalisis daun dengan AI...", style: TextStyle(fontSize: 15, color: primaryColor)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Detektor Daun Melon",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Text(
              "Deteksi penyakit daun melon secara cepat dengan AI.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Bagian Stack untuk Kamera Transparan
            Stack(
              alignment: Alignment.topCenter,
              children: [
                // 1. Tampilan Kamera (Clipped to the circle)
                if (_isCameraInitialized && _cameraController != null)
                  ClipOval(
                    child: SizedBox(
                      width: circleSize,
                      height: circleSize,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: circleSize,
                          height: circleSize / _cameraController!.value.aspectRatio,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    ),
                  )
                else
                  // Placeholder saat kamera loading/gagal
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.camera_alt_rounded, size: 42, color: Colors.white),
                    ),
                  ),

                // 2. Button Overlay (Icon, Text, dan GestureDetector)
                GestureDetector(
                  onTap: _takePhoto, // Hanya memanggil fungsi ambil foto (preview)
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.4), 
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.camera_alt_rounded,
                            size: 42, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          "Ambil Gambar",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Tombol upload dari galeri
            SizedBox(
              width: w * 0.65,
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery, // Hanya memanggil fungsi pilih gambar (preview)
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryColor),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.image, color: primaryColor),
                label: const Text(
                  "Unggah Dari Galeri",
                  style: TextStyle(color: primaryColor, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Preview hasil gambar & Tombol Diagnosa
            if (_image != null) ...[
              const Text(
                "Hasil Gambar:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _image!,
                  width: w * 0.8,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              // --- Tombol Diagnosa Baru ---
              SizedBox(
                width: w * 0.65,
                child: ElevatedButton.icon(
                  onPressed: _performDetection, // Panggil fungsi deteksi AI
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.psychology, color: Colors.white),
                  label: const Text(
                    "DIAGNOSA SEKARANG",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // --------------------------
              const SizedBox(height: 28),
            ],

            // Key Features (tanpa "Instant Results")
            _buildSectionTitle("Key Features", primaryColor),
            const SizedBox(height: 8),
            // _featureCard(Icons.bolt, "Instant Results", "Get disease analysis in seconds"), // Dihapus
            _featureCard(Icons.auto_awesome, "AI Powered",
                "Advanced machine learning detection"),
            _featureCard(Icons.healing, "Treatment Tips",
                "Get care suggestions for healthy leaves"),

            const SizedBox(height: 20),
            _buildSectionTitle("Tips", primaryColor),
            const SizedBox(height: 8),
            const Text(
              "Pastikan daunnya fokus dan terang benderang untuk hasil yang lebih akurat.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ... (Helper methods _buildSectionTitle dan _featureCard tetap sama)
  Widget _buildSectionTitle(String title, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade50,
          child: Icon(icon, color: const Color(0xFF064E3B)),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}