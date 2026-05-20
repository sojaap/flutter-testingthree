import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  bool _isFallback = false;
  final List<Map<String, dynamic>> _fallbackStudents = [];
  int _fallbackIdCounter = 1;

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (_isFallback) return null;
    if (_database != null) return _database!;
    try {
      if (kIsWeb) {
        _isFallback = true;
        return null;
      }
      _database = await _initDB('students_v2.db'); // Changed filename to cleanly create new schema
      return _database;
    } catch (e) {
      debugPrint("SQLite initialization failed, switching to in-memory fallback: $e");
      _isFallback = true;
      return null;
    }
  }

  Future<Database> _initDB(String fileName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, fileName);
    return sqlite3.open(path);
  }

  Future<void> createTables(Database? db) async {
    // If fallback is enabled or database is null, load some initial mock students
    if (_isFallback || db == null) {
      if (_fallbackStudents.isEmpty) {
        _fallbackStudents.addAll([
          {
            'id': 1,
            'nama': 'Sakahayu Pribadi',
            'tempat_tanggal_lahir': 'Depok, 27 Januari 2004',
            'jenis_kelamin': 'Laki-laki',
            'alamat': 'Bogor',
            'agama': 'Islam',
            'pendidikan': 'S1 Teknik Informatika',
            'nomor_hp': '081242109841',
            'email': 'saka@gmail.com',
          },
          {
            'id': 2,
            'nama': 'Soja Purnamasari',
            'tempat_tanggal_lahir': 'Jakarta, 15 Maret 2005',
            'jenis_kelamin': 'Perempuan',
            'alamat': 'Depok',
            'agama': 'Islam',
            'pendidikan': 'S1 Sistem Informasi',
            'nomor_hp': '081234567890',
            'email': 'soja.purnamasari@mhs.ac.id',
          }
        ]);
        _fallbackIdCounter = 3;
      }
      return;
    }

    try {
      db.execute('''
        CREATE TABLE IF NOT EXISTS students (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          tempat_tanggal_lahir TEXT,
          jenis_kelamin TEXT,
          alamat TEXT,
          agama TEXT,
          pendidikan TEXT,
          nomor_hp TEXT,
          email TEXT
        )
      ''');
    } catch (e) {
      debugPrint("Error creating SQLite tables, switching to fallback: $e");
      _isFallback = true;
      await createTables(null);
    }
  }

  Future<void> insertStudent(Map<String, dynamic> student) async {
    final db = await database;
    if (_isFallback || db == null) {
      final newStudent = Map<String, dynamic>.from(student);
      newStudent['id'] = _fallbackIdCounter++;
      _fallbackStudents.add(newStudent);
      return;
    }

    try {
      db.execute('''
        INSERT INTO students (nama, tempat_tanggal_lahir, jenis_kelamin, alamat, agama, pendidikan, nomor_hp, email) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        student['nama'], 
        student['tempat_tanggal_lahir'], 
        student['jenis_kelamin'], 
        student['alamat'], 
        student['agama'], 
        student['pendidikan'], 
        student['nomor_hp'], 
        student['email']
      ]);
    } catch (e) {
      debugPrint("SQLite insert failed, falling back: $e");
      _isFallback = true;
      await insertStudent(student);
    }
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    if (_isFallback || db == null) {
      return List<Map<String, dynamic>>.from(_fallbackStudents);
    }

    try {
      final result = db.select('SELECT * FROM students');
      return result.map((row) => {
        'id': row['id'],
        'nama': row['nama'],
        'tempat_tanggal_lahir': row['tempat_tanggal_lahir'],
        'jenis_kelamin': row['jenis_kelamin'],
        'alamat': row['alamat'],
        'agama': row['agama'],
        'pendidikan': row['pendidikan'],
        'nomor_hp': row['nomor_hp'],
        'email': row['email']
      }).toList();
    } catch (e) {
      debugPrint("SQLite select failed, falling back: $e");
      _isFallback = true;
      return getStudents();
    }
  }

  Future<void> updateStudent(Map<String, dynamic> student) async {
    final db = await database;
    if (_isFallback || db == null) {
      final idx = _fallbackStudents.indexWhere((element) => element['id'] == student['id']);
      if (idx != -1) {
        _fallbackStudents[idx] = Map<String, dynamic>.from(student);
      } else {
        _fallbackStudents.add(Map<String, dynamic>.from(student));
      }
      return;
    }

    try {
      db.execute('''
        UPDATE students SET 
          nama = ?, 
          tempat_tanggal_lahir = ?, 
          jenis_kelamin = ?, 
          alamat = ?, 
          agama = ?, 
          pendidikan = ?, 
          nomor_hp = ?, 
          email = ? 
        WHERE id = ?
      ''', [
        student['nama'], 
        student['tempat_tanggal_lahir'], 
        student['jenis_kelamin'], 
        student['alamat'], 
        student['agama'], 
        student['pendidikan'], 
        student['nomor_hp'], 
        student['email'], 
        student['id']
      ]);
    } catch (e) {
      debugPrint("SQLite update failed, falling back: $e");
      _isFallback = true;
      await updateStudent(student);
    }
  }

  Future<void> deleteStudent(int id) async {
    final db = await database;
    if (_isFallback || db == null) {
      _fallbackStudents.removeWhere((element) => element['id'] == id);
      return;
    }

    try {
      db.execute('DELETE FROM students WHERE id = ?', [id]);
    } catch (e) {
      debugPrint("SQLite delete failed, falling back: $e");
      _isFallback = true;
      await deleteStudent(id);
    }
  }
}