import 'dart:io';
import 'dart:async';
import 'package:osc/osc.dart';

/// Script para monitorar níveis em TEMPO REAL (atualiza continuamente)
/// 
/// Uso:
/// dart scripts/monitor_tempo_real.dart <IP> <MIX> [INTERVALO_MS]
/// 
/// Exemplo:
/// dart scripts/monitor_tempo_real.dart 192.168.9.138 1
/// dart scripts/monitor_tempo_real.dart 10.0.2.2 1 500

void main(List<String> args) async {
  // Valida argumentos
  if (args.isEmpty) {
    print('❌ Uso: dart scripts/monitor_tempo_real.dart <IP> <MIX> [INTERVALO_MS]');
    print('   Exemplo: dart scripts/monitor_tempo_real.dart 192.168.9.138 1');
    print('   Exemplo: dart scripts/monitor_tempo_real.dart 10.0.2.2 1 500');
    exit(1);
  }

  final ip = args[0];
  final mix = args.length > 1 ? int.tryParse(args[1]) ?? 1 : 1;
  final intervalMs = args.length > 2 ? int.tryParse(args[2]) ?? 1000 : 1000;

  if (mix < 1 || mix > 16) {
    print('❌ Mix deve ser um número entre 1 e 16');
    exit(1);
  }

  print('🎛️  Monitor em Tempo Real - CCLMidas');
  print('═' * 70);
  print('📡 IP: $ip:10023');
  print('🎚️  Mix: $mix');
  print('⏱️  Intervalo: ${intervalMs}ms');
  print('═' * 70);
  print('');

  // Conecta ao console
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  final consoleAddress = InternetAddress(ip);
  const consolePort = 10023;

  print('✅ Conectado!');
  print('💡 Pressione Ctrl+C para sair');
  print('');

  // Mapa para armazenar os níveis dos canais
  final Map<int, ChannelInfo> channels = {};
  BusInfo? busInfo;

  // Escuta respostas
  socket.listen((event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram != null) {
        try {
          final message = OSCMessage.fromBytes(datagram.data);
          final address = message.address;

          // Parse channel level
          if (address.contains('/ch/') && address.contains('/mix/') && address.endsWith('/level')) {
            final parts = address.split('/');
            if (parts.length >= 5) {
              final channelNum = int.tryParse(parts[2]);
              final mixNum = int.tryParse(parts[4]);
              
              if (channelNum != null && mixNum == mix && message.arguments.isNotEmpty) {
                final level = (message.arguments[0] as num).toDouble();
                
                if (!channels.containsKey(channelNum)) {
                  channels[channelNum] = ChannelInfo(channelNum);
                }
                channels[channelNum]!.level = level;
                channels[channelNum]!.lastUpdate = DateTime.now();
              }
            }
          }

          // Parse channel name
          if (address.contains('/config/name')) {
            final parts = address.split('/');
            if (parts.length >= 3 && parts[1] == 'ch') {
              final channelNum = int.tryParse(parts[2]);
              if (channelNum != null && message.arguments.isNotEmpty) {
                final name = message.arguments[0].toString();
                
                if (!channels.containsKey(channelNum)) {
                  channels[channelNum] = ChannelInfo(channelNum);
                }
                channels[channelNum]!.name = name;
              }
            }
          }

          // Parse bus level
          if (address.contains('/bus/') && address.endsWith('/fader')) {
            final parts = address.split('/');
            if (parts.length >= 3) {
              final busNum = int.tryParse(parts[2]);

              if (busNum != null && busNum == mix && message.arguments.isNotEmpty) {
                final level = (message.arguments[0] as num).toDouble();

                if (busInfo == null) {
                  busInfo = BusInfo(busNum);
                }
                busInfo!.level = level;
                busInfo!.lastUpdate = DateTime.now();
              }
            }
          }

        } catch (e) {
          // Ignora erros de parsing
        }
      }
    }
  });

  // Timer para solicitar informações periodicamente
  Timer.periodic(Duration(milliseconds: intervalMs), (timer) async {
    // Solicita níveis de todos os canais
    for (int ch = 1; ch <= 32; ch++) {
      final levelAddress = '/ch/${ch.toString().padLeft(2, '0')}/mix/${mix.toString().padLeft(2, '0')}/level';
      await _sendMessage(socket, consoleAddress, consolePort, levelAddress);
    }

    // Solicita nível do bus
    final busAddress = '/bus/${mix.toString().padLeft(2, '0')}/mix/fader';
    await _sendMessage(socket, consoleAddress, consolePort, busAddress);

    // Limpa tela e mostra status
    _clearScreen();
    _printStatus(channels, busInfo, mix);
  });

  // Solicita nomes dos canais (uma vez só)
  await Future.delayed(const Duration(milliseconds: 100));
  for (int ch = 1; ch <= 32; ch++) {
    final nameAddress = '/ch/${ch.toString().padLeft(2, '0')}/config/name';
    await _sendMessage(socket, consoleAddress, consolePort, nameAddress);
    await Future.delayed(const Duration(milliseconds: 10));
  }

  // Mantém o script rodando
  await Future.delayed(const Duration(days: 365));
}

