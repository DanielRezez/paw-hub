import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../services/sensor_http_service.dart';

class SensorViewModel extends ChangeNotifier {
  final SensorHttpService _sensorHttpService = SensorHttpService();

  SensorData? _sensorData;
  SensorData? get sensorData => _sensorData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSensorData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sensorData = await _sensorHttpService.fetchSensorData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
