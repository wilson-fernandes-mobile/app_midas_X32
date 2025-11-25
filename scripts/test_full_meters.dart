import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math' as Math;
import 'package:osc/osc.dart';

/// Teste completo de meters:
/// 1. Simula o console X32 enviando /meters/1
/// 2. Escuta as mensagens que o app envia (/xremote, /batchsubscribe, etc.)
/// 3. Responde com meters simulados
void main(List<String> arguments) async {
  final consolePort = 10023; // Porta do console (onde o app se conecta)
  final sendInterval = 40; // Intervalo de envio em ms (25Hz)

  print('🎛️  Teste Completo de Meters - Simulador X32');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📡 Simulando console X32 na porta: $consolePort');
  print('⏱️  Intervalo de meters: ${sendInterval}ms (${1000 ~/ sendInterval}Hz)');
  print('');
  print('⚠️  IMPORTANTE:');
  print('   1. Rode este script ANTES de conectar o app');
  print('   2. No app, conecte em: 127.0.0.1:$consolePort');
  print('   3. Observe os logs do app para ver se recebe /meters/1');
  print('');

  // Cria socket UDP
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, consolePort);

  print('✅ Console simulado criado na porta: ${socket.port}');
  print('');
  print('📊 Aguardando conexão do app...');
  print('   Pressione Ctrl+C para sair');
  print('');

  InternetAddress? appAddress;
  int? appPort;
  var subscribed = false;
  var messageCount = 0;
  var time = 0.0;
  Timer? metersTimer;

  // Escuta mensagens do app
  socket.listen((event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram == null) return;

      // Salva endereço do app
      appAddress = datagram.address;
      appPort = datagram.port;

      try {
        // Decodifica mensagem OSC
        final message = OSCMessage.fromBytes(datagram.data);
        
        print('📨 Recebido do app: ${message.address} ${message.arguments}');

        // Responde a comandos específicos
        if (message.address == '/xremote') {
          print('   ✅ App ativou modo remoto');
        } else if (message.address == '/batchsubscribe') {
          print('   ✅ App subscreveu para meters!');
          print('   📊 Iniciando envio de meters...');
          subscribed = true;

          // Inicia timer de envio de meters
          metersTimer?.cancel();
          metersTimer = Timer.periodic(Duration(milliseconds: sendInterval), (timer) {
            if (appAddress != null && appPort != null) {
              messageCount++;
              time += sendInterval / 1000.0;

              // Cria dados de meters simulados
              final metersData = _generateSimulatedMeters(time);

              // Cria mensagem OSC /meters/1
              final metersMsg = OSCMessage('/meters/1', arguments: [
                Uint8List.fromList(metersData)
              ]);

              // Envia para o app
              socket.send(metersMsg.toBytes(), appAddress!, appPort!);

              // Log a cada 25 mensagens (1 segundo em 25Hz)
              if (messageCount % 25 == 0) {
                print('📤 Enviados $messageCount meters (${time.toStringAsFixed(1)}s)');
              }
            }
          });
        } else if (message.address == '/meters/1') {
          print('   ℹ️  App solicitou meters (polling)');
          
          // Responde com meters mesmo sem subscription
          if (appAddress != null && appPort != null && !subscribed) {
            final metersData = _generateSimulatedMeters(time);
            final metersMsg = OSCMessage('/meters/1', arguments: [
              Uint8List.fromList(metersData)
            ]);
            socket.send(metersMsg.toBytes(), appAddress!, appPort!);
          }
        }
      } catch (e) {
        print('❌ Erro ao processar mensagem: $e');
      }
    }
  });

  // Aguarda Ctrl+C
  await ProcessSignal.sigint.watch().first;
  print('');
  print('🛑 Encerrando simulador...');
  metersTimer?.cancel();
  socket.close();
  print('✅ Simulador encerrado. Total de meters enviados: $messageCount');
}

/// Gera dados de meters simulados (64 bytes)
List<int> _generateSimulatedMeters(double time) {
  final data = <int>[];
  final random = Math.Random();

  for (var i = 0; i < 32; i++) {
    // Simula meters REALISTAS com mudanças RÁPIDAS e ALEATÓRIAS
    // Como um meter real de áudio (sobe/desce rapidamente)

    // Cada canal tem um comportamento diferente:
    // - Canais ímpares: Variação rápida (bateria, percussão)
    // - Canais pares: Variação média (vocais, instrumentos)

    double level;
    if (i % 2 == 0) {
      // Canais pares: Variação MUITO RÁPIDA (0% a 100%)
      final randomValue = random.nextDouble();
      final phase = (time * 10.0) + (i * 1.5);
      final sine = Math.sin(phase);
      level = (randomValue * 0.6 + sine.abs() * 0.4).clamp(0.0, 1.0);
    } else {
      // Canais ímpares: Picos aleatórios (simula transientes)
      final randomValue = random.nextDouble();
      if (randomValue > 0.7) {
        // 30% de chance de pico alto
        level = 0.8 + random.nextDouble() * 0.2; // 80% a 100%
      } else {
        // 70% de chance de nível médio/baixo
        level = random.nextDouble() * 0.6; // 0% a 60%
      }
    }

    // Converte para 16-bit big-endian (0-1023)
    final value = (level * 1023).toInt().clamp(0, 1023);

    // Big-endian: MSB primeiro, LSB depois
    data.add((value >> 8) & 0xFF); // MSB
    data.add(value & 0xFF);        // LSB
  }

  return data;
}

