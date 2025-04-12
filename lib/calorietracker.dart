import 'dart:async';
import 'dart:io';

import 'package:onfit/databasehelper.dart';
import 'package:permission_handler/permission_handler.dart';

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