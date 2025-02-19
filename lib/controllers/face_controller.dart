import 'dart:math';
import 'dart:typed_data';

import 'package:absen/services/facenet_service.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import '../services/face_service.dart';
import '../services/local_db_service.dart';

class FaceController extends GetxController {
  var isCameraPermissionGranted = true.obs;
  var capturedImagePath = "".obs;
  var enteredNIK = "".obs; // Store NIK input
  final FaceService faceService = FaceService();
  final FaceNetService faceNetService = FaceNetService();

  Future<void> onImageCaptured(String imagePath, String nik) async {
    capturedImagePath.value = imagePath;
    enteredNIK.value = nik;

    final File file = File(imagePath);
    final List<double> newEmbedding =
        await faceNetService.extractFaceEmbedding(file);

    if (newEmbedding.isNotEmpty) {
      List<double> storedEmbedding =
          await LocalDBService.getEmployeeEmbedding(nik);

      if (storedEmbedding.isNotEmpty) {
        double similarity = cosineSimilarity(storedEmbedding, newEmbedding);
        if (similarity > 0.6) {
          Get.snackbar("Success", "Face recognized!");
        } else {
          Get.snackbar("Error", "Face not recognized!");
        }
      } else {
        await LocalDBService.insertEmployee(nik, newEmbedding);
        Get.snackbar("Success", "Face registered for NIK: $nik!");
      }
    } else {
      Get.snackbar("Error", "No face detected!");
    }
  }

  Future<void> onImagseCaptured(String imagePath, String text) async {
    print("📷 Image Captured: $imagePath");

    // Load image file
    final File file = File(imagePath);
    final img.Image? image = img.decodeImage(await file.readAsBytes());

    if (image == null) {
      print("❌ Error: Could not decode image");
      return;
    }

    // Preprocess the image
    Float32List processedImage = faceNetService.preprocessImage(image);
    print(
        "🔍 Processed Image Size: ${processedImage.length}"); // Should be 160*160*3 = 76800

    // Run FaceNet model
    List<double> faceEmbedding =
        await faceNetService.runFaceNetModel(processedImage);

    if (faceEmbedding.isNotEmpty) {
      print("✅ Face Embedding: $faceEmbedding");
      Get.snackbar("Success", "Face recognized!");
    } else {
      print("❌ Face recognition failed!");
      Get.snackbar("Error", "No face detected!");
    }
  }

  double cosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) {
      throw ArgumentError(
          "Embeddings must be non-empty and of the same length");
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) {
      return 0.0; // Avoid division by zero
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}
