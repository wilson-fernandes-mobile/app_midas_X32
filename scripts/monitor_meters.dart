import 'dart:io';
import 'dart:async';
import 'package:osc/osc.dart';

/// Script para monitorar mensagens /meters/1 da mesa Midas X32/M32
/// 
/// USO:
/// dart scripts/monitor_meters.dart <IP_DA_MESA>
/// 
/// Exemplo:
/// dart scripts/monitor_meters.dart 192.168.30.209

void main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Uso: dart scripts/monitor_meters.dart <IP_DA_MESA>');
    print('   Exemplo: dart scripts/monitor_meters.dart 192.168.30.209');
    exit(1);
  }

  final consoleIp = args[0];
  final consolePort = 10023;

  print('🎛️  Monitor de Meters - Midas X32/M32');
  print('━' * 60);
  print('📡 Conectando em: $consoleIp:$consolePort');
  print('');

  try {
    final consoleAddress = InternetAddress(consoleIp);
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

    print('✅ Socket criado na porta: ${socket.port}');
    print('');

    // Envia /xremote primeiro (necessário para algumas versões do X32/M32)
    print('📤 Enviando /xremote...');
    final xremoteMsg = OSCMessage('/xremote', arguments: []);
    socket.send(xremoteMsg.toBytes(), consoleAddress, consolePort);
    await Future.delayed(Duration(milliseconds: 100));

    // Tenta /batchsubscribe (método correto para X32/M32)
    // Formato: /batchsubscribe ,ssiiii nome caminho inicio fim intervalo
    // Baseado na documentação: /batchsubscribe ,ssiii yyy /meters/6 0 0 40
    print('📤 Enviando /batchsubscribe para meters...');
    final batchMsg = OSCMessage('/batchsubscribe', arguments: ['meters', '/meters/1', 0, 0, 40]);
    socket.send(batchMsg.toBytes(), consoleAddress, consolePort);
    await Future.delayed(Duration(milliseconds: 100));

    print('⏳ Aguardando mensagens /meters/1...');
    print('');

    var metersCount = 0;
    var lastMetersTime = DateTime.now();

    // Escuta mensagens OSC
    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();
        if (datagram != null) {
          try {
            final message = OSCMessage.fromBytes(datagram.data);
            
            // Filtra apenas /meters/1
            if (message.address == '/meters/1') {
              metersCount++;
              final now = DateTime.now();
              final elapsed = now.difference(lastMetersTime).inMilliseconds;
              lastMetersTime = now;

              print('━' * 60);
              print('📊 METERS #$metersCount recebido! (${elapsed}ms desde último)');
              print('   Endereço: ${message.address}');
              print('   Argumentos: ${message.arguments.length}');

              if (message.arguments.isNotEmpty) {
                final arg = message.arguments[0];
                print('   Tipo: ${arg.runtimeType}');

                // Tenta converter para List<int>
                List<int>? blob;
                if (arg is List<int>) {
                  blob = arg;
                } else if (arg.runtimeType.toString().contains('Uint8List')) {
                  blob = List<int>.from(arg as Iterable);
                }

                if (blob != null) {
                  print('   Tamanho do blob: ${blob.length} bytes');
                  print('');
                  print('   Primeiros 16 bytes (hex):');
                  final hexStr = blob.take(16).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
                  print('   $hexStr');
                  print('');

                  // Decodifica os primeiros 8 canais
                  print('   📈 Primeiros 8 canais decodificados:');
                  for (int i = 0; i < 8 && i * 2 < blob.length - 1; i++) {
                    final index = i * 2;
                    final highByte = blob[index];
                    final lowByte = blob[index + 1];
                    final rawValue = (highByte << 8) | lowByte;
                    
                    // Converte de signed 16-bit para float
                    final signedValue = rawValue > 32767 ? rawValue - 65536 : rawValue;
                    final normalizedValue = (signedValue / 32768.0).clamp(0.0, 1.0);
                    
                    // Cria barra visual
                    final barLength = (normalizedValue * 40).round();
                    final bar = '█' * barLength + '░' * (40 - barLength);
                    
                    // Converte para dB
                    final db = normalizedValue > 0.0 
                        ? (20 * (normalizedValue - 0.75) / 0.25).toStringAsFixed(1)
                        : '-∞';
                    
                    final percent = (normalizedValue * 100).toStringAsFixed(1);
                    
                    print('   Ch${(i + 1).toString().padLeft(2, '0')}: $bar $percent% ($db dB)');
                  }
                } else {
                  print('   ⚠️  Não foi possível converter para blob');
                }
              } else {
                print('   ⚠️  Sem argumentos!');
              }
              print('');
            }
          } catch (e) {
            print('❌ Erro ao decodificar mensagem: $e');
          }
        }
      }
    });

    // Solicita /meters/1 a cada 50ms (20Hz)
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      final message = OSCMessage('/meters/1', arguments: []);
      final bytes = message.toBytes();
      socket.send(bytes, consoleAddress, consolePort);
    });

    // Renova subscrição a cada 9 segundos
    Timer.periodic(Duration(seconds: 9), (timer) {
      print('🔄 Renovando subscrição (/renew meters)...');
      final message = OSCMessage('/renew', arguments: ['meters']);
      final bytes = message.toBytes();
      socket.send(bytes, consoleAddress, consolePort);
    });

    print('✅ Monitoramento iniciado!');
    print('   - Enviado /batchsubscribe para receber meters automaticamente');
    print('   - Solicitando /meters/1 a cada 50ms (20Hz) como fallback');
    print('   - Renovando subscrição a cada 9s');
    print('');
    print('Pressione Ctrl+C para sair');
    print('');

  } catch (e) {
    print('❌ Erro: $e');
    exit(1);
  }
}

