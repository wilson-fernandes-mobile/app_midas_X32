import 'dart:convert';

/// Representa um preset salvo com configurações de volumes
class Preset {
  final String id; // UUID único
  final String name; // Nome do preset
  final int mixNumber; // Número do Mix/Bus (1-16)
  final Map<int, double> channelLevels; // Map: channelNumber -> level (0.0-1.0)
  final double busLevel; // Volume do bus/mix (0.0-1.0)
  final DateTime createdAt; // Data de criação
  final DateTime updatedAt; // Data da última atualização

  Preset({
    required this.id,
    required this.name,
    required this.mixNumber,
    required this.channelLevels,
    required this.busLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria um novo preset com timestamp atual
  factory Preset.create({
    required String name,
    required int mixNumber,
    required Map<int, double> channelLevels,
    required double busLevel,
  }) {
    final now = DateTime.now();
    return Preset(
      id: _generateId(),
      name: name,
      mixNumber: mixNumber,
      channelLevels: channelLevels,
      busLevel: busLevel,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Gera um ID único simples (timestamp + random)
  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Cria uma cópia com alterações
  Preset copyWith({
    String? name,
    int? mixNumber,
    Map<int, double>? channelLevels,
    double? busLevel,
  }) {
    return Preset(
      id: id,
      name: name ?? this.name,
      mixNumber: mixNumber ?? this.mixNumber,
      channelLevels: channelLevels ?? this.channelLevels,
      busLevel: busLevel ?? this.busLevel,
      createdAt: createdAt,
      updatedAt: DateTime.now(), // Atualiza timestamp
    );
  }

  /// Converte para JSON para salvar no SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mixNumber': mixNumber,
      'channelLevels': channelLevels.map((k, v) => MapEntry(k.toString(), v)),
      'busLevel': busLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cria um Preset a partir de JSON
  factory Preset.fromJson(Map<String, dynamic> json) {
    // Converte channelLevels de Map<String, dynamic> para Map<int, double>
    final channelLevelsMap = (json['channelLevels'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(int.parse(k), (v as num).toDouble()),
    );

    return Preset(
      id: json['id'] as String,
      name: json['name'] as String,
      mixNumber: json['mixNumber'] as int,
      channelLevels: channelLevelsMap,
      busLevel: (json['busLevel'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converte para String JSON
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Cria um Preset a partir de String JSON
  factory Preset.fromJsonString(String jsonString) {
    return Preset.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Preset(id: $id, name: $name, mixNumber: $mixNumber, channels: ${channelLevels.length}, busLevel: $busLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Preset && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

