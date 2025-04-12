import 'package:flutter/material.dart';
import 'package:onfit/databasehelper.dart';
import 'package:onfit/main.dart';
import 'package:onfit/util.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar Exercício")),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16.0 : 24.0,
          vertical: 16.0,
        ),
        child: Column(
          children: [
            _buildResponsiveTextField(
              context,
              controller: nameController,
              label: "Nome do Exercício",
            ),
            SizedBox(height: isSmallScreen ? 12.0 : 16.0),
            _buildNumberFieldWithButtons(
              controller: weightController,
              labelText: "Carga (kg)",
            ),
            SizedBox(height: isSmallScreen ? 12.0 : 16.0),
            _buildNumberFieldWithButtons(
              controller: repsController,
              labelText: "Repetições",
            ),
            SizedBox(height: isSmallScreen ? 12.0 : 16.0),
            _buildNumberFieldWithButtons(
              controller: setsController,
             labelText: "Séries",
            ),
            SizedBox(height: isSmallScreen ? 12.0 : 16.0),
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

Widget _buildResponsiveButton(BuildContext context, String text, VoidCallback onPressed) {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width * 0.7,
      height: screenSize.height * 0.07,
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
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveTextField(BuildContext context, {required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: AppText.getScaleFactor(context) * 16),
      ),
    );
  }