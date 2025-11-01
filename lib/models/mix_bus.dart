/// Representa um bus de mix (monitor) do console
class MixBus {
  final int number;
  String name;
  double level; // Volume geral do bus (0.0 a 1.0)
  double peakLevel; // Nível de pico do meter do bus (0.0 a 1.0)
  final List<int> channels; // Canais disponíveis neste mix

  MixBus({
    required this.number,
    this.name = '',
    this.level = 0.75,
    this.peakLevel = 0.0,
    this.channels = const [],
  });

  /// Endereço OSC para o nome do bus
  String get nameAddress {
    return '/bus/${number.toString().padLeft(2, '0')}/config/name';
  }

  /// Endereço OSC para o volume geral do bus
  String get levelAddress {
    return '/bus/${number.toString().padLeft(2, '0')}/mix/fader';
  }

  /// Valor OSC do level (0.0 a 1.0)
  double get oscLevel => level;

  MixBus copyWith({
    String? name,
    double? level,
    double? peakLevel,
    List<int>? channels,
  }) {
    return MixBus(
      number: number,
      name: name ?? this.name,
      level: level ?? this.level,
      peakLevel: peakLevel ?? this.peakLevel,
      channels: channels ?? this.channels,
    );
  }
}

