import 'package:flutter/foundation.dart';
import '../models/preset.dart';
import '../models/channel.dart';
import '../models/mix_bus.dart';
import '../services/preset_service.dart';
import 'mixer_viewmodel.dart';

/// ViewModel para gerenciar presets
class PresetViewModel extends ChangeNotifier {
  final PresetService _presetService;
  final MixerViewModel _mixerViewModel;

  List<Preset> _presets = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Tracking de preset aplicado
  Preset? _appliedPreset;
  bool _hasUnsavedChanges = false;
  bool _autoSaveEnabled = true;
  int? _lastMixNumber; // Rastreia o último mix selecionado

  PresetViewModel(this._presetService, this._mixerViewModel) {
    loadPresets();
    // Escuta mudanças no MixerViewModel para detectar alterações
    _mixerViewModel.addListener(_onMixerChanged);
    // Inicializa com o mix atual
    _lastMixNumber = _mixerViewModel.selectedMix?.number;
  }

  List<Preset> get presets => _presets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Preset? get appliedPreset => _appliedPreset;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get autoSaveEnabled => _autoSaveEnabled;

  @override
  void dispose() {
    _mixerViewModel.removeListener(_onMixerChanged);
    super.dispose();
  }

  /// Ativa/desativa auto-save
  void setAutoSave(bool enabled) {
    _autoSaveEnabled = enabled;
    notifyListeners();
  }

  /// Callback quando o mixer muda (faders alterados ou mix trocado)
  void _onMixerChanged() {
    final currentMixNumber = _mixerViewModel.selectedMix?.number;

    // Verifica se o mix foi trocado
    if (_lastMixNumber != null && currentMixNumber != _lastMixNumber) {
      if (kDebugMode) {
        print('🔄 Mix trocado de $_lastMixNumber para $currentMixNumber - Desativando preset');
      }
      // Limpa o preset aplicado quando trocar de mix
      _appliedPreset = null;
      _hasUnsavedChanges = false;
      _lastMixNumber = currentMixNumber;
      notifyListeners();
      return;
    }

    // Atualiza o último mix
    _lastMixNumber = currentMixNumber;

    if (_appliedPreset == null || !_autoSaveEnabled) return;

    // Verifica se houve mudanças nos níveis
    if (_hasChangesFromAppliedPreset()) {
      _hasUnsavedChanges = true;
      notifyListeners();

      // Auto-save após 2 segundos de inatividade
      _scheduleAutoSave();
    }
  }

  /// Verifica se há mudanças em relação ao preset aplicado
  bool _hasChangesFromAppliedPreset() {
    if (_appliedPreset == null) return false;

    final selectedMix = _mixerViewModel.selectedMix;
    if (selectedMix == null) return false;

    // Verifica se o bus level mudou
    if ((selectedMix.level - _appliedPreset!.busLevel).abs() > 0.001) {
      return true;
    }

    // Verifica se algum canal mudou
    for (final channel in _mixerViewModel.channels) {
      final presetLevel = _appliedPreset!.channelLevels[channel.number];
      if (presetLevel != null) {
        if ((channel.level - presetLevel).abs() > 0.001) {
          return true;
        }
      }
    }

    return false;
  }

  // Timer para auto-save
  Future<void>? _autoSaveTimer;

  /// Agenda auto-save após 2 segundos
  void _scheduleAutoSave() {
    _autoSaveTimer?.ignore(); // Cancela timer anterior

    _autoSaveTimer = Future.delayed(const Duration(seconds: 2), () async {
      if (_appliedPreset != null && _hasUnsavedChanges && _autoSaveEnabled) {
        await _performAutoSave();
      }
    });
  }

  /// Executa o auto-save
  Future<void> _performAutoSave() async {
    if (_appliedPreset == null) return;

    try {
      final selectedMix = _mixerViewModel.selectedMix;
      if (selectedMix == null) return;

      // Captura os níveis atuais
      final channelLevels = <int, double>{};
      for (final channel in _mixerViewModel.channels) {
        channelLevels[channel.number] = channel.level;
      }

      // Atualiza o preset
      final updatedPreset = _appliedPreset!.copyWith(
        mixNumber: selectedMix.number,
        channelLevels: channelLevels,
        busLevel: selectedMix.level,
      );

      final success = await _presetService.savePreset(updatedPreset);

      if (success) {
        _appliedPreset = updatedPreset;
        _hasUnsavedChanges = false;
        await loadPresets(); // Recarrega lista

        if (kDebugMode) {
          print('💾 Auto-save: Preset "${_appliedPreset!.name}" atualizado!');
        }

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no auto-save: $e');
      }
    }
  }

