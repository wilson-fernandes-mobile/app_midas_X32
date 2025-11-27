import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:osc/osc.dart';

/// Simula o envio de mensagens /meters/1 do X32
/// Para testar se o app está recebendo meters corretamente
void main(List<String> arguments) async {
  // Configuração (pode ser passado como argumento)
  final appIp = arguments.isNotEmpty ? arguments[0] : '127.0.0.1';
  final appPort = arguments.length > 1 ? int.parse(arguments[1]) : 10024;
  final sendInterval = 50; // Intervalo de envio em ms (20Hz)

  print('🎛️  Simulador de Meters - Midas X32/M32');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📡 Enviando meters para: $appIp:$appPort');
  print('⏱️  Intervalo: ${sendInterval}ms (${1000 ~/ sendInterval}Hz)');
  print('');

  // Cria socket UDP
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  final targetAddress = InternetAddress(appIp);

  print('✅ Socket criado na porta: ${socket.port}');
  print('');
  print('📊 Enviando mensagens /meters/1 simuladas...');
  print('   Pressione Ctrl+C para sair');
  print('');

  var messageCount = 0;
  var time = 0.0;

  // Timer para enviar meters periodicamente
  Timer.periodic(Duration(milliseconds: sendInterval), (timer) {
    messageCount++;
    time += sendInterval / 1000.0;

    // Cria dados de meters simulados (64 bytes = 32 canais x 2 bytes)
    final metersData = _generateSimulatedMeters(time);

    // Cria mensagem OSC /meters/1 com blob de dados
    final message = OSCMessage('/meters/1', arguments: [
      Uint8List.fromList(metersData)
    ]);

    // Envia mensagem
    socket.send(message.toBytes(), targetAddress, appPort);

    // Log a cada 20 mensagens (1 segundo em 20Hz)
    if (messageCount % 20 == 0) {
      print('📤 Enviadas $messageCount mensagens (${time.toStringAsFixed(1)}s)');
      print('   Primeiros 4 canais: ${_formatChannelLevels(metersData, 4)}');
    }
  });

  // Aguarda Ctrl+C
  await ProcessSignal.sigint.watch().first;
  print('');
  print('🛑 Encerrando simulador...');
  //timer.cancel();
  socket.close();
  print('✅ Simulador encerrado. Total de mensagens enviadas: $messageCount');
}

/// Gera dados de meters simulados (64 bytes)
/// Simula níveis variando com o tempo para parecer real
List<int> _generateSimulatedMeters(double time) {
  final data = <int>[];

  for (var i = 0; i < 32; i++) {
    // Simula níveis diferentes para cada canal
    // Usa seno para criar variação suave
    final phase = (i * 0.3) + time;
    final level = 0.5 + 0.4 * (i % 2 == 0 ? 1 : -1) * (0.5 + 0.5 * (phase % 1.0));
    
    // Converte para 16-bit big-endian (0-1023)
    final value = (level * 1023).toInt().clamp(0, 1023);
    
    // Big-endian: MSB primeiro, LSB depois
    data.add((value >> 8) & 0xFF); // MSB
    data.add(value & 0xFF);        // LSB
  }

  return data;
}

/// Formata os níveis dos primeiros N canais para exibição
String _formatChannelLevels(List<int> data, int count) {
  final levels = <String>[];
  
  for (var i = 0; i < count && i < 32; i++) {
    final msb = data[i * 2];
    final lsb = data[i * 2 + 1];
    final value = (msb << 8) | lsb;
    final percent = (value / 1023.0 * 100).toStringAsFixed(1);
    levels.add('Ch${(i + 1).toString().padLeft(2, '0')}:$percent%');
  }
  
  return levels.join(' ');
}

