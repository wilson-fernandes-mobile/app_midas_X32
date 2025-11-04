import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:osc/osc.dart';

/// Serviço para comunicação OSC com o console M32/X32
class OSCService {
  RawDatagramSocket? _socket;
  InternetAddress? _consoleAddress;
  int _consolePort = 10023;
  bool _isConnected = false;

  final StreamController<OSCMessage> _messageController =
      StreamController<OSCMessage>.broadcast();

  /// Stream de mensagens OSC recebidas do console
  Stream<OSCMessage> get messageStream => _messageController.stream;

  bool get isConnected => _isConnected;
  String? get consoleIp => _consoleAddress?.address;

  /// Conecta ao console M32/X32
  Future<bool> connect(String ipAddress, {int port = 10023}) async {
    try {
      // Fecha conexão anterior se existir
      await disconnect();

      _consoleAddress = InternetAddress(ipAddress);
      _consolePort = port;

      // Cria socket UDP para enviar e receber mensagens
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      // Escuta mensagens recebidas
      _socket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram != null) {
            try {
              final message = OSCMessage.fromBytes(datagram.data);
              if (kDebugMode) {
                print('📥 OSC recebido: ${message.address} ${message.arguments}');
              }
              _messageController.add(message);
            } catch (e) {
              print('Erro ao parsear mensagem OSC: $e');
            }
          }
        }
      });

      // Envia comando de info para verificar conexão
      await sendMessage('/info');

      // Inicia keep-alive (M32 desconecta após 10s sem mensagens)
      _startKeepAlive();

      _isConnected = true;
      print('Conectado ao console em $ipAddress:$port');
      return true;
    } catch (e) {
      print('Erro ao conectar: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Desconecta do console
  Future<void> disconnect() async {
    _isConnected = false;
    _keepAliveTimer?.cancel();
    _socket?.close();
    _socket = null;
    _consoleAddress = null;
    print('Desconectado do console');
  }

  Timer? _keepAliveTimer;

  /// Mantém a conexão ativa enviando mensagens periódicas
  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isConnected) {
        sendMessage('/xremote'); // Comando keep-alive do M32/X32
      } else {
        timer.cancel();
      }
    });
  }

  /// Envia uma mensagem OSC para o console
  Future<void> sendMessage(String address, [List<Object> arguments = const []]) async {
    if (!_isConnected || _socket == null || _consoleAddress == null) {
      print('Não conectado ao console');
      return;
    }

    try {
      final message = OSCMessage(address, arguments: arguments);
      final bytes = message.toBytes();
      _socket!.send(bytes, _consoleAddress!, _consolePort);
    } catch (e) {
      print('Erro ao enviar mensagem OSC: $e');
    }
  }

  /// Define o nível (volume) de um canal em um mix específico
  /// channel: 1-32, mixBus: 1-16, level: 0.0-1.0
  Future<void> setChannelLevel(int channel, int mixBus, double level) async {
    final address = '/ch/${channel.toString().padLeft(2, '0')}/mix/${mixBus.toString().padLeft(2, '0')}/level';
    final clampedLevel = level.clamp(0.0, 1.0);

    if (kDebugMode) {
      print('🔊 OSCService.setChannelLevel: $address [$clampedLevel]');
    }

    await sendMessage(address, [clampedLevel]);

    if (kDebugMode) {
      print('✅ OSCService: Mensagem enviada!');
    }
  }

  /// Define o pan de um canal em um mix específico
  /// channel: 1-32, mixBus: 1-16, pan: 0.0 (L) - 1.0 (R)
  Future<void> setChannelPan(int channel, int mixBus, double pan) async {
    final address = '/ch/${channel.toString().padLeft(2, '0')}/mix/${mixBus.toString().padLeft(2, '0')}/pan';
    await sendMessage(address, [pan.clamp(0.0, 1.0)]);
  }

  /// Define o volume geral de um bus
  /// bus: 1-16, level: 0.0-1.0
  Future<void> setBusLevel(int bus, double level) async {
    final address = '/bus/${bus.toString().padLeft(2, '0')}/mix/fader';
    await sendMessage(address, [level.clamp(0.0, 1.0)]);
  }

  /// Solicita o nome de um canal
  Future<void> requestChannelName(int channel) async {
    final address = '/ch/${channel.toString().padLeft(2, '0')}/config/name';
    await sendMessage(address);
  }

  /// Solicita o nome de um bus
  Future<void> requestBusName(int bus) async {
    final address = '/bus/${bus.toString().padLeft(2, '0')}/config/name';
    await sendMessage(address);
  }

  /// Solicita o nível principal (Main LR) de um canal
  Future<void> requestChannelMainLevel(int channel) async {
    final address = '/ch/${channel.toString().padLeft(2, '0')}/mix/fader';
    await sendMessage(address);
  }

  /// Solicita o mute principal (Main LR) de um canal
  Future<void> requestChannelMainMute(int channel) async {
    final address = '/ch/${channel.toString().padLeft(2, '0')}/mix/on';
    await sendMessage(address);
  }

  /// Solicita informações de todos os canais para um mix específico
  Future<void> requestMixInfo(int mixBus) async {
    if (kDebugMode) {
      print('📋 Solicitando info de todos os canais para Mix $mixBus...');
    }

    // Solicita nomes e níveis de todos os 32 canais
    for (int ch = 1; ch <= 32; ch++) {
      await requestChannelName(ch);
      final levelAddress = '/ch/${ch.toString().padLeft(2, '0')}/mix/${mixBus.toString().padLeft(2, '0')}/level';

      if (kDebugMode) {
        print('📤 Solicitando: $levelAddress');
      }

      await sendMessage(levelAddress);

      // Pequeno delay para não sobrecarregar
      await Future.delayed(const Duration(milliseconds: 10));
    }

    // Solicita o nível do bus (fader master do mix)
    final busLevelAddress = '/bus/${mixBus.toString().padLeft(2, '0')}/mix/fader';
    if (kDebugMode) {
      print('📤 Solicitando nível do bus: $busLevelAddress');
    }
    await sendMessage(busLevelAddress);

    if (kDebugMode) {
      print('✅ Solicitações enviadas para Mix $mixBus!');
    }
  }

  /// Subscreve para receber atualizações automáticas
  Future<void> subscribe() async {
    await sendMessage('/xremote');
    await sendMessage('/subscribe');
  }

  /// Cancela subscrição
  Future<void> unsubscribe() async {
    await sendMessage('/unsubscribe');
  }

  /// Solicita meters (níveis de áudio em tempo real)
  /// /meters/1 = Canais 1-32
  /// /meters/2 = Buses 1-16
  /// /meters/3 = Aux/FX
  /// /meters/4 = Outputs
  Future<void> requestMeters() async {
    // Solicita meters dos canais (1-32)
    await sendMessage('/meters/1');
    // Solicita meters dos buses (1-16)
    await sendMessage('/meters/2');
  }

  /// Processa blob binário de meters
  /// Cada canal = 2 bytes (16-bit signed integer)
  /// Retorna Map<int, double> onde key = channel number, value = peak level (0.0-1.0)
  Map<int, double> parseMetersBlob(List<int> blob) {
    final meters = <int, double>{};

    try {
      // Cada canal usa 2 bytes (16-bit big-endian)
      for (int i = 0; i < blob.length - 1; i += 2) {
        final channelIndex = i ~/ 2;

        // Combina 2 bytes em um valor de 16-bit (big-endian)
        final highByte = blob[i];
        final lowByte = blob[i + 1];
        final rawValue = (highByte << 8) | lowByte;

        // Converte de signed 16-bit para float (0.0-1.0)
        // Valores negativos são tratados como 0
        final signedValue = rawValue > 32767 ? rawValue - 65536 : rawValue;
        final normalizedValue = (signedValue / 32768.0).clamp(0.0, 1.0);

        // Channel number (1-based)
        final channelNumber = channelIndex + 1;

        if (channelNumber <= 32) {
          meters[channelNumber] = normalizedValue;
        }
      }

      if (kDebugMode && meters.isNotEmpty) {
        // Log apenas alguns canais para não poluir
        final ch1 = meters[1]?.toStringAsFixed(2) ?? '0.00';
        final ch2 = meters[2]?.toStringAsFixed(2) ?? '0.00';
        print('📊 Meters: Ch1=$ch1, Ch2=$ch2, ... (${meters.length} canais)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao processar meters blob: $e');
      }
    }

    return meters;
  }

  void dispose() {
    _keepAliveTimer?.cancel();
    _messageController.close();
    disconnect();
  }
}

