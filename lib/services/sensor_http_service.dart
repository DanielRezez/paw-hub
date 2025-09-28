import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sensor_data.dart'; // Ajuste o caminho se necessário

class SensorHttpService {
  // TODO: Substitua pela URL base da sua API
  final String _baseUrl = 'YOUR_API_BASE_URL_HERE';

  Future<SensorData> fetchSensorData() async {
    // TODO: Substitua 'endpoint_sensores' pelo endpoint real da sua API
    final response = await http.get(Uri.parse('$_baseUrl/endpoint_sensores'));

    if (response.statusCode == 200) {
      // Se o servidor retornar uma resposta OK, parse o JSON.
      // Supondo que a API retorna um único objeto SensorData
      return SensorData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // Se o servidor não retornar uma resposta OK,
      // lance uma exceção.
      throw Exception('Falha ao carregar dados dos sensores');
    }
  }

  // Você pode adicionar outros métodos aqui conforme necessário,
  // por exemplo, para enviar configurações para os sensores, etc.
}
