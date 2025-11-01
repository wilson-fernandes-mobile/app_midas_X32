# 📊 Implementação de Meters (VU/Peak Meters) - M32/X32

## 🎯 O Que São Meters?

**Meters** são os **indicadores de nível de áudio em tempo real** que mostram o sinal passando pelos canais, independente da posição do fader.

### Diferença Entre Level e Meters:

| Característica | `/ch/XX/mix/YY/level` (Fader) | `/meters/1` (Audio Meters) |
|----------------|-------------------------------|----------------------------|
| **O que é** | Posição do fader (0.0-1.0) | Nível de áudio real (VU/Peak) |
| **Você controla** | ✅ Sim (envia e recebe) | ❌ Não (só recebe) |
| **Atualização** | Só quando move o fader | ~20-40x por segundo (automático) |
| **Uso** | Controle de volume | Visualização de áudio (VU meter) |
| **Formato** | Float (0.0-1.0) | Blob binário (16-bit signed int) |

---

## 🔧 Como Funciona

### 1. Comandos OSC de Meters

```
/meters/1    - Retorna níveis de todos os canais (1-32)
/meters/2    - Retorna níveis dos buses (1-16)
/meters/3    - Retorna níveis dos aux/fx
/meters/4    - Retorna níveis dos outputs
```

### 2. Formato da Resposta

O console envia um **blob binário** com todos os níveis de uma vez:

```
Byte 0-1:   Canal 1  (16-bit big-endian signed integer)
Byte 2-3:   Canal 2
Byte 4-5:   Canal 3
...
Byte 62-63: Canal 32
```

**Total**: 64 bytes (32 canais × 2 bytes)

### 3. Conversão de Valores

```dart
// Combina 2 bytes em um valor de 16-bit (big-endian)
final highByte = blob[i];
final lowByte = blob[i + 1];
final rawValue = (highByte << 8) | lowByte;

// Converte de signed 16-bit para float (0.0-1.0)
final signedValue = rawValue > 32767 ? rawValue - 65536 : rawValue;
final normalizedValue = (signedValue / 32768.0).clamp(0.0, 1.0);
```

### 4. Frequência de Atualização

- **Recomendado**: 20-40 Hz (50ms - 25ms)
- **Implementado**: 20 Hz (50ms)
- **Motivo**: Balanceia responsividade vs. carga de rede

---

## 📁 Arquivos Modificados

### 1. `lib/services/osc_service.dart`

**Adicionado:**
- `requestMeters()` - Solicita meters do console
- `parseMetersBlob(List<int> blob)` - Decodifica blob binário

```dart
/// Solicita meters (níveis de áudio em tempo real)
Future<void> requestMeters() async {
  await sendMessage('/meters/1');
}

/// Processa blob binário de meters
Map<int, double> parseMetersBlob(List<int> blob) {
  final meters = <int, double>{};
  
  for (int i = 0; i < blob.length - 1; i += 2) {
    final channelIndex = i ~/ 2;
    final highByte = blob[i];
    final lowByte = blob[i + 1];
    final rawValue = (highByte << 8) | lowByte;
    final signedValue = rawValue > 32767 ? rawValue - 65536 : rawValue;
    final normalizedValue = (signedValue / 32768.0).clamp(0.0, 1.0);
    
    final channelNumber = channelIndex + 1;
    if (channelNumber <= 32) {
      meters[channelNumber] = normalizedValue;
    }
  }
  
  return meters;
}
```

### 2. `lib/viewmodels/mixer_viewmodel.dart`

**Adicionado:**
- `Timer? _metersTimer` - Timer para polling periódico
- `_updateChannelPeakLevels(Map<int, double> meters)` - Atualiza peak levels
- `startMetersPolling()` - Inicia polling de meters
- `stopMetersPolling()` - Para polling de meters

**Modificado:**
- `_handleOSCMessage()` - Processa mensagens `/meters/1`

```dart
// Processa meters (níveis de áudio em tempo real)
if (address == '/meters/1' && message.arguments.isNotEmpty) {
  final arg = message.arguments[0];
  
  List<int>? blob;
  if (arg is List<int>) {
    blob = arg;
  } else if (arg.runtimeType.toString().contains('Uint8List')) {
    blob = List<int>.from(arg as Iterable);
  }
  
  if (blob != null) {
    final meters = _oscService.parseMetersBlob(blob);
    _updateChannelPeakLevels(meters);
  }
  return;
}
```

### 3. `lib/views/mixer_screen.dart`

**Modificado:**
- `initState()` - Inicia polling de meters
- `dispose()` - Para polling de meters
- Peak Meter - Usa `channel.peakLevel` (vem de `/meters/1`)

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadInitialMix();
    // Inicia polling de meters (VU/Peak meters em tempo real)
    context.read<MixerViewModel>().startMetersPolling();
  });
}

