import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_camera/flutter_camera.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/face_controller.dart';

class FaceRegistrationScreen extends StatelessWidget {
  final FaceController faceController = Get.put(FaceController());
  final TextEditingController nikController = TextEditingController(); // NIK input controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register Face")),
      body: Obx(() {
        if (!faceController.isCameraPermissionGranted.value) {
          return Center(child: Text("Camera permission is required."));
        }

        return Column(
          children: [
            // 🔹 TextField for NIK Input
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: nikController,
                decoration: InputDecoration(
                  labelText: "Enter Employee NIK",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // 🔹 Camera Preview
            Expanded(
              child: Stack(
                children: [
                  FlutterCamera(
                    color: Colors.black,
                    onImageCaptured: (XFile file) {
                      if (nikController.text.isEmpty) {
                        Get.snackbar("Error", "Please enter NIK before capturing.");
                        return;
                      }
                      faceController.onImageCaptured(file.path, nikController.text); // Pass NIK
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

            // 🔹 Show Captured Image
            Obx(() => faceController.capturedImagePath.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Image.file(
                          File(faceController.capturedImagePath.value),
                          height: 150,
                        ),
                        Text("Face Captured for NIK: ${faceController.enteredNIK.value}"),
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
