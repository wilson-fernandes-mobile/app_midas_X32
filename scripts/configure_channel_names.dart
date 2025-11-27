import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

/// Script para configurar nomes dos canais no emulador X32
///
/// Uso:
/// dart scripts/configure_channel_names.dart <IP> <PORTA>
///
/// Exemplo:
/// dart scripts/configure_channel_names.dart 192.168.9.138 10023

/// Cria uma mensagem OSC simples
Uint8List createOSCMessage(String address, String value) {
  final buffer = BytesBuilder();

  // Adiciona endereço OSC
  buffer.add(utf8.encode(address));
  // Padding para múltiplo de 4
  final addressPadding = 4 - (address.length % 4);
  for (int i = 0; i < addressPadding; i++) {
    buffer.addByte(0);
  }

  // Adiciona type tag (,s = string)
  buffer.add(utf8.encode(',s'));
  buffer.addByte(0);
  buffer.addByte(0);

  // Adiciona valor string
  buffer.add(utf8.encode(value));
  // Padding para múltiplo de 4
  final valuePadding = 4 - (value.length % 4);
  for (int i = 0; i < valuePadding; i++) {
    buffer.addByte(0);
  }

  return buffer.toBytes();
}

void main(List<String> args) async {
  if (args.length < 2) {
    print('❌ Uso: dart scripts/configure_channel_names.dart <IP> <PORTA>');
    print('   Exemplo: dart scripts/configure_channel_names.dart 192.168.9.138 10023');
    exit(1);
  }

  final ip = args[0];
  final port = int.tryParse(args[1]);

  if (port == null) {
    print('❌ Porta inválida: ${args[1]}');
    exit(1);
  }

  print('🎛️  Configurando nomes dos canais no X32/M32');
  print('   IP: $ip');
  print('   Porta: $port');
  print('');

  // Configuração dos nomes dos canais
  final channelNames = {
    1: 'lead male',
    2: 'lead feminino',
    3: 'mic man',
    4: 'Kick',
    5: 'Snare Top',
    6: 'Snare Btm',
    7: 'Hi-Hat',
    8: 'Snare 1',
    9: 'Snare 2',
    10: 'Snare 3',
    11: 'OH L',
    12: 'OH R',
    13: 'Bass DI',
    14: 'Guitar 1',
    15: 'Guitar 1',
    16: 'GTR Segunda',
    17: 'Keys L',
    18: 'Keys R',
    19: 'Synth',
    20: 'Acoustic',
    21: 'Percussion',
    22: 'Shaker',
    23: 'Playback L',
    24: 'Playback R',
    25: 'Click',
    26: 'FX Return 1',
    27: 'FX Return 2',
    28: 'Monitor',
    29: 'Talkback',
    30: 'Spare 1',
    31: 'Spare 2',
    32: 'Spare 3',
  };

  try {
    // Cria socket UDP
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    final targetAddress = InternetAddress(ip);

    print('📡 Enviando nomes dos canais...\n');

    int successCount = 0;
    int errorCount = 0;

    for (final entry in channelNames.entries) {
      final channelNumber = entry.key;
      final channelName = entry.value;
      final channelStr = channelNumber.toString().padLeft(2, '0');

      try {
        // Cria mensagem OSC
        final bytes = createOSCMessage(
          '/ch/$channelStr/config/name',
          channelName,
        );

        // Envia
        socket.send(bytes, targetAddress, port);

        print('✅ Canal $channelStr: "$channelName"');
        successCount++;

        // Aguarda um pouco entre comandos
        await Future.delayed(const Duration(milliseconds: 50));
      } catch (e) {
        print('❌ Erro no canal $channelStr: $e');
        errorCount++;
      }
    }

    print('');
    print('📊 RESULTADO:');
    print('   ✅ Sucesso: $successCount canais');
    print('   ❌ Erros: $errorCount canais');
    print('');

    if (successCount > 0) {
      print('🎉 Nomes configurados com sucesso!');
      print('');
      print('📱 Agora no app:');
      print('   1. Clique no botão ↻ (Refresh)');
      print('   2. Observe os ícones coloridos nos canais!');
      print('');
      print('🎨 Ícones esperados:');
      print('   🎤 (Azul)     - Vocal Lead, Vocal BV1, Vocal BV2');
      print('   🥁 (Vermelho) - Kick, Snare, Hi-Hat, Toms, OH');
      print('   🎸 (Roxo)     - Bass DI, Bass Amp');
      print('   🎸 (Laranja)  - Guitar 1, Guitar 2, Acoustic');
      print('   🎹 (Verde)    - Keys L/R, Synth');
      print('   🪘 (Cinza)    - Percussion, Shaker');
      print('   ▶️ (Amarelo)  - Playback L/R, Click');
      print('   ✨ (Cinza)    - FX Return 1/2');
      print('   🔊 (Cinza)    - Monitor');
    }

    socket.close();
  } catch (e) {
    print('❌ Erro: $e');
    exit(1);
  }
}

