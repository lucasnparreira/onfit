import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onfit/databasehelper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_calendar/table_calendar.dart';

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