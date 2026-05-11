import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, fileName);
    return sqlite3.open(path);
  }

  Future<void> createTables(Database db) async {
    db.execute('''
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        major TEXT NOT NULL,
        origin TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertStudent(Map<String, dynamic> student) async {
    final db = await database;
    db.execute('''
      INSERT INTO students (name, email, major, origin) VALUES (?, ?, ?, ?)
    ''', [student['name'], student['email'], student['major'], student['origin']]);
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    final result = db.select('SELECT * FROM students');
    return result.map((row) => {
      'id': row['id'],
      'name': row['name'],
      'email': row['email'],
      'major': row['major'],
      'origin': row['origin']
    }).toList();
  }

  Future<void> updateStudent(Map<String, dynamic> student) async {
    final db = await database;
    print('Updating student with id: ${student['id']}, Type: ${student['id'].runtimeType}');
    db.execute('''
      UPDATE students SET name = ?, email = ?, major = ?, origin = ? WHERE id = ?
    ''', [student['name'], student['email'], student['major'], student['origin'], student['id']]);
    print('Updated student: $student');
  }

  Future<void> deleteStudent(int id) async {
    final db = await database;
    db.execute('DELETE FROM students WHERE id = ?', [id]);
  }
}