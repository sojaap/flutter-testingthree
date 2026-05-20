import 'package:flutter/material.dart';
import 'main_page.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    await dbHelper.createTables(db);
  } catch (e) {
    debugPrint("Database initialization failed: $e");
  }

  runApp(const MyApp()); // Tambahkan const
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Tambahkan parameter key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0061FF),
          primary: const Color(0xFF0061FF),
          surface: const Color(0xFFF1F5F9),
        ),
      ),
      home: const MainPage(), // Tambahkan const
    );
  }
}