class ChannelInfo {
  final int number;
  String name = '';
  double level = 0.0;
  DateTime? lastUpdate;

  ChannelInfo(this.number);
}

class BusInfo {
  final int number;
  double level = 0.0;
  DateTime? lastUpdate;

  BusInfo(this.number);
}

void _printStatus(Map<int, ChannelInfo> channels, BusInfo? busInfo, int mix) {
  print('🎛️  Monitor em Tempo Real - Mix $mix');
  print('═' * 70);
  print('⏰ ${DateTime.now().toString().substring(11, 19)}');
  print('');

  // Mostra canais em 2 colunas
  for (int row = 0; row < 16; row++) {
    final ch1 = row + 1;
    final ch2 = row + 17;

    final info1 = channels[ch1];
    final info2 = channels[ch2];

    final col1 = _formatChannel(ch1, info1);
    final col2 = _formatChannel(ch2, info2);

    print('$col1  $col2');
  }

  print('');
  print('─' * 70);
  
  // Mostra bus
  if (busInfo != null) {
    final percentage = (busInfo.level * 100).toStringAsFixed(1).padLeft(5);
    final bar = _createBar(busInfo.level, 30);
    final status = busInfo.lastUpdate != null ? '✅' : '⏳';
    print('$status BUS ${mix.toString().padLeft(2, '0')}: $bar $percentage%');
  } else {
    print('⏳ BUS ${mix.toString().padLeft(2, '0')}: Aguardando...');
  }

  print('═' * 70);
  print('💡 Pressione Ctrl+C para sair');
}

String _formatChannel(int ch, ChannelInfo? info) {
  final chStr = 'Ch${ch.toString().padLeft(2, '0')}';
  
  if (info == null || info.lastUpdate == null) {
    return '$chStr: ⏳ Aguardando...'.padRight(33);
  }

  final percentage = (info.level * 100).toStringAsFixed(1).padLeft(5);
  final bar = _createBar(info.level, 10);
  final status = '✅';

  return '$status $chStr: $bar $percentage%';
}

String _createBar(double level, int length) {
  final filled = (level * length).round();
  final empty = length - filled;
  return '█' * filled + '░' * empty;
}

Future<void> _sendMessage(
  RawDatagramSocket socket,
  InternetAddress address,
  int port,
  String oscAddress, [
  List<Object> arguments = const [],
]) async {
  try {
    final message = OSCMessage(oscAddress, arguments: arguments);
    final bytes = message.toBytes();
    socket.send(bytes, address, port);
  } catch (e) {
    // Ignora erros
  }
}

void _clearScreen() {
  if (Platform.isWindows) {
    print('\x1B[2J\x1B[0;0H'); // ANSI escape codes
  } else {
    print('\x1B[2J\x1B[0;0H');
  }
}

