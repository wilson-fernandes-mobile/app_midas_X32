import 'dart:io';
import 'package:osc/osc.dart';

/// Script para testar se o emulador SALVA valores
/// 
/// Uso:
/// dart scripts/test_set_get.dart <IP>

void main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Uso: dart scripts/test_set_get.dart <IP>');
    print('   Exemplo: dart scripts/test_set_get.dart 192.168.9.138');
    exit(1);
  }

  final ip = args[0];

  print('🧪 Teste: Definir e Ler Valores');
  print('═' * 60);
  print('📡 IP: $ip:10023');
  print('═' * 60);
  print('');

  // Conecta
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  final consoleAddress = InternetAddress(ip);
  const consolePort = 10023;

  print('✅ Socket criado');
  print('');

  // Armazena valores recebidos
  final Map<String, dynamic> receivedValues = {};

  // Escuta respostas
  socket.listen((event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram != null) {
        try {
          final message = OSCMessage.fromBytes(datagram.data);
          receivedValues[message.address] = message.arguments;
          print('📥 RECEBIDO: ${message.address} ${message.arguments}');
        } catch (e) {
          // Ignora
        }
      }
    }
  });

  print('🧪 TESTE 1: Definir Canal 1 = 75%');
  print('─' * 60);
  await _sendMessage(socket, consoleAddress, consolePort, '/ch/01/mix/01/level', [0.75]);
  print('📤 ENVIADO: /ch/01/mix/01/level [0.75]');
  await Future.delayed(const Duration(milliseconds: 500));
  print('');

  print('🧪 TESTE 2: Ler Canal 1');
  print('─' * 60);
  await _sendMessage(socket, consoleAddress, consolePort, '/ch/01/mix/01/level');
  print('📤 SOLICITADO: /ch/01/mix/01/level');
  await Future.delayed(const Duration(milliseconds: 500));
  print('');

  print('🧪 TESTE 3: Definir Canal 2 = 50%');
  print('─' * 60);
  await _sendMessage(socket, consoleAddress, consolePort, '/ch/02/mix/01/level', [0.50]);
  print('📤 ENVIADO: /ch/02/mix/01/level [0.50]');
  await Future.delayed(const Duration(milliseconds: 500));
  print('');

  print('🧪 TESTE 4: Ler Canal 2');
  print('─' * 60);
  await _sendMessage(socket, consoleAddress, consolePort, '/ch/02/mix/01/level');
  print('📤 SOLICITADO: /ch/02/mix/01/level');
  await Future.delayed(const Duration(milliseconds: 500));
  print('');

  print('🧪 TESTE 5: Definir Bus 1 = 80%');
  print('─' * 60);
  await _sendMessage(socket, consoleAddress, consolePort, '/bus/01/mix/fader', [0.80]);
  print('📤 ENVIADO: /bus/01/mix/fader [0.80]');
  await Future.delayed(const Duration(milliseconds: 500));
  print('');

  print('🧪 TESTE 6: Ler Bus 1');
  print('─' * 60);
  await _sendMessage(socket, consoleAddress, consolePort, '/bus/01/mix/fader');
  print('📤 SOLICITADO: /bus/01/mix/fader');
  await Future.delayed(const Duration(milliseconds: 500));
  print('');

  print('═' * 60);
  print('📊 RESULTADO:');
  print('═' * 60);
  print('');

  // Verifica resultados
  final ch1Level = receivedValues['/ch/01/mix/01/level'];
  final ch2Level = receivedValues['/ch/02/mix/01/level'];
  final busLevel = receivedValues['/bus/01/mix/fader'];

  if (ch1Level != null) {
    final value = (ch1Level[0] as num).toDouble();
    final expected = 0.75;
    final match = (value - expected).abs() < 0.01;
    print('Canal 1: ${match ? "✅" : "❌"} Esperado: $expected, Recebido: $value');
  } else {
    print('Canal 1: ❌ Sem resposta');
  }

  if (ch2Level != null) {
    final value = (ch2Level[0] as num).toDouble();
    final expected = 0.50;
    final match = (value - expected).abs() < 0.01;
    print('Canal 2: ${match ? "✅" : "❌"} Esperado: $expected, Recebido: $value');
  } else {
    print('Canal 2: ❌ Sem resposta');
  }

  if (busLevel != null) {
    final value = (busLevel[0] as num).toDouble();
    final expected = 0.80;
    final match = (value - expected).abs() < 0.01;
    print('Bus 1:   ${match ? "✅" : "❌"} Esperado: $expected, Recebido: $value');
  } else {
    print('Bus 1:   ❌ Sem resposta');
  }

  print('');
  print('═' * 60);
  
  if (ch1Level != null && ch2Level != null && busLevel != null) {
    final ch1Match = ((ch1Level[0] as num).toDouble() - 0.75).abs() < 0.01;
    final ch2Match = ((ch2Level[0] as num).toDouble() - 0.50).abs() < 0.01;
    final busMatch = ((busLevel[0] as num).toDouble() - 0.80).abs() < 0.01;

    if (ch1Match && ch2Match && busMatch) {
      print('✅ SUCESSO! O emulador está salvando valores!');
    } else {
      print('⚠️  ATENÇÃO! O emulador respondeu, mas com valores diferentes!');
      print('   Isso significa que o emulador NÃO está salvando os valores.');
      print('   Ele sempre retorna 0.0 (ou valores padrão).');
    }
  } else {
    print('❌ FALHA! O emulador não está respondendo!');
    print('   Verifique se o emulador está rodando.');
  }

  print('═' * 60);

  socket.close();
  exit(0);
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
    print('❌ Erro ao enviar $oscAddress: $e');
  }
}