@override
void dispose() {
  // Para polling de meters quando sair da tela
  context.read<MixerViewModel>().stopMetersPolling();
  super.dispose();
}
```

---

## 🧪 Como Testar

### 1. Teste com Script (Sem App)

```bash
# Testa recebimento de meters
dart scripts/test_meters.dart 192.168.9.138

# Ou com porta customizada
dart scripts/test_meters.dart 192.168.9.138 10023
```

**Saída esperada:**
```
📊 Recebeu /meters/1
   Tamanho do blob: 64 bytes
   Canais esperados: 32

   Primeiros 8 canais:
   Ch 1: ████████████░░░░░░░░  60% (-3.0 dB)
   Ch 2: ██████░░░░░░░░░░░░░░  30% (-9.0 dB)
   Ch 3: ░░░░░░░░░░░░░░░░░░░░   0% (-∞ dB)
   ...
```

### 2. Teste no App

1. **Execute o app:**
   ```bash
   flutter run
   ```

2. **Conecte ao emulador:**
   - IP: `192.168.9.138`
   - Porta: `10023`

3. **Abra o Mixer Screen:**
   - Mix 1 será carregado automaticamente
   - Meters começam a atualizar automaticamente

4. **No Emulador X32:**
   - Abra o emulador
   - Vá em **Meters** → **Channel Meters**
   - Mova os faders ou gere sinal de teste
   - **Observe os Peak Meters no app atualizando em tempo real!**

5. **Logs esperados:**
   ```
   📊 Iniciando polling de meters (50ms = ~20Hz)
   📊 Meters: Ch1=0.60, Ch2=0.30, ... (32 canais)
   ```

---

## 📊 Fluxo de Dados

```
┌─────────────────┐
│  MixerScreen    │
│   (initState)   │
└────────┬────────┘
         │
         │ startMetersPolling()
         ▼
┌─────────────────┐
│ MixerViewModel  │
│  Timer (50ms)   │
└────────┬────────┘
         │
         │ requestMeters()
         ▼
┌─────────────────┐
│   OSCService    │
│ sendMessage()   │
└────────┬────────┘
         │
         │ /meters/1
         ▼
┌─────────────────┐
│  M32/X32 Console│
│   (Emulator)    │
└────────┬────────┘
         │
         │ Blob binário (64 bytes)
         ▼
┌─────────────────┐
│   OSCService    │
│ messageStream   │
└────────┬────────┘
         │
         │ OSCMessage
         ▼
┌─────────────────┐
│ MixerViewModel  │
│_handleOSCMessage│
└────────┬────────┘
         │
         │ parseMetersBlob()
         ▼
┌─────────────────┐
│   OSCService    │
│ Map<int,double> │
└────────┬────────┘
         │
         │ meters
         ▼
┌─────────────────┐
│ MixerViewModel  │
│_updateChannelPeakLevels
└────────┬────────┘
         │
         │ notifyListeners()
         ▼
┌─────────────────┐
│  MixerScreen    │
│   Peak Meter    │
│  (atualiza UI)  │
└─────────────────┘
```

---

## ⚡ Performance

### Carga de Rede

- **Frequência**: 20 Hz (50ms)
- **Tamanho da requisição**: ~20 bytes (`/meters/1`)
- **Tamanho da resposta**: ~80 bytes (64 bytes de dados + header OSC)
- **Total por segundo**: ~2 KB/s (upload + download)

### Carga de CPU

- **Parsing**: Muito leve (loop simples de 32 iterações)
- **UI Update**: Otimizado com `notifyListeners()` único
- **Impacto**: Mínimo (<1% CPU em dispositivos modernos)

---

## 🎯 Próximos Passos (Opcional)

### 1. Peak Hold
Adicionar "peak hold" (pico máximo fica visível por alguns segundos):

```dart
class Channel {
  final double peakLevel;
  final double peakHold;      // Novo
  final DateTime? peakHoldTime; // Novo
}
```

### 2. Meters de Buses
Implementar `/meters/2` para mostrar níveis dos buses:

```dart
Future<void> requestBusMeters() async {
  await sendMessage('/meters/2');
}
```

### 3. Configuração de Frequência
Permitir usuário ajustar frequência de atualização:

```dart
void startMetersPolling({int intervalMs = 50}) {
  _metersTimer = Timer.periodic(Duration(milliseconds: intervalMs), ...);
}
```

---

## 📚 Referências

- **X32/M32 OSC Protocol**: [UNOFFICIAL X32/M32 OSC REMOTE PROTOCOL](https://tostibroeders.nl/wp-content/uploads/2020/02/X32-OSC.pdf)
- **OSC Specification**: [OpenSoundControl.org](http://opensoundcontrol.org/)
- **X32 Emulator**: [Patrick Maillot's X32 Emulator](https://sites.google.com/site/patrickmaillot/x32)

