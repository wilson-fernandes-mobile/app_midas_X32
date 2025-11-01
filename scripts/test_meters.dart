import 'dart:io';
import 'dart:typed_data';
import 'package:osc/osc.dart';

/// Script para testar o recebimento de meters do M32/X32
/// 
/// Uso:
///   dart scripts/test_meters.dart <IP> [PORTA]
/// 
/// Exemplo:
///   dart scripts/test_meters.dart 192.168.9.138
///   dart scripts/test_meters.dart 192.168.9.138 10023

void main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Uso: dart scripts/test_meters.dart <IP> [PORTA]');
    print('   Exemplo: dart scripts/test_meters.dart 192.168.9.138');
    exit(1);
  }

  final ip = args[0];
  final port = args.length > 1 ? int.parse(args[1]) : 10023;

  print('🎛️  Testando Meters do M32/X32');
  print('📡 IP: $ip');
  print('🔌 Porta: $port');
  print('');

  // Cria socket UDP
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  final consoleAddress = InternetAddress(ip);

  print('✅ Socket criado na porta ${socket.port}');
  print('');

  // Escuta respostas
  socket.listen((event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram != null) {
        try {
          final message = OSCMessage.fromBytes(datagram.data);
          
          if (message.address == '/meters/1') {
            print('📊 Recebeu /meters/1');
            
            if (message.arguments.isNotEmpty) {
              final arg = message.arguments[0];
              
              // Converte para List<int>
              List<int>? blob;
              if (arg is Uint8List) {
                blob = arg;
              } else if (arg is List<int>) {
                blob = arg;
              }
              
              if (blob != null) {
                print('   Tamanho do blob: ${blob.length} bytes');
                print('   Canais esperados: ${blob.length ~/ 2}');
                print('');
                
                // Decodifica os primeiros 8 canais
                print('   Primeiros 8 canais:');
                for (int i = 0; i < 8 && i * 2 < blob.length - 1; i++) {
                  final index = i * 2;
                  final highByte = blob[index];
                  final lowByte = blob[index + 1];
                  final rawValue = (highByte << 8) | lowByte;
                  
                  // Converte de signed 16-bit para float
                  final signedValue = rawValue > 32767 ? rawValue - 65536 : rawValue;
                  final normalizedValue = (signedValue / 32768.0).clamp(0.0, 1.0);
                  
                  // Converte para dB
                  final db = normalizedValue > 0.0 
                      ? (20 * (normalizedValue - 0.75) / 0.25).toStringAsFixed(1)
                      : '-∞';
                  
                  // Barra visual
                  final barLength = (normalizedValue * 20).round();
                  final bar = '█' * barLength + '░' * (20 - barLength);
                  
                  print('   Ch${(i + 1).toString().padLeft(2)}: $bar ${(normalizedValue * 100).toStringAsFixed(0).padLeft(3)}% ($db dB)');
                }
                print('');
              } else {
                print('   ⚠️  Formato desconhecido: ${arg.runtimeType}');
              }
            }
          } else {
            print('📨 ${message.address}: ${message.arguments}');
          }
        } catch (e) {
          print('❌ Erro ao processar mensagem: $e');
        }
      }
    }
  });

  // Envia /xremote para manter conexão
  print('📤 Enviando /xremote...');
  final xremoteMsg = OSCMessage('/xremote', arguments: []);
  socket.send(xremoteMsg.toBytes(), consoleAddress, port);
  await Future.delayed(const Duration(milliseconds: 100));

  // Loop: solicita meters a cada 100ms
  print('📊 Solicitando meters a cada 100ms...');
  print('   (Pressione Ctrl+C para parar)');
  print('');

  int count = 0;
  while (true) {
    // Envia /meters/1
    final metersMsg = OSCMessage('/meters/1', arguments: []);
    socket.send(metersMsg.toBytes(), consoleAddress, port);

    count++;
    if (count % 10 == 0) {
      // Envia /xremote a cada 1 segundo para manter conexão
      socket.send(xremoteMsg.toBytes(), consoleAddress, port);
    }

    await Future.delayed(const Duration(milliseconds: 100));
  }
}

