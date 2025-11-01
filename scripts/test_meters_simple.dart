import 'dart:io';
import 'dart:typed_data';

/// Script simples para testar se o emulador responde /meters/1
/// 
/// Uso:
///   dart scripts/test_meters_simple.dart <IP> [PORTA]

void main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Uso: dart scripts/test_meters_simple.dart <IP> [PORTA]');
    print('   Exemplo: dart scripts/test_meters_simple.dart 192.168.9.138');
    exit(1);
  }

  final ip = args[0];
  final port = args.length > 1 ? int.parse(args[1]) : 10023;

  print('🧪 Testando se o emulador responde /meters/1');
  print('📡 IP: $ip:$port');
  print('');

  // Cria socket UDP
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  final consoleAddress = InternetAddress(ip);

  print('✅ Socket criado na porta ${socket.port}');
  print('');

  int messagesReceived = 0;
  bool receivedMeters = false;

  // Escuta respostas
  socket.listen((event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram != null) {
        messagesReceived++;
        
        // Tenta decodificar como string
        try {
          final message = String.fromCharCodes(datagram.data);
          print('📨 Mensagem $messagesReceived: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
          
          if (message.contains('/meters/1')) {
            receivedMeters = true;
            print('');
            print('✅ ✅ ✅ RECEBEU /meters/1! ✅ ✅ ✅');
            print('   Tamanho: ${datagram.data.length} bytes');
            print('');
            
            // Mostra os primeiros bytes
            print('   Primeiros 32 bytes (hex):');
            final preview = datagram.data.take(32).toList();
            final hexStr = preview.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
            print('   $hexStr');
            print('');
          }
        } catch (e) {
          print('📨 Mensagem $messagesReceived: [dados binários, ${datagram.data.length} bytes]');
        }
      }
    }
  });

  // Envia /xremote
  print('📤 1. Enviando /xremote...');
  final xremoteBytes = _buildOSCMessage('/xremote');
  socket.send(xremoteBytes, consoleAddress, port);
  await Future.delayed(const Duration(milliseconds: 200));

  // Envia /meters/1 (5 vezes)
  print('📤 2. Enviando /meters/1 (5 vezes)...');
  for (int i = 0; i < 5; i++) {
    final metersBytes = _buildOSCMessage('/meters/1');
    socket.send(metersBytes, consoleAddress, port);
    print('   Tentativa ${i + 1}/5');
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // Aguarda respostas
  print('');
  print('⏳ Aguardando respostas por 2 segundos...');
  await Future.delayed(const Duration(seconds: 2));

  // Resultado
  print('');
  print('═══════════════════════════════════════════════════════');
  print('📊 RESULTADO:');
  print('═══════════════════════════════════════════════════════');
  print('   Mensagens recebidas: $messagesReceived');
  
  if (receivedMeters) {
    print('   Status: ✅ EMULADOR SUPORTA /meters/1!');
    print('');
    print('   🎉 O emulador está enviando dados de meters!');
    print('   📊 Os Peak Meters devem funcionar no app!');
  } else {
    print('   Status: ❌ EMULADOR NÃO RESPONDE /meters/1');
    print('');
    print('   ⚠️  O emulador X32 pode não implementar /meters/1');
    print('   💡 Soluções:');
    print('      1. Use um console M32/X32 real');
    print('      2. Use outro emulador que suporte meters');
    print('      3. Os Peak Meters vão ficar em 0 (sem animação)');
  }
  print('═══════════════════════════════════════════════════════');

  socket.close();
  exit(0);
}

/// Constrói uma mensagem OSC simples (sem dependências)
Uint8List _buildOSCMessage(String address) {
  final bytes = <int>[];
  
  // Address
  bytes.addAll(address.codeUnits);
  // Padding para múltiplo de 4
  while (bytes.length % 4 != 0) {
    bytes.add(0);
  }
  
  // Type tag string (vazio)
  bytes.addAll(','.codeUnits);
  bytes.add(0);
  bytes.add(0);
  bytes.add(0);
  
  return Uint8List.fromList(bytes);
}

