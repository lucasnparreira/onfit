import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as thePath;
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // scaffoldBackgroundColor: Colors.white.withOpacity(0.2)
        ),
      home: HomeScreen(),
    );
  }
}

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonWidth = screenSize.width * 0.7; 
    final buttonHeight = screenSize.height * 0.07;

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
      body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("lib/assets/images/academia.jpg"), 
          fit: BoxFit.cover, 
        ),
      ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMainButton(
                  context,
                  "Adicionar Exercício",
                  buttonWidth,
                  buttonHeight,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddExerciseScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMainButton(
                  context,
                  "Histórico",
                  buttonWidth,
                  buttonHeight,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMainButton(
                  context,
                  "Perfil",
                  buttonWidth,
                  buttonHeight,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMainButton(
                  context,
                  "Evolução do Peso",
                  buttonWidth,
                  buttonHeight,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WeightProgressScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(
    BuildContext context,
    String text,
    double width,
    double height,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
  final TextEditingController weightController = TextEditingController(text: '0');
  final TextEditingController repsController = TextEditingController(text: '0');
  final TextEditingController setsController = TextEditingController(text: '0');
  
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

  void _incrementValue(TextEditingController controller) {
    int currentValue = int.tryParse(controller.text) ?? 0;
    setState(() {
      controller.text = (currentValue + 1).toString();
    });
  }

  void _decrementValue(TextEditingController controller) {
    int currentValue = int.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      setState(() {
        controller.text = (currentValue - 1).toString();
      });
    }
  }

  Widget _buildNumberFieldWithButtons({
    required String labelText,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () => _decrementValue(controller),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: labelText),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(icon: Icon(Icons.add),
        onPressed: () => _incrementValue(controller), 
        ),
      ],
    );
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
            const SizedBox(height: 16),
            _buildNumberFieldWithButtons(
              controller: weightController,
              labelText: "Carga (kg)",
            ),
            const SizedBox(height: 16),
            _buildNumberFieldWithButtons(
              controller: repsController,
              labelText: "Repetições",
            ),
            const SizedBox(height: 16),
            _buildNumberFieldWithButtons(
              controller: setsController,
             labelText: "Séries",
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

Future<void> _exportAllWorkouts() async {
  try {
    final db = await DatabaseHelper.instance.database;
    final allExercises = await db.query('exercises', orderBy: 'date DESC');

    if (allExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum treino encontrado para exportar')),
      );
      return;
    }

    StringBuffer exportContent = StringBuffer();
    exportContent.writeln('Histórico Completo de Treinos - onFit\n');
    exportContent.writeln('Total de treinos registrados: ${allExercises.length}\n');

    String currentDate = '';
    for (var exercise in allExercises) {
      final exerciseDate = DateTime.parse(exercise['date'] as String);
      final formattedDate = DateFormat('dd/MM/yyyy').format(exerciseDate);

      if (formattedDate != currentDate) {
        currentDate = formattedDate;
        exportContent.writeln('\n=== $formattedDate ===\n');
      }

        exportContent.writeln('Exercício: ${exercise['name']}');
        exportContent.writeln('Carga: ${exercise['weight']} kg');
        exportContent.writeln('Repetições: ${exercise['reps']}');
        exportContent.writeln('Séries: ${exercise['sets']}');
        exportContent.writeln('---');
      }

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/onfit_workouts${DateFormat('yyyyMMdd').format(DateTime.now())}.txt');
      await file.writeAsString(exportContent.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Meu histórico completo de treinos do onFit',
        subject: 'Histórico de Treinos onFit',
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Histórico de Treinos"),
      actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _exportAllWorkouts,
            tooltip: 'Exportar todos os treinos',
          ),
        ],
      ),      
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
                            subtitle: Text('Peso: ${exercise['weight']} kg, Reps: ${exercise['reps']}, Séries: ${exercise['sets']}'),
                            trailing: Row(
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
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

class CalorieTracker {
  double _caloriesBurned = 0;
  double _userWeight;
  DateTime? _lastActivity;
  bool _isActive = false;
  DateTime? _lastUpdate;
  String _currentActivity = 'Geral';
  double get caloriesBurned => _caloriesBurned;
  String get currentActivity => _currentActivity;
  String _nextActivity = 'Geral';
  DateTime? _startTime;
  int _durationSeconds = 0;

  // MET values for different activities
  final Map<String, double> _metValues = {
    'Geral': 3.5,
    'Caminhada': 4.3,
    'Corrida': 7.0,
    'Ciclismo': 6.0,
    'Musculação': 5.0,
  };

  CalorieTracker({required double initialWeight}) : _userWeight = initialWeight;

  void updateWeight(double newWeight) {
    _userWeight = newWeight;
  }

  void startActivity([String? activity]) {
    _isActive = true;
    _currentActivity = activity ?? _nextActivity;
    _startTime = DateTime.now();
    _lastUpdate = _startTime;
  }

  Future<void> endActivity() async {
    if (_isActive && _lastUpdate != null) {
      final endTime = DateTime.now();
      _durationSeconds = endTime.difference(_startTime!).inSeconds;

      final met = _metValues[_currentActivity] ?? 3.5;
      _caloriesBurned += (met * _userWeight * _durationSeconds) / 3600;

      await DatabaseHelper.instance.logActivity(
        activityType: _currentActivity, 
        caloriesBurned: _caloriesBurned, 
        durationSeconds: _durationSeconds
        );
    }
    _isActive = false;
  }

  Future<void> initialize({required double userWeight}) async {
    _userWeight = userWeight;
    await _requestPermissions();
    _startTracking();
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      return (await Permission.activityRecognition.request()).isGranted;
    }
    return false;
  }

  void _startTracking() {
    // Simulate activity based on time
    Timer.periodic(const Duration(minutes: 1), (_) {
      if (_isActive) {
        // Basic calculation: ~5 calories per minute for light activity
        _caloriesBurned += (3.5 * _userWeight * 1.6667) / 1000; // MET formula simplified
        _caloriesBurned = double.parse(_caloriesBurned.toStringAsFixed(1));
      }
    });
  }

  void reset() {
    _caloriesBurned = 0;
    _isActive = false;
    _currentActivity = 'Geral';
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
  late CalorieTracker _calorieTracker;
  bool _isTracking = false;
  String _selectedActivity = 'Geral';

  @override
  void initState() {
    super.initState();
    _selectedActivity = 'Geral';
     _calorieTracker = CalorieTracker(initialWeight: 70.0);
    _loadProfile();
    _loadProfileCalories();
  }

  Future<void> _loadProfileCalories() async {
    final profile = await DatabaseHelper.instance.getProfile();
    if (profile != null && profile['weight'] != null) {
      final weight = double.tryParse(profile['weight'].toString()) ?? 70.0;
    
    setState(() {
        _calorieTracker.updateWeight(weight);
        _weightController.text = weight.toString();
      });
    }
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
            decoration: InputDecoration(labelText: "Peso Atual do Usuário"),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final weight = double.tryParse(value) ?? 70.0;
              _calorieTracker.updateWeight(weight);
            },
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
          // Add this card to display calories
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Calorias Queimadas",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${_calorieTracker.caloriesBurned.toStringAsFixed(1)} kcal",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _isTracking ? "Rastreando..." : "Pausado",
                    style: TextStyle(
                      color: _isTracking ? Colors.green : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Add this reset button
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _calorieTracker.reset();
                        _isTracking = false;
                      });
                    },
                    icon: Icon(Icons.refresh),
                    label: Text("Reiniciar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _showActivityHistory,
                    child: Text('Ver Histórico Completo'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                   ),
                  ),
                ],
              ),
            ),
          ),
          DropdownButton<String>(
            value: _selectedActivity,
            items: const [
              DropdownMenuItem(value: 'Geral', child: Text("Atividade Geral")),
              DropdownMenuItem(value: 'Caminhada', child: Text("Caminhada")),
              DropdownMenuItem(value: 'Corrida', child: Text("Corrida")),
              DropdownMenuItem(value: 'Ciclismo', child: Text("Ciclismo")),
              DropdownMenuItem(value: 'Musculação', child: Text("Musculação")),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedActivity = newValue;
                  if (_isTracking) {
                    // If currently tracking, update the current activity
                    _calorieTracker.endActivity();
                    _calorieTracker.startActivity(newValue);
                  }
                });
              }
            },
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        setState(() {
          _isTracking = !_isTracking;
          if (_isTracking) {
            _calorieTracker.startActivity(_selectedActivity);
          } else {
            _calorieTracker.endActivity().then((_) {
              if (mounted) setState(() {});
            });
          }
        });
      },
      child: Icon(_isTracking ? Icons.pause : Icons.play_arrow),
      backgroundColor: _isTracking ? Colors.red : Colors.blue,
    ),
  );
 }

void _showActivityHistory() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows full screen expansion
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Histórico de Atividades',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: _buildActivityHistoryList(),
            ),
          ],
        ),
      );
    },
  );
}
}

Widget _buildActivityHistoryList() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: DatabaseHelper.instance.getActivityHistory(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text("Nenhuma atividade registrada ainda"));
      }
      
      final logs = snapshot.data!;
      return ListView.separated(
        itemCount: logs.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final log = logs[index];
          final duration = Duration(seconds: log['duration_seconds'] as int);
          final date = DateTime.parse(log['date']);
          
          return ListTile(
            title: Text(
              log['activity_type'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${log['calories_burned'].toStringAsFixed(1)} kcal'),
                Text('Duração: ${duration.inMinutes} minutos'),
              ],
            ),
            trailing: Text(
              DateFormat('dd/MM/yy').format(date),
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
      );
    },
  );
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
                            curveSmoothness: 0.3,
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