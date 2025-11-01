/// Representa um canal do console M32/X32
class Channel {
  final int number;
  String name;
  double level; // 0.0 a 1.0
  double pan; // -1.0 (L) a 1.0 (R)
  bool mute;
  String color;
  int icon; // Ícone do canal (1-74)
  double peakLevel; // Nível de pico do meter (0.0 a 1.0)

  Channel({
    required this.number,
    this.name = '',
    this.level = 0.75,
    this.pan = 0.0,
    this.mute = false,
    this.color = 'OFF',
    this.icon = 1, // Ícone padrão (microfone)
    this.peakLevel = 0.0, // Sem sinal por padrão
  });

  /// Converte level (0.0-1.0) para valor OSC do M32 (0.0-1.0)
  double get oscLevel => level;

  /// Converte pan (-1.0 a 1.0) para valor OSC do M32 (0.0-1.0)
  double get oscPan => (pan + 1.0) / 2.0;

  /// Endereço OSC para o level deste canal em um mix específico
  String getLevelAddress(int mixNumber) {
    return '/ch/${number.toString().padLeft(2, '0')}/mix/${mixNumber.toString().padLeft(2, '0')}/level';
  }

  /// Endereço OSC para o pan deste canal em um mix específico
  String getPanAddress(int mixNumber) {
    return '/ch/${number.toString().padLeft(2, '0')}/mix/${mixNumber.toString().padLeft(2, '0')}/pan';
  }

  /// Endereço OSC para o nome do canal
  String get nameAddress {
    return '/ch/${number.toString().padLeft(2, '0')}/config/name';
  }

  /// Endereço OSC para a cor do canal
  String get colorAddress {
    return '/ch/${number.toString().padLeft(2, '0')}/config/color';
  }

  /// Endereço OSC para o ícone do canal
  String get iconAddress {
    return '/ch/${number.toString().padLeft(2, '0')}/config/icon';
  }

  Channel copyWith({
    String? name,
    double? level,
    double? pan,
    bool? mute,
    String? color,
    int? icon,
    double? peakLevel,
  }) {
    return Channel(
      number: number,
      name: name ?? this.name,
      level: level ?? this.level,
      pan: pan ?? this.pan,
      mute: mute ?? this.mute,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      peakLevel: peakLevel ?? this.peakLevel,
    );
  }
}

/// Ícones disponíveis no M32/X32 (1-74)
/// Baseado na documentação não oficial do protocolo OSC
class ChannelIcon {
  static const int microphone = 1;
  static const int guitar = 2;
  static const int bass = 3;
  static const int drums = 4;
  static const int keyboard = 5;
  static const int saxophone = 6;
  static const int trumpet = 7;
  static const int violin = 8;
  static const int piano = 9;
  static const int vocal = 10;

  // Mapeamento de ícone para emoji/descrição
  static String getIconEmoji(int iconNumber) {
    switch (iconNumber) {
      case 1: return '🎤'; // Microphone
      case 2: return '🎸'; // Guitar
      case 3: return '🎸'; // Bass
      case 4: return '🥁'; // Drums
      case 5: return '🎹'; // Keyboard
      case 6: return '🎷'; // Saxophone
      case 7: return '🎺'; // Trumpet
      case 8: return '🎻'; // Violin
      case 9: return '🎹'; // Piano
      case 10: return '🎤'; // Vocal
      default: return '🎵'; // Generic music note
    }
  }

  static String getIconName(int iconNumber) {
    switch (iconNumber) {
      case 1: return 'Microfone';
      case 2: return 'Guitarra';
      case 3: return 'Baixo';
      case 4: return 'Bateria';
      case 5: return 'Teclado';
      case 6: return 'Saxofone';
      case 7: return 'Trompete';
      case 8: return 'Violino';
      case 9: return 'Piano';
      case 10: return 'Vocal';
      default: return 'Instrumento';
    }
  }
}

