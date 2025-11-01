import 'dart:io';
import 'package:osc/osc.dart';

/// Script de teste manual para verificar comunicação OSC com X32 Emulator
/// 
/// Execute com: dart test/osc_test_manual.dart
void main() async {
  print('🎛️  Teste de Comunicação OSC com X32 Emulator\n');
  
  // Configuração
  final consoleIP = '127.0.0.1'; // Mude para o IP do seu PC se testar de outro dispositivo
  final consolePort = 10023;
  
  print('📡 Conectando ao emulador em $consoleIP:$consolePort...\n');
  
  // Cria socket UDP
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  final consoleAddress = InternetAddress(consoleIP);
  
  // Escuta respostas
  socket.listen((event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram != null) {
        try {
          final message = OSCMessage.fromBytes(datagram.data);
          print('✅ RECEBIDO: ${message.address}');
          if (message.arguments.isNotEmpty) {
            print('   Argumentos: ${message.arguments}');
          }
        } catch (e) {
          print('⚠️  Erro ao decodificar: $e');
        }
      }
    }
  });
  
  // Função auxiliar para enviar comandos
  Future<void> sendCommand(String address, [List<Object> args = const []]) async {
    final message = OSCMessage(address, arguments: args);
    final bytes = message.toBytes();
    socket.send(bytes, consoleAddress, consolePort);
    print('📤 ENVIADO: $address ${args.isNotEmpty ? args : ""}');
    await Future.delayed(Duration(milliseconds: 100));
  }
  
  print('🧪 Iniciando testes...\n');
  
  // Teste 1: Info do console
  print('--- Teste 1: Solicitar informações do console ---');
  await sendCommand('/info');
  await Future.delayed(Duration(seconds: 1));
  
  // Teste 2: Keep-alive
  print('\n--- Teste 2: Keep-alive (xremote) ---');
  await sendCommand('/xremote');
  await Future.delayed(Duration(seconds: 1));
  
  // Teste 3: Solicitar nome do canal 1
  print('\n--- Teste 3: Solicitar nome do Canal 1 ---');
  await sendCommand('/ch/01/config/name');
  await Future.delayed(Duration(seconds: 1));
  
  // Teste 4: Definir nível do canal 1 no mix 1
  print('\n--- Teste 4: Definir nível do Canal 1 no Mix 1 para 0.75 ---');
  await sendCommand('/ch/01/mix/01/level', [0.75]);
  await Future.delayed(Duration(milliseconds: 500));
  
  // Teste 5: Solicitar nível do canal 1 no mix 1
  print('\n--- Teste 5: Solicitar nível do Canal 1 no Mix 1 ---');
  await sendCommand('/ch/01/mix/01/level');
  await Future.delayed(Duration(seconds: 1));
  
  // Teste 6: Definir fader do bus 1
  print('\n--- Teste 6: Definir fader do Bus 1 para 0.5 ---');
  await sendCommand('/bus/01/mix/fader', [0.5]);
  await Future.delayed(Duration(milliseconds: 500));
  
  // Teste 7: Solicitar fader do bus 1
  print('\n--- Teste 7: Solicitar fader do Bus 1 ---');
  await sendCommand('/bus/01/mix/fader');
  await Future.delayed(Duration(seconds: 1));
  
  // Teste 8: Testar múltiplos canais
  print('\n--- Teste 8: Configurar níveis de vários canais ---');
  for (int ch = 1; ch <= 5; ch++) {
    final level = ch * 0.15; // 0.15, 0.30, 0.45, 0.60, 0.75
    await sendCommand('/ch/${ch.toString().padLeft(2, '0')}/mix/01/level', [level]);
    await Future.delayed(Duration(milliseconds: 200));
  }
  
  print('\n--- Teste 9: Solicitar níveis configurados ---');
  for (int ch = 1; ch <= 5; ch++) {
    await sendCommand('/ch/${ch.toString().padLeft(2, '0')}/mix/01/level');
    await Future.delayed(Duration(milliseconds: 200));
  }
  
  await Future.delayed(Duration(seconds: 2));
  
  print('\n✅ Testes concluídos!');
  print('\n📊 Verifique no terminal do X32 Emulator se os comandos foram recebidos.');
  print('💡 Se você viu mensagens "RECEBIDO", a comunicação está funcionando!\n');
  
  socket.close();
  exit(0);
}

