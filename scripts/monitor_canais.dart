import 'dart:io';
import 'dart:typed_data';
import 'package:osc/osc.dart';

/// Script para monitorar níveis dos canais em tempo real
/// 
/// Uso:
/// dart scripts/monitor_canais.dart <IP> <MIX>
/// 
/// Exemplo:
/// dart scripts/monitor_canais.dart 192.168.9.138 1
/// dart scripts/monitor_canais.dart 10.0.2.2 1

void main(List<String> args) async {
  // Valida argumentos
  if (args.length < 2) {
    print('❌ Uso: dart scripts/monitor_canais.dart <IP> <MIX>');
    print('   Exemplo: dart scripts/monitor_canais.dart 192.168.9.138 1');
    exit(1);
  }

  final ip = args[0];
  final mix = int.tryParse(args[1]);

  if (mix == null || mix < 1 || mix > 16) {
    print('❌ Mix deve ser um número entre 1 e 16');
    exit(1);
  }

  print('🎛️  Monitor de Canais - CCLMidas');
  print('═' * 60);
  print('📡 IP: $ip:10023');
  print('🎚️  Mix: $mix');
  print('═' * 60);
  print('');

  // Conecta ao console
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  final consoleAddress = InternetAddress(ip);
  const consolePort = 10023;

  print('✅ Socket criado na porta ${socket.port}');
  print('🔌 Conectando ao console...');
  print('');

  // Mapa para armazenar os níveis dos canais
  final Map<int, double> channelLevels = {};
  double? busLevel;

  // Escuta respostas
  socket.listen((event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram != null) {
        try {
          final message = OSCMessage.fromBytes(datagram.data);
          final address = message.address;

          // Parse channel level: /ch/01/mix/01/level
          if (address.contains('/ch/') && address.contains('/mix/') && address.endsWith('/level')) {
            final parts = address.split('/');
            if (parts.length >= 5) {
              final channelNum = int.tryParse(parts[2]);
              final mixNum = int.tryParse(parts[4]);
              
              if (channelNum != null && mixNum == mix && message.arguments.isNotEmpty) {
                final level = (message.arguments[0] as num).toDouble();
                channelLevels[channelNum] = level;
                
                // Mostra atualização
                final percentage = (level * 100).toStringAsFixed(1);
                final db = _levelToDb(level);
                final bar = _createBar(level);
                print('📊 Ch${channelNum.toString().padLeft(2, '0')}: $bar $percentage% ($db dB)');
              }
            }
          }

          // Parse bus level: /bus/01/mix/fader
          if (address.contains('/bus/') && address.endsWith('/fader')) {
            final parts = address.split('/');
            if (parts.length >= 3) {
              final busNum = int.tryParse(parts[2]);

              if (busNum != null && busNum == mix && message.arguments.isNotEmpty) {
                busLevel = (message.arguments[0] as num).toDouble();

                final percentage = (busLevel! * 100).toStringAsFixed(1);
                final db = _levelToDb(busLevel!);
                final bar = _createBar(busLevel!);
                print('🎛️  BUS${busNum.toString().padLeft(2, '0')}: $bar $percentage% ($db dB)');
              }
            }
          }

          // Parse channel name: /ch/01/config/name
          if (address.contains('/config/name')) {
            final parts = address.split('/');
            if (parts.length >= 3 && parts[1] == 'ch') {
              final channelNum = int.tryParse(parts[2]);
              if (channelNum != null && message.arguments.isNotEmpty) {
                final name = message.arguments[0].toString();
                print('📝 Ch${channelNum.toString().padLeft(2, '0')}: "$name"');
              }
            }
          }

        } catch (e) {
          print('⚠️  Erro ao parsear mensagem: $e');
        }
      }
    }
  });

  // Envia comando de info para testar conexão
  await _sendMessage(socket, consoleAddress, consolePort, '/info');
  await Future.delayed(const Duration(milliseconds: 100));

  print('🔍 Solicitando informações do Mix $mix...');
  print('');

  // Solicita informações de todos os canais
  for (int ch = 1; ch <= 32; ch++) {
    // Solicita nome do canal
    final nameAddress = '/ch/${ch.toString().padLeft(2, '0')}/config/name';
    await _sendMessage(socket, consoleAddress, consolePort, nameAddress);

    // Solicita nível do canal
    final levelAddress = '/ch/${ch.toString().padLeft(2, '0')}/mix/${mix.toString().padLeft(2, '0')}/level';
    await _sendMessage(socket, consoleAddress, consolePort, levelAddress);

    await Future.delayed(const Duration(milliseconds: 10));
  }

  // Solicita nível do bus
  final busAddress = '/bus/${mix.toString().padLeft(2, '0')}/mix/fader';
  await _sendMessage(socket, consoleAddress, consolePort, busAddress);

  print('');
  print('✅ Solicitações enviadas!');
  print('');
  print('═' * 60);
  print('💡 Aguardando respostas...');
  print('   (Pressione Ctrl+C para sair)');
  print('═' * 60);
  print('');

  // Mantém o script rodando
  await Future.delayed(const Duration(seconds: 5));

  // Mostra resumo
  print('');
  print('═' * 60);
  print('📊 RESUMO DOS NÍVEIS:');
  print('═' * 60);
  print('');

  if (channelLevels.isEmpty) {
    print('⚠️  Nenhum canal respondeu!');
    print('   Verifique se o emulador está rodando.');
  } else {
    for (int ch = 1; ch <= 32; ch++) {
      final level = channelLevels[ch];
      if (level != null) {
        final percentage = (level * 100).toStringAsFixed(1);
        final db = _levelToDb(level);
        final bar = _createBar(level);
        print('Ch${ch.toString().padLeft(2, '0')}: $bar $percentage% ($db dB)');
      } else {
        print('Ch${ch.toString().padLeft(2, '0')}: ⚠️  Sem resposta');
      }
    }
  }

  print('');
  if (busLevel != null) {
    final percentage = (busLevel! * 100).toStringAsFixed(1);
    final db = _levelToDb(busLevel!);
    final bar = _createBar(busLevel!);
    print('BUS: $bar $percentage% ($db dB)');
  } else {
    print('BUS: ⚠️  Sem resposta');
  }

  print('');
  print('═' * 60);
  print('✅ Monitoramento concluído!');
  print('═' * 60);

  socket.close();
  exit(0);
}

/// Envia uma mensagem OSC
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
    print('❌ Erro ao enviar $oscAddress: $e');
  }
}

/// Converte nível (0.0-1.0) para dB
String _levelToDb(double level) {
  if (level <= 0.0) return '-∞';
  final db = 20 * (level - 1) * 0.5; // Aproximação
  return db.toStringAsFixed(1);
}

/// Cria barra visual do nível
String _createBar(double level) {
  const barLength = 20;
  final filled = (level * barLength).round();
  final empty = barLength - filled;
  
  final bar = '█' * filled + '░' * empty;
  
  // Colorização (não funciona em todos os terminais)
  if (level > 0.8) {
    return bar; // Vermelho (alto)
  } else if (level > 0.5) {
    return bar; // Amarelo (médio)
  } else {
    return bar; // Verde (baixo)
  }
}

