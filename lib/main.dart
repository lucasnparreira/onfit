import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as thePath;
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('exercises_v4.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = thePath.join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        weight INTEGER,
        reps INTEGER,
        sets INTEGER,
        date TEXT
      )
    ''');

    await db.execute(''' 
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        weight INTEGER,
        goal TEXT
      )
    ''');
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Padding(
        padding: EdgeInsets.only(top: 25.0),
        child: Text(
          "onFit - acompanhando seus treinos",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      centerTitle: true,
      toolbarHeight: 70, 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddExerciseScreen()),
                );
              },
              child: Text("Adicionar Exercício",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
              child: Text("Histórico",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Text("Perfil",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: 20),
            ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WeightProgressScreen()),
              );
            },
            child: Text("Evolução do Peso",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
          ),
          ],
        ),
      ),
    );
  }
}

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController setsController = TextEditingController();

  Future<void> _saveExercise() async {
    // Get the context at the start of the async operation
    final BuildContext currentContext = context;
    
    final name = nameController.text;
    final weight = int.tryParse(weightController.text) ?? 0;
    final reps = int.tryParse(repsController.text) ?? 0;
    final sets = int.tryParse(setsController.text) ?? 0;
    final date = DateTime.now().toIso8601String();

    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o nome do exercício')),
      );
      return;
    }

    try {
      await DatabaseHelper.instance.insertExercise({
        'name': name,
        'weight': weight,
        'reps': reps,
        'sets': sets,
        'date': date,
      });

      if (!mounted) return;
      Navigator.of(currentContext).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar Exercício")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nome do Exercício"),
            ),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: "Carga (kg)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: repsController,
              decoration: const InputDecoration(labelText: "Repetições"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: setsController,
              decoration: const InputDecoration(labelText: "Séries"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveExercise,
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late ValueNotifier<List<Map<String, dynamic>>> _selectedExercises;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  late TextEditingController _editNameController;
  late TextEditingController _editWeightController;
  late TextEditingController _editRepsController;
  late TextEditingController _editSetsController;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _selectedExercises = ValueNotifier([]);
    _editNameController = TextEditingController();
    _editWeightController = TextEditingController();
    _editRepsController = TextEditingController();
    _editSetsController = TextEditingController();
    _loadExercisesForSelectedDay();
  }

  Future<void> _loadExercisesForSelectedDay() async {
    final exercises = await DatabaseHelper.instance.getExercisesForDate(
      _selectedDay.toIso8601String().substring(0, 10), 
    );
    _selectedExercises.value = exercises;
  }

  Future<void> _deleteExercise(int id) async {
    await DatabaseHelper.instance.deleteExercise(id);
    _loadExercisesForSelectedDay(); 
  }

 Future<void> _editExercise(Map<String, dynamic> exercise) async {
  // Get the context at the start
  final BuildContext currentContext = context;
  
  _editNameController.text = exercise['name'];
  _editWeightController.text = exercise['weight'].toString();
  _editRepsController.text = exercise['reps'].toString();
  _editSetsController.text = exercise['sets'].toString();

  try {
    final result = await showDialog<bool>(
      context: currentContext,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text("Editar Exercício"),
        content: Column(
          children: [
            TextField(
              controller: _editNameController,
              decoration: const InputDecoration(labelText: "Nome do Exercício"),
            ),
            TextField(
              controller: _editWeightController,
              decoration: const InputDecoration(labelText: "Peso (kg)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _editRepsController,
              decoration: const InputDecoration(labelText: "Repetições"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _editSetsController,
              decoration: const InputDecoration(labelText: "Séries"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Salvar"),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final updatedExercise = {
        'id': exercise['id'],
        'name': _editNameController.text,
        'weight': int.tryParse(_editWeightController.text) ?? 0,
        'reps': int.tryParse(_editRepsController.text) ?? 0,
        'sets': int.tryParse(_editSetsController.text) ?? 0,
        'date': exercise['date'],
      };
      await DatabaseHelper.instance.updateExercise(updatedExercise);
      _loadExercisesForSelectedDay();
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(currentContext).showSnackBar(
      SnackBar(content: Text('Erro ao editar: ${e.toString()}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Histórico de Treinos")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2101, 1, 1),
            focusedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              _loadExercisesForSelectedDay();
            },
          ),
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _selectedExercises,
              builder: (context, exercises, child) {
                return exercises.isEmpty
                    ? Center(child: Text("Nenhum exercício registrado neste dia"))
                    : ListView.builder(
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];
                          return ListTile(
                            title: Text(exercise['name']),
                            subtitle: Text('Peso: ${exercise['weight']} kg, Reps: ${exercise['reps']}'),
                            trailing: Row(
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Séries: ${exercise['sets']}'),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editExercise(exercise),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteExercise(exercise['id']),
                                ),
                              ],
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await DatabaseHelper.instance.getProfile();
    if (profile != null) {
      setState(() {
        _usernameController.text = profile['username'];
        _weightController.text = profile['weight'].toString();
        _goalController.text = profile['goal']?.toString() ?? '';
      });
    }
  }

  Future<void> _saveProfile() async {
    final username = _usernameController.text;
    final weight = _weightController.text;
    final goal = _goalController.text;
    
    if (username.isNotEmpty) {
      await DatabaseHelper.instance.saveProfile(username, weight, goal);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil salvo com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Perfil")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Nome do Usuário"),
            ),
             TextField(
              controller: _weightController,
              decoration: InputDecoration(labelText: "Peso do Usuário"),
            ),
            TextField(
              controller: _goalController,
              decoration: InputDecoration(labelText: "Meta de Atividade Física"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}

class WeightProgressScreen extends StatefulWidget {
  const WeightProgressScreen({super.key});

  @override
  _WeightProgressScreenState createState() => _WeightProgressScreenState();
}

class _WeightProgressScreenState extends State<WeightProgressScreen> {
  List<Map<String, dynamic>> _weightData = [];

  @override
  void initState() {
    super.initState();
    _loadWeightData();
  }

  Future<void> _loadWeightData() async {
    final dbHelper = DatabaseHelper.instance;
    final profile = await dbHelper.getProfile();

    if (profile != null) {
      setState(() {
        _weightData = [
          {'date': DateTime.now().subtract(Duration(days: 30)), 'weight': profile['weight'] - 3},
          {'date': DateTime.now().subtract(Duration(days: 20)), 'weight': profile['weight'] - 2},
          {'date': DateTime.now().subtract(Duration(days: 10)), 'weight': profile['weight'] - 1},
          {'date': DateTime.now(), 'weight': profile['weight']},
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Evolução do Peso")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Histórico do Peso", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: _weightData.isEmpty
                  ? Center(child: Text("Nenhum dado disponível"))
                  : LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < _weightData.length) {
                                  final date = _weightData[index]['date'] as DateTime;
                                  return Text("${date.day}/${date.month}");
                                }
                                return Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _weightData.asMap().entries.map((entry) {
                              return FlSpot(entry.key.toDouble(), entry.value['weight'].toDouble());
                            }).toList(),
                            isCurved: true,
                            barWidth: 3,
                            color: Color.fromRGBO(0, 122, 255, 1.0)
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}