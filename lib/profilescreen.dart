import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onfit/calorietracker.dart';
import 'package:onfit/databasehelper.dart';

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
          SizedBox(height: 20),
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