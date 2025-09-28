class SensorData {
  final double nivelRacao;
  final double nivelAgua;
  final DateTime timestamp;

  SensorData({
    required this.nivelRacao,
    required this.nivelAgua,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      // Corrigido aqui
      nivelRacao: (json['nivel_racao'] as num).toDouble(),
      nivelAgua: (json['nivel_agua'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // E corrigido aqui
      'nivel_racao': nivelRacao,
      'nivel_agua': nivelAgua,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
