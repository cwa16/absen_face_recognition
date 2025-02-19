import 'package:absen/services/facenet_service.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:async';
import '../services/face_service.dart';
import '../services/local_db_service.dart';

class AttendanceController extends GetxController {
  var isCameraPermissionGranted = true.obs;
  var attendanceStatus = "".obs;
  var matchedFacePath = "".obs;
  var isProcessing = false.obs; // Prevent multiple detections

  final FaceService faceService = FaceService();
  final FaceNetService faceNetService = FaceNetService();

  @override
  void onInit() {
    super.onInit();
    _startAutoScan();
  }

  void _startAutoScan() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      if (!isProcessing.value) {
        isProcessing.value = true;
        await _captureAndProcess();
        isProcessing.value = false;
      }
    });
  }

  Future<void> _captureAndProcess() async {
    final String imagePath = await _captureImage();
    if (imagePath.isNotEmpty) {
      await processAttendance(imagePath);
    }
  }

  Future<String> _captureImage() async {
    try {
      // Simulate capturing an image automatically (adjust based on your camera implementation)
      File file = await FaceService.captureImage();
      return file.path;
    } catch (e) {
      return "";
    }
  }

  Future<void> processAttendance(String imagePath) async {
    attendanceStatus.value = "Processing...";
    final File file = File(imagePath);

    // Extract face embedding (instead of bounding box)
    final List<double> detectedEmbedding =
        await faceNetService.extractFaceEmbedding(file);

    if (detectedEmbedding.isNotEmpty) {
      // Match face with database
      String? matchedNIK =
          await LocalDBService.findEmployeeByFace(detectedEmbedding);
      if (matchedNIK != null) {
        matchedFacePath.value = imagePath; // Store matched face image
        await LocalDBService.markAttendance(matchedNIK);
        attendanceStatus.value = "Attendance Recorded for NIK: $matchedNIK ✅";
        Get.snackbar("Success", "Attendance Recorded for NIK: $matchedNIK ✅");
      } else {
        attendanceStatus.value = "Face Not Recognized ❌";
        Get.snackbar("Error", "Face Not Recognized ❌");
      }
    } else {
      attendanceStatus.value = "No Face Detected!";
       Get.snackbar("Error", "No Face Detected!");
    }
  }
}
