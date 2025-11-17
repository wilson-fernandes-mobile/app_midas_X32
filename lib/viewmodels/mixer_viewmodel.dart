import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:osc/osc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/channel.dart';
import '../models/mix_bus.dart';
import '../services/osc_service.dart';

/// ViewModel para controlar o mixer
class MixerViewModel extends ChangeNotifier {
  final OSCService _oscService;

  List<Channel> _channels = [];
  MixBus? _selectedMix;
  bool _isLoading = false;
  StreamSubscription<OSCMessage>? _oscSubscription;
  Timer? _metersTimer;
  Timer? _renewTimer;

  MixerViewModel(this._oscService) {
    _initializeChannels();
    _listenToOSCMessages();
    // NÃO carrega o Mix aqui - ainda não está conectado!
    // O Mix será carregado quando o MixerScreen chamar loadLastSelectedMix()
  }

  /// Carrega o último Mix selecionado (chamado pelo MixerScreen após conectar)
  Future<void> loadLastSelectedMix() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMixNumber = prefs.getInt('last_selected_mix');

      if (lastMixNumber != null && lastMixNumber >= 1 && lastMixNumber <= 16) {
        if (kDebugMode) {
          print('💾 Carregando último Mix selecionado: Mix $lastMixNumber');
        }
        // Seleciona o último mix automaticamente
        await selectMix(lastMixNumber);
      } else {
        if (kDebugMode) {
          print('ℹ️  Nenhum Mix salvo anteriormente - carregando Mix 1 por padrão');
        }
        // Carrega Mix 1 por padrão
        await selectMix(1);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️  Erro ao carregar último Mix: $e');
      }
    }
  }



  /// Salva o Mix selecionado
  Future<void> _saveSelectedMix(int mixNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_selected_mix', mixNumber);

      if (kDebugMode) {
        print('💾 Mix $mixNumber salvo como último selecionado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️  Erro ao salvar Mix: $e');
      }
    }
  }

  List<Channel> get channels => _channels;
  MixBus? get selectedMix => _selectedMix;
  bool get isLoading => _isLoading;

  /// Inicializa os 32 canais
  void _initializeChannels() {
    _channels = List.generate(
      32,
      (index) => Channel(
        number: index + 1,
        name: 'Ch ${index + 1}',
      ),
    );
  }

  /// Escuta mensagens OSC do console
  void _listenToOSCMessages() {
    _oscSubscription = _oscService.messageStream.listen((message) {
      _handleOSCMessage(message);
    });
  }

  /// Processa mensagens OSC recebidas
  void _handleOSCMessage(OSCMessage message) {
    final address = message.address;

    // Debug: mostra mensagens recebidas (exceto meters para não poluir)
    if (kDebugMode && !address.startsWith('/meters/')) {
      print('🎛️ MixerVM recebeu: $address ${message.arguments}');
    }

    // Processa meters dos canais (níveis de áudio em tempo real)
    if (address == '/meters/1' && message.arguments.isNotEmpty) {
      final arg = message.arguments[0];

      // O argumento pode ser Uint8List ou List<int>
      List<int>? blob;
      if (arg is List<int>) {
        blob = arg;
      } else if (arg.runtimeType.toString().contains('Uint8List')) {
        // Converte Uint8List para List<int>
        blob = List<int>.from(arg as Iterable);
      }

      if (blob != null) {
        final meters = _oscService.parseMetersBlob(blob);
        _updateChannelPeakLevels(meters);
      }
      return; // Não precisa processar mais nada
    }

    // Processa meters dos buses (níveis de áudio em tempo real)
    if (address == '/meters/2' && message.arguments.isNotEmpty) {
      final arg = message.arguments[0];

      // O argumento pode ser Uint8List ou List<int>
      List<int>? blob;
      if (arg is List<int>) {
        blob = arg;
      } else if (arg.runtimeType.toString().contains('Uint8List')) {
        // Converte Uint8List para List<int>
        blob = List<int>.from(arg as Iterable);
      }

      if (blob != null) {
        final busMeters = _oscService.parseMetersBlob(blob);
        _updateBusPeakLevels(busMeters);
      }
      return; // Não precisa processar mais nada
    }

    // Exemplo: /ch/01/config/name
    if (address.contains('/config/name')) {
      final parts = address.split('/');
      if (parts.length >= 3 && parts[1] == 'ch') {
        final channelNum = int.tryParse(parts[2]);
        if (channelNum != null && message.arguments.isNotEmpty) {
          final name = message.arguments[0].toString();
          if (kDebugMode) {
            print('📝 Atualizando nome do canal $channelNum: $name');
          }
          _updateChannelName(channelNum, name);
        }
      }
    }

    // Exemplo: /ch/01/mix/fader (nível principal Main LR)
    if (address.contains('/ch/') && address.endsWith('/mix/fader')) {
      final parts = address.split('/');
      if (parts.length >= 3 && parts[1] == 'ch') {
        final channelNum = int.tryParse(parts[2]);
        if (channelNum != null && message.arguments.isNotEmpty) {
          final level = (message.arguments[0] as num).toDouble();
          if (kDebugMode) {
            print('🎚️ Atualizando nível principal (Main LR) do canal $channelNum: $level');
          }
          _updateChannelLevel(channelNum, level);
        }
      }
    }

    // Exemplo: /ch/01/mix/on (mute principal Main LR)
    if (address.contains('/ch/') && address.endsWith('/mix/on')) {
      final parts = address.split('/');
      if (parts.length >= 3 && parts[1] == 'ch') {
        final channelNum = int.tryParse(parts[2]);
        if (channelNum != null && message.arguments.isNotEmpty) {
          final isOn = (message.arguments[0] as num).toInt() == 1;
          final isMuted = !isOn; // on=1 significa não mutado, on=0 significa mutado
          if (kDebugMode) {
            print('🔇 Atualizando mute principal (Main LR) do canal $channelNum: ${isMuted ? "MUTED" : "ON"}');
          }
          _updateChannelMute(channelNum, isMuted);
        }
      }
    }

    // Exemplo: /ch/01/mix/01/level (nível em um mix específico)
    if (address.contains('/mix/') && address.endsWith('/level') && !address.endsWith('/mix/fader')) {
      final parts = address.split('/');
      if (parts.length >= 5 && parts[1] == 'ch') {
        final channelNum = int.tryParse(parts[2]);
        final mixNum = int.tryParse(parts[4]);
        if (channelNum != null && mixNum != null && message.arguments.isNotEmpty) {
          // Só atualiza se for o mix selecionado
          if (_selectedMix != null && mixNum == _selectedMix!.number) {
            final level = (message.arguments[0] as num).toDouble();
            if (kDebugMode) {
              print('🎚️ Atualizando nível do canal $channelNum no mix $mixNum: $level');
            }
            _updateChannelLevel(channelNum, level);
          }
        }
      }
    }

    // Exemplo: /bus/01/mix/fader (fader master do bus/mix)
    if (address.contains('/bus/') && address.endsWith('/fader')) {
      final parts = address.split('/');
      if (parts.length >= 3 && parts[1] == 'bus') {
        final busNum = int.tryParse(parts[2]);
        if (busNum != null && message.arguments.isNotEmpty) {
          // Só atualiza se for o mix selecionado
          if (_selectedMix != null && busNum == _selectedMix!.number) {
            final level = (message.arguments[0] as num).toDouble();
            if (kDebugMode) {
              print('🎛️ Atualizando nível do BUS $busNum (Mix $busNum): $level');
            }
            _updateBusLevel(level);
          }
        }
      }
    }
  }

  /// Atualiza o nome de um canal
  void _updateChannelName(int channelNumber, String name) {
    final index = channelNumber - 1;
    if (index >= 0 && index < _channels.length) {
      _channels[index] = _channels[index].copyWith(name: name);
      notifyListeners();
    }
  }

  /// Atualiza o nível de um canal
  void _updateChannelLevel(int channelNumber, double level) {
    final index = channelNumber - 1;
    if (index >= 0 && index < _channels.length) {
      _channels[index] = _channels[index].copyWith(level: level);
      notifyListeners();
    }
  }

  /// Atualiza o mute de um canal
  void _updateChannelMute(int channelNumber, bool mute) {
    final index = channelNumber - 1;
    if (index >= 0 && index < _channels.length) {
      _channels[index] = _channels[index].copyWith(mute: mute);
      notifyListeners();
    }
  }

  /// Atualiza os peak levels de múltiplos canais (vindo dos meters)
  void _updateChannelPeakLevels(Map<int, double> meters) {
    bool hasChanges = false;

    for (final entry in meters.entries) {
      final channelNumber = entry.key;
      final peakLevel = entry.value;
      final index = channelNumber - 1;

      if (index >= 0 && index < _channels.length) {
        _channels[index] = _channels[index].copyWith(peakLevel: peakLevel);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Atualiza os peak levels dos buses (vindo dos meters)
  void _updateBusPeakLevels(Map<int, double> busMeters) {
    if (_selectedMix == null) return;

    for (final entry in busMeters.entries) {
      final busNumber = entry.key;
      final peakLevel = entry.value;

      // Só atualiza se for o bus/mix selecionado
      if (busNumber == _selectedMix!.number) {
        _selectedMix = _selectedMix!.copyWith(peakLevel: peakLevel);
        notifyListeners();
        return;
      }
    }
  }

  /// Atualiza o nível do bus (fader master do mix)
  void _updateBusLevel(double level) {
    if (_selectedMix != null) {
      _selectedMix = _selectedMix!.copyWith(level: level);
      notifyListeners();
    }
  }

  /// Seleciona um mix (bus de monitor)
  Future<void> selectMix(int mixNumber) async {
    if (kDebugMode) {
      print('🎯 Selecionando Mix $mixNumber...');
    }

    _isLoading = true;
    notifyListeners();

    _selectedMix = MixBus(
      number: mixNumber,
      name: 'Mix $mixNumber',
      channels: List.generate(32, (i) => i + 1),
    );

    if (kDebugMode) {
      print('📡 Solicitando informações do Mix $mixNumber...');
    }

    // Solicita informações do mix
    await _oscService.requestMixInfo(mixNumber);
    await _oscService.requestBusName(mixNumber);

    // Salva o Mix selecionado
    await _saveSelectedMix(mixNumber);

    if (kDebugMode) {
      print('✅ Mix $mixNumber selecionado!');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Altera o volume de um canal
  Future<void> setChannelLevel(int channelNumber, double level) async {
    if (kDebugMode) {
      print('🎚️ setChannelLevel chamado: Canal $channelNumber = $level');
    }

    if (_selectedMix == null) {
      if (kDebugMode) {
        print('⚠️  selectedMix é null! Não pode enviar.');
      }
      return;
    }

    if (kDebugMode) {
      print('📤 Enviando para Mix ${_selectedMix!.number}: Canal $channelNumber = $level');
    }

    // Atualiza localmente primeiro (feedback imediato)
    _updateChannelLevel(channelNumber, level);

    // Envia para o console
    await _oscService.setChannelLevel(
      channelNumber,
      _selectedMix!.number,
      level,
    );

    if (kDebugMode) {
      print('✅ Comando enviado!');
    }
  }

  /// Altera o pan de um canal
  Future<void> setChannelPan(int channelNumber, double pan) async {
    if (_selectedMix == null) return;

    final index = channelNumber - 1;
    if (index >= 0 && index < _channels.length) {
      _channels[index] = _channels[index].copyWith(pan: pan);
      notifyListeners();
    }

    // Converte pan de -1.0/1.0 para 0.0/1.0 (formato OSC)
    final oscPan = (pan + 1.0) / 2.0;
    await _oscService.setChannelPan(
      channelNumber,
      _selectedMix!.number,
      oscPan,
    );
  }

  /// Alterna mute de um canal
  Future<void> toggleChannelMute(int channelNumber) async {
    final index = channelNumber - 1;
    if (index >= 0 && index < _channels.length) {
      final newMute = !_channels[index].mute;
      _channels[index] = _channels[index].copyWith(mute: newMute);
      notifyListeners();

      // M32 usa level 0.0 para mute
      if (newMute) {
        await setChannelLevel(channelNumber, 0.0);
      }
    }
  }

  /// Altera o volume geral do bus
  Future<void> setBusLevel(double level) async {
    if (_selectedMix == null) return;

    // Atualiza localmente
    _selectedMix = _selectedMix!.copyWith(level: level);
    notifyListeners();

    // Envia para o console
    await _oscService.setBusLevel(_selectedMix!.number, level);
  }

  /// Recarrega informações do mix atual
  Future<void> refresh() async {
    if (_selectedMix != null) {
      await selectMix(_selectedMix!.number);
    }
  }

  /// Inicia a solicitação periódica de meters (VU/Peak meters em tempo real)
  void startMetersPolling({bool demoMode = false}) {
    // Cancela timers anteriores se existirem
    _metersTimer?.cancel();
    _renewTimer?.cancel();

    if (kDebugMode) {
      print('📊 Iniciando polling de meters (50ms = ~20Hz)');
      if (demoMode) {
        print('   🎭 MODO DEMO: Simulando meters (emulador não suporta)');
      } else {
        print('   🎚️  MODO REAL: Usando meters do console');
      }
    }

    if (demoMode) {
      // MODO DEMO: Simula meters com valores aleatórios
      _metersTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        _simulateDemoMeters();
      });
    } else {
      // MODO REAL: Solicita meters do console
      _metersTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        _oscService.requestMeters();
      });

      // IMPORTANTE: X32/M32 requer renovação de meters a cada 10 segundos
      // Envia /renew a cada 9 segundos para garantir
      _renewTimer = Timer.periodic(const Duration(seconds: 9), (timer) {
        _oscService.renewMeters();
      });

      // Envia o primeiro renew imediatamente
      _oscService.renewMeters();
    }
  }

  /// Simula meters para demonstração (quando emulador não suporta)
  void _simulateDemoMeters() {
    final meters = <int, double>{};
    final random = DateTime.now().millisecondsSinceEpoch % 100 / 100.0;

    // Simula meters dos canais
    for (int ch = 1; ch <= 32; ch++) {
      // Simula níveis variados baseados no fader atual
      final channel = _channels[ch - 1];
      final baseLevel = channel.level;

      // Adiciona variação aleatória (±20%)
      final variation = (random - 0.5) * 0.4;
      final simulatedLevel = (baseLevel + variation).clamp(0.0, 1.0);

      meters[ch] = simulatedLevel;
    }

    _updateChannelPeakLevels(meters);

    // Simula meters do bus selecionado
    if (_selectedMix != null) {
      final busMeters = <int, double>{};
      final baseLevel = _selectedMix!.level;

      // Adiciona variação aleatória (±20%)
      final variation = (random - 0.5) * 0.4;
      final simulatedLevel = (baseLevel + variation).clamp(0.0, 1.0);

      busMeters[_selectedMix!.number] = simulatedLevel;
      _updateBusPeakLevels(busMeters);
    }
  }

  /// Para a solicitação periódica de meters
  void stopMetersPolling() {
    if (kDebugMode) {
      print('⏹️ Parando polling de meters');
    }

    _metersTimer?.cancel();
    _metersTimer = null;
    _renewTimer?.cancel();
    _renewTimer = null;
  }

  @override
  void dispose() {
    _metersTimer?.cancel();
    _oscSubscription?.cancel();
    super.dispose();
  }
}

