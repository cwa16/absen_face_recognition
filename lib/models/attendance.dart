class Attendance {
  final int id;
  final String nik;
  final String timestamp;

  Attendance({required this.id, required this.nik, required this.timestamp});

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      nik: map['nik'],
      timestamp: map['timestamp'],
    );
  }
}