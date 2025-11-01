/// Informações sobre o console conectado
class ConsoleInfo {
  final String ipAddress;
  final int port;
  final String model; // 'M32' ou 'X32'
  final bool isConnected;

  ConsoleInfo({
    required this.ipAddress,
    this.port = 10023,
    this.model = 'M32',
    this.isConnected = false,
  });

  ConsoleInfo copyWith({
    String? ipAddress,
    int? port,
    String? model,
    bool? isConnected,
  }) {
    return ConsoleInfo(
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      model: model ?? this.model,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

