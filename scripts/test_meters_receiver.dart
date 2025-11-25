import 'dart:io';
import 'dart:typed_data';
import 'package:osc/osc.dart';

/// Testa se o app está recebendo mensagens /meters/1 corretamente
/// Escuta na porta 10023 (mesma porta que o app usa)
void main(List<String> arguments) async {
  final listenPort = 10024; // Porta diferente para não conflitar com o app

  print('🎛️  Teste de Recepção de Meters - Midas X32/M32');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📡 Escutando na porta: $listenPort');
  print('');
  print('⚠️  IMPORTANTE: Para testar com o simulador:');
  print('   1. Rode este script primeiro');
  print('   2. Em outro terminal, rode: dart scripts/simulate_meters.dart');
  print('      (edite o IP/porta no simulador para 127.0.0.1:$listenPort)');
  print('');

  // Cria socket UDP
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, listenPort);

  print('✅ Socket criado e escutando...');
  print('   Aguardando mensagens /meters/1...');
  print('   Pressione Ctrl+C para sair');
  print('');

  var messageCount = 0;
  var lastMessageTime = DateTime.now();

  // Escuta mensagens
  socket.listen((event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram == null) return;

      try {
        // Decodifica mensagem OSC
        final message = OSCMessage.fromBytes(datagram.data);
        final now = DateTime.now();
        final timeSinceLastMs = now.difference(lastMessageTime).inMilliseconds;
        lastMessageTime = now;

        messageCount++;

        // Verifica se é /meters/1
        if (message.address == '/meters/1') {
          print('📊 METERS #$messageCount recebido! (${timeSinceLastMs}ms desde último)');
          print('   Endereço: ${message.address}');
          print('   Argumentos: ${message.arguments.length}');

          if (message.arguments.isNotEmpty) {
            final arg = message.arguments[0];
            print('   Tipo: ${arg.runtimeType}');

            if (arg is Uint8List) {
              print('   Tamanho do blob: ${arg.length} bytes');
              print('');
              print('   📈 Primeiros 8 canais decodificados:');
              _printChannelLevels(arg, 8);
            } else {
              print('   ⚠️  Argumento não é Uint8List!');
            }
          }
        } else {
          print('📨 Mensagem OSC recebida: ${message.address}');
        }

        print('');
      } catch (e) {
        print('❌ Erro ao decodificar mensagem: $e');
      }
    }
  });

  // Aguarda Ctrl+C
  await ProcessSignal.sigint.watch().first;
  print('');
  print('🛑 Encerrando teste...');
  socket.close();
  print('✅ Teste encerrado. Total de mensagens recebidas: $messageCount');
}

/// Decodifica e exibe os níveis dos canais
void _printChannelLevels(Uint8List data, int count) {
  if (data.length < count * 2) {
    print('   ⚠️  Dados insuficientes (${data.length} bytes)');
    return;
  }

  for (var i = 0; i < count; i++) {
    final msb = data[i * 2];
    final lsb = data[i * 2 + 1];
    final value = (msb << 8) | lsb;
    final percent = value / 1023.0 * 100;
    final db = _percentToDb(percent);
    
    // Cria barra visual
    final barLength = (percent / 100 * 40).round();
    final bar = '█' * barLength + '░' * (40 - barLength);
    
    print('   Ch${(i + 1).toString().padLeft(2, '0')}: $bar ${percent.toStringAsFixed(1)}% ($db dB)');
  }
}

/// Converte porcentagem para dB (aproximado)
String _percentToDb(double percent) {
  if (percent <= 0) return '-∞';
  // Conversão aproximada: 0% = -90dB, 100% = 0dB
  final db = (percent / 100.0 * 90.0) - 90.0;
  return db.toStringAsFixed(1);
}

