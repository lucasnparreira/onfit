import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:onfit/databasehelper.dart';

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