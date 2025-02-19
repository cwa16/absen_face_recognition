import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceService {
  late FaceDetector faceDetector;

  FaceService() {
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
          enableContours: true,
          enableClassification: true,
          performanceMode: FaceDetectorMode.accurate),
    );
  }

  Future<List<Face>> detectFaces(File imageFile) async {
    try {
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final List<Face> faces = await faceDetector.processImage(inputImage);

      print("Detected ${faces.length} face(s)");
      return faces;
    } catch (e) {
      print("Error in face detection: $e");
      return [];
    }
  }

  void dispose() {
    faceDetector.close();
  }

  static captureImage() {}
}
