import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter? _interpreter;
  late List<String> _labels;

  static const String modelPath = 'assets/model/model_melon.tflite';
  static const String labelPath = 'assets/model/labels.txt';

  late int inputSize; // 🔹 Auto dari model

  /// =======================
  /// 🔹 LOAD MODEL
  /// =======================
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      final labelData = await rootBundle.loadString(labelPath);

      _labels = labelData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      // 🔍 Ambil ukuran input dari model (misalnya 150, 224, dll)
      inputSize = inputShape.length == 4 ? inputShape[1] : inputShape[0];

      print("✅ Model berhasil dimuat (${_labels.length} kelas).");
      print("📏 Input tensor shape: $inputShape");
      print("📤 Output tensor shape: $outputShape");
    } catch (e) {
      print("❌ Error memuat model: $e");
      rethrow;
    }
  }

  /// =======================
  /// 🔹 PREPROCESS IMAGE
  /// =======================
  Float32List _preProcessImage(File imageFile) {
    final img.Image? originalImage = img.decodeImage(
      imageFile.readAsBytesSync(),
    );
    if (originalImage == null) throw Exception("Gagal decode gambar");

    final img.Image resizedImage = img.copyResize(
      originalImage,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    final Float32List floatBuffer = Float32List(inputSize * inputSize * 3);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        floatBuffer[pixelIndex++] = pixel.r / 255.0;
        floatBuffer[pixelIndex++] = pixel.g / 255.0;
        floatBuffer[pixelIndex++] = pixel.b / 255.0;
      }
    }

    return floatBuffer;
  }

  /// =======================
  /// 🔹 RUN INFERENCE
  /// =======================
  Future<String> runInference(File imageFile) async {
    if (_interpreter == null) {
      throw Exception(
        "Model belum dimuat. Jalankan loadModel() terlebih dahulu.",
      );
    }

    try {
      final Float32List inputBuffer = _preProcessImage(imageFile);
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      print("📥 Input tensor shape (dari model): $inputShape");
      print("📤 Output tensor shape (dari model): $outputShape");

      dynamic input;

      // ✅ Tangani berbagai format input
      if (inputShape.length == 4 && inputShape[1] == inputSize) {
        input = inputBuffer.reshape([1, inputSize, inputSize, 3]); // [1,H,W,3]
      } else if (inputShape.length == 3) {
        input = inputBuffer.reshape([inputSize, inputSize, 3]); // [H,W,3]
      } else if (inputShape.length == 4 && inputShape[1] == 3) {
        // [1,3,H,W]
        final img.Image resized = img.copyResize(
          img.decodeImage(imageFile.readAsBytesSync())!,
          width: inputSize,
          height: inputSize,
        );

        final Float32List channelFirst = Float32List(inputSize * inputSize * 3);
        int rIndex = 0,
            gIndex = inputSize * inputSize,
            bIndex = 2 * inputSize * inputSize;

        for (int y = 0; y < inputSize; y++) {
          for (int x = 0; x < inputSize; x++) {
            final pixel = resized.getPixel(x, y);
            channelFirst[rIndex++] = pixel.r / 255.0;
            channelFirst[gIndex++] = pixel.g / 255.0;
            channelFirst[bIndex++] = pixel.b / 255.0;
          }
        }

        input = channelFirst.reshape([1, 3, inputSize, inputSize]);
      } else {
        throw Exception("❌ Bentuk input tensor tidak dikenali: $inputShape");
      }

      final int numClasses = outputShape.last;
      final output = List.filled(numClasses, 0.0).reshape([1, numClasses]);

      // Jalankan inferensi
      _interpreter!.run(input, output);

      final results = List<double>.from(output[0]);
      double maxProb = -1;
      int maxIndex = -1;

      for (int i = 0; i < results.length; i++) {
        if (results[i] > maxProb) {
          maxProb = results[i];
          maxIndex = i;
        }
      }

      if (maxIndex != -1 && maxProb > 0.5) {
        return "🩺 Penyakit terdeteksi: ${_labels[maxIndex]}\nConfidence: ${(maxProb * 100).toStringAsFixed(2)}%";
      } else {
        return "⚠️ Tidak dapat mengidentifikasi penyakit.\nConfidence ${(maxProb * 100).toStringAsFixed(2)}% terlalu rendah.";
      }
    } catch (e) {
      print("⚠️ Error saat menjalankan inferensi: $e");
      rethrow;
    }
  }

  /// =======================
  /// 🔹 DISPOSE
  /// =======================
  void dispose() {
    try {
      _interpreter?.close();
      _interpreter = null;
    } catch (_) {}
  }
}