  /// Carrega todos os presets
  Future<void> loadPresets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _presets = await _presetService.loadPresets();
      if (kDebugMode) {
        print('✅ ${_presets.length} presets carregados');
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar presets: $e';
      if (kDebugMode) {
        print('❌ $_errorMessage');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Salva o estado atual como um novo preset
  Future<bool> saveCurrentAsPreset(String name) async {
    try {
      final selectedMix = _mixerViewModel.selectedMix;
      if (selectedMix == null) {
        _errorMessage = 'Nenhum mix selecionado';
        notifyListeners();
        return false;
      }

      // Verifica se o nome já existe
      final nameExists = await _presetService.presetNameExists(name);
      if (nameExists) {
        _errorMessage = 'Já existe um preset com este nome';
        notifyListeners();
        return false;
      }

      // Captura os níveis de todos os canais
      final channelLevels = <int, double>{};
      for (final channel in _mixerViewModel.channels) {
        channelLevels[channel.number] = channel.level;
      }

      // Cria o preset
      final preset = Preset.create(
        name: name,
        mixNumber: selectedMix.number,
        channelLevels: channelLevels,
        busLevel: selectedMix.level,
      );

      // Salva
      final success = await _presetService.savePreset(preset);

      if (success) {
        await loadPresets(); // Recarrega a lista
        _errorMessage = null;
        if (kDebugMode) {
          print('✅ Preset "$name" salvo com sucesso!');
        }
      } else {
        _errorMessage = 'Erro ao salvar preset';
      }

      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao salvar preset: $e';
      if (kDebugMode) {
        print('❌ $_errorMessage');
      }
      notifyListeners();
      return false;
    }
  }

  /// Atualiza um preset existente com o estado atual
  Future<bool> updatePreset(String presetId, {String? newName}) async {
    try {
      final existingPreset = await _presetService.getPresetById(presetId);
      if (existingPreset == null) {
        _errorMessage = 'Preset não encontrado';
        notifyListeners();
        return false;
      }

      final selectedMix = _mixerViewModel.selectedMix;
      if (selectedMix == null) {
        _errorMessage = 'Nenhum mix selecionado';
        notifyListeners();
        return false;
      }

      // Se está mudando o nome, verifica se já existe
      if (newName != null && newName != existingPreset.name) {
        final nameExists = await _presetService.presetNameExists(newName, excludeId: presetId);
        if (nameExists) {
          _errorMessage = 'Já existe um preset com este nome';
          notifyListeners();
          return false;
        }
      }

      // Captura os níveis atuais
      final channelLevels = <int, double>{};
      for (final channel in _mixerViewModel.channels) {
        channelLevels[channel.number] = channel.level;
      }

      // Atualiza o preset
      final updatedPreset = existingPreset.copyWith(
        name: newName,
        mixNumber: selectedMix.number,
        channelLevels: channelLevels,
        busLevel: selectedMix.level,
      );

      final success = await _presetService.savePreset(updatedPreset);

      if (success) {
        await loadPresets();
        _errorMessage = null;
        if (kDebugMode) {
          print('✅ Preset atualizado com sucesso!');
        }
      } else {
        _errorMessage = 'Erro ao atualizar preset';
      }

      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar preset: $e';
      if (kDebugMode) {
        print('❌ $_errorMessage');
      }
      notifyListeners();
      return false;
    }
  }

  /// Deleta um preset
  Future<bool> deletePreset(String presetId) async {
    try {
      final success = await _presetService.deletePreset(presetId);

      if (success) {
        await loadPresets();
        _errorMessage = null;
        if (kDebugMode) {
          print('✅ Preset deletado com sucesso!');
        }
      } else {
        _errorMessage = 'Erro ao deletar preset';
      }

      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao deletar preset: $e';
      if (kDebugMode) {
        print('❌ $_errorMessage');
      }
      notifyListeners();
      return false;
    }
  }

  /// Aplica um preset na mesa (envia comandos OSC)
  Future<bool> applyPreset(String presetId) async {
    try {
      final preset = await _presetService.getPresetById(presetId);
      if (preset == null) {
        _errorMessage = 'Preset não encontrado';
        notifyListeners();
        return false;
      }

      final selectedMix = _mixerViewModel.selectedMix;
      if (selectedMix == null) {
        _errorMessage = 'Nenhum mix selecionado';
        notifyListeners();
        return false;
      }

      if (kDebugMode) {
        print('🎚️  Aplicando preset "${preset.name}" no Mix ${selectedMix.number}...');
      }

      // Aplica o volume do bus
      await _mixerViewModel.setBusLevel(preset.busLevel);

      // Aplica os níveis de cada canal
      for (final entry in preset.channelLevels.entries) {
        final channelNumber = entry.key;
        final level = entry.value;
        await _mixerViewModel.setChannelLevel(channelNumber, level);
      }

      // Marca este preset como aplicado
      _appliedPreset = preset;
      _hasUnsavedChanges = false;
      _lastMixNumber = selectedMix.number; // Atualiza o mix rastreado
      _errorMessage = null;

      if (kDebugMode) {
        print('✅ Preset "${preset.name}" aplicado com sucesso!');
        if (_autoSaveEnabled) {
          print('💾 Auto-save ativado para este preset');
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao aplicar preset: $e';
      if (kDebugMode) {
        print('❌ $_errorMessage');
      }
      notifyListeners();
      return false;
    }
  }

  /// Limpa o preset aplicado (desativa auto-save)
  void clearAppliedPreset() {
    _appliedPreset = null;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  /// Obtém presets filtrados por mix
  List<Preset> getPresetsByMix(int mixNumber) {
    return _presets.where((p) => p.mixNumber == mixNumber).toList();
  }

  /// Limpa a mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

