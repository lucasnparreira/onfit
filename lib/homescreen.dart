import 'package:flutter/material.dart';
import 'package:onfit/addexercisescreen.dart';
import 'package:onfit/historyscreen.dart';
import 'package:onfit/main.dart';
import 'package:onfit/_buildresponsivebutton.dart';
import 'package:onfit/profilescreen.dart';
import 'package:onfit/weightprogressscreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final buttonWidth = screenSize.width * 0.7; 
    final buttonHeight = screenSize.height * 0.07;

    return Scaffold(
      appBar: AppBar(
      title: Padding(
        padding: EdgeInsets.only(top: screenSize.height * 0.025),
        child: Text(
          "onFit - acompanhando seus treinos",
          style: TextStyle(fontSize: screenSize.width * 0.045, fontWeight: FontWeight.bold),
        ),
      ),
      centerTitle: true,
      toolbarHeight: screenSize.height * 0.1, 
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
            child:ConstrainedBox(constraints: BoxConstraints(
              maxWidth: isPortrait ? screenSize.width * 0.9 : screenSize.width * 0.6,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildResponsiveButton(
                  context,
                  "Adicionar Exercício",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddExerciseScreen()),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                _buildResponsiveButton(
                  context,
                  "Histórico",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                _buildResponsiveButton(
                  context,
                  "Perfil",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                _buildResponsiveButton(
                  context,
                  "Evolução do Peso",
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