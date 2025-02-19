import 'dart:convert';

import 'package:absen/services/facenet_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDBService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'attendance.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE employees (
          nik TEXT PRIMARY KEY,
          faceData TEXT
        );
      ''');
      await db.execute('''
        CREATE TABLE attendance (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nik TEXT,
          timestamp TEXT
        );
      ''');
    });
  }

  static Future<void> insertEmployee(String nik, List<double> faceData) async {
    final db = await database;

    String faceDataJson = jsonEncode(faceData);

    await db.insert('employees', {'nik': nik, 'faceData': faceDataJson},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // static Future<String?> findEmployeeByFace(String faceData) async {
  //   final db = await database;
  //   final result = await db.query('employees',
  //       where: 'faceData = ?', whereArgs: [faceData], limit: 1);
  //   return result.isNotEmpty ? result.first['nik'] as String : null;
  // }

  static Future<void> markAttendance(String nik) async {
    final db = await database;
    await db.insert('attendance', {
      'nik': nik,
      'timestamp': DateTime.now().toString(),
    });
  }

  static Future<List<double>> getEmployeeEmbedding(String nik) async {
    final List<Map<String, dynamic>> maps = await _database!.query(
      'employees',
      where: "nik = ?",
      whereArgs: [nik],
    );

    if (maps.isNotEmpty) {
      return maps.first['faceData']
          .split(',')
          .map((e) => double.parse(e))
          .toList();
    }
    return [];
  }

  static Future<String?> findEmployeeByFace(
      List<double> detectedEmbedding) async {
    final db = await database;
    List<Map<String, dynamic>> employees = await db.query('employees');

    for (var employee in employees) {
      List<double> storedEmbedding = (employee['faceData'] as String)
          .replaceAll('[', '') // Remove opening bracket
          .replaceAll(']', '') // Remove closing bracket
          .split(',')
          .map((e) => double.parse(e.trim())) // Trim spaces and parse
          .toList();

      if (FaceNetService.isFaceMatch(detectedEmbedding, storedEmbedding)) {
        return employee['nik']; // Return NIK if match found
      }
    }
    return null; // No match found
  }
}
