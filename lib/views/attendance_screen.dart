import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_camera/flutter_camera.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/attendance_controller.dart';

class AttendanceScreen extends StatelessWidget {
  final AttendanceController attendanceController = Get.put(AttendanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Face Attendance")),
      body: Obx(() {
        if (!attendanceController.isCameraPermissionGranted.value) {
          return Center(child: Text("Camera permission is required."));
        }

        return Column(
          children: [
            // 🔹 Camera Preview
            Expanded(
              child: Stack(
                children: [
                  FlutterCamera(
                    color: Colors.black,
                    onImageCaptured: (XFile file) {
                      attendanceController.processAttendance(file.path);
                    },
                  ),

                  // 🔹 Face Guide Box Overlay
                  Center(
                    child: Container(
                      width: 200,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  // 🔹 Instruction Text
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.black54,
                        child: Text(
                          "Align your face inside the box",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // 🔹 Display Attendance Status
            Obx(() => attendanceController.attendanceStatus.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        if (attendanceController.matchedFacePath.value.isNotEmpty)
                          Image.file(
                            File(attendanceController.matchedFacePath.value),
                            height: 150,
                          ),
                        Text(
                          attendanceController.attendanceStatus.value,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink()),
          ],
        );
      }),
    );
  }
}
