import 'package:absen/controllers/attendance_controller.dart';
import 'package:absen/views/attendance_screen.dart';
import 'package:absen/views/face_registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  final AttendanceController attendanceController = Get.put(AttendanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Recognition Attendance"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(() => FaceRegistrationScreen());
              },
              child: const Text("Register Face")
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(() => AttendanceScreen());
              },
              child: const Text("Mark Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}