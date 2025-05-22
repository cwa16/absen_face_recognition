import 'package:absen/controllers/attendance_controller.dart';
import 'package:absen/views/attendance_screen.dart';
import 'package:absen/views/face_registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  final AttendanceController attendanceController =
      Get.put(AttendanceController());

  final List<MenuItem> menuItems = [
    MenuItem(icon: Icons.lock_clock, label: 'Absen Masuk'),
    MenuItem(icon: Icons.lock_clock, label: 'Absen Pulang'),
    MenuItem(icon: Icons.history, label: 'Riwayat Absen'),
    MenuItem(icon: Icons.person_add, label: 'Registrasi Wajah'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Face Recognition Attendance"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: menuItems.map((item) {
                  return GestureDetector(
                    onTap: () {
                      if (item.label == 'Absen Masuk' ||
                          item.label == 'Absen Pulang') {
                        Get.to(() => AttendanceScreen());
                      } else if (item.label == 'Registrasi Wajah') {
                        Get.to(() => FaceRegistrationScreen());
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24), // rounded-2xl
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item.icon, size: 40, color: Colors.blue),
                          const SizedBox(height: 16),
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // 🔹 Judul
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Absensi Terakhir',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),

            Obx(() {
              final data = attendanceController.attendanceList;

              if (data.isEmpty) {
                return Center(child: Text("Belum ada data absensi."));
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        MaterialStateProperty.all(Colors.grey[100]),
                    columnSpacing: 24,
                    horizontalMargin: 12,
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey.shade200),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'NIK',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Waktu',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: data.map((absen) {
                      return DataRow(
                        cells: [
                          DataCell(Text(absen.nik)),
                          DataCell(Text(absen.timestamp)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String label;

  MenuItem({required this.icon, required this.label});
}
