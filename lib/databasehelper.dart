import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as thePath;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  // Table names
  static const String tableExercises = 'exercises';
  static const String tableProfile = 'profile';
  static const String tableActivityLogs = 'activity_logs';
  
  // Activity logs columns
  static const String colActivityType = 'activity_type';
  static const String colCaloriesBurned = 'calories_burned';
  static const String colDurationSeconds = 'duration_seconds';
  static const String colDate = 'date';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('exercises_v9.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = thePath.join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB); // Version increased to 2
  }

  Future _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE $tableExercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        weight INTEGER,
        reps INTEGER,
        sets INTEGER,
        date TEXT
      )
    ''');

    await db.execute(''' 
      CREATE TABLE $tableProfile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        weight INTEGER,
        goal TEXT
      )
    ''');

    await db.execute(''' 
      CREATE TABLE $tableActivityLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        $colActivityType TEXT,
        $colCaloriesBurned REAL,
        $colDurationSeconds INTEGER,
        $colDate TEXT
      )
    ''');
  }

  Future<int> logActivity({
    required String activityType,
    required double caloriesBurned,
    required int durationSeconds,
  }) async {
    final db = await database;
    return await db.insert(tableActivityLogs, {
      colActivityType: activityType,
      colCaloriesBurned: caloriesBurned,
      colDurationSeconds: durationSeconds,
      colDate: DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getActivityHistory() async {
    final db = await database;
    return await db.query(
      tableActivityLogs, // Fixed table name
      orderBy: '$colDate DESC',
    );
  }

  // Método para inserir um exercício
  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    final db = await instance.database;
    return await db.insert('exercises', exercise);
  }

  // Método para atualizar um exercício
  Future<int> updateExercise(Map<String, dynamic> exercise) async {
    final db = await instance.database;
    return await db.update(
      'exercises',
      exercise,
      where: 'id = ?',
      whereArgs: [exercise['id']],
    );
  }

  // Método para excluir um exercício
  Future<int> deleteExercise(int id) async {
    final db = await instance.database;
    return await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método para buscar exercícios de uma data específica
  Future<List<Map<String, dynamic>>> getExercisesForDate(String date) async {
    final db = await instance.database;
    return await db.query(
      'exercises',
      where: 'date LIKE ?',
      whereArgs: ['%$date%'],
      orderBy: 'date DESC',
    );
  }

  // Método para inserir ou atualizar o perfil
Future<void> saveProfile(String username, String weight, String goal) async {
  final db = await instance.database;
  await db.insert(
    'profile',
    {'id': 1, 'username': username, 'weight':weight,'goal': goal},
    conflictAlgorithm: ConflictAlgorithm.replace, 
  );
}

// Método para obter o perfil do usuário
Future<Map<String, dynamic>?> getProfile() async {
  final db = await instance.database;
  final result = await db.query('profile', where: 'id = ?', whereArgs: [1]);

  if (result.isNotEmpty) {
    return result.first;
  }
  return null;
}

}