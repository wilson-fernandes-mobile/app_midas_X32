import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/preset.dart';

/// Serviço para gerenciar persistência de presets
class PresetService {
  static const String _presetsKey = 'saved_presets';

  /// Carrega todos os presets salvos
  Future<List<Preset>> loadPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getStringList(_presetsKey) ?? [];

      if (kDebugMode) {
        print('Carregando ${presetsJson.length} presets salvos...');
      }

      final presets = presetsJson
          .map((jsonString) {
            try {
              return Preset.fromJsonString(jsonString);
            } catch (e) {
              if (kDebugMode) {
                print('Erro ao carregar preset: $e');
              }
              return null;
            }
          })
          .whereType<Preset>()
          .toList();

      // Ordena por data de atualização (mais recente primeiro)
      presets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      if (kDebugMode) {
        print('${presets.length} presets carregados com sucesso');
      }

      return presets;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar presets: $e');
      }
      return [];
    }
  }

  /// Salva um novo preset
  Future<bool> savePreset(Preset preset) async {
    try {
      final presets = await loadPresets();

      // Verifica se já existe um preset com o mesmo ID
      final existingIndex = presets.indexWhere((p) => p.id == preset.id);

      if (existingIndex >= 0) {
        // Atualiza preset existente
        presets[existingIndex] = preset;
        if (kDebugMode) {
          print('📝 Atualizando preset existente: ${preset.name}');
        }
      } else {
        // Adiciona novo preset
        presets.add(preset);
        if (kDebugMode) {
          print('Salvando novo preset: ${preset.name}');
        }
      }

      // Salva todos os presets
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = presets.map((p) => p.toJsonString()).toList();
      await prefs.setStringList(_presetsKey, presetsJson);

      if (kDebugMode) {
        print('Preset salvo com sucesso!');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar preset: $e');
      }
      return false;
    }
  }

  /// Deleta um preset
  Future<bool> deletePreset(String presetId) async {
    try {
      final presets = await loadPresets();

      // Remove o preset com o ID especificado
      final initialLength = presets.length;
      presets.removeWhere((p) => p.id == presetId);

      if (presets.length == initialLength) {
        if (kDebugMode) {
          print('Preset não encontrado: $presetId');
        }
        return false;
      }

      // Salva a lista atualizada
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = presets.map((p) => p.toJsonString()).toList();
      await prefs.setStringList(_presetsKey, presetsJson);

      if (kDebugMode) {
        print('🗑️  Preset deletado com sucesso!');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao deletar preset: $e');
      }
      return false;
    }
  }

  /// Busca um preset por ID
  Future<Preset?> getPresetById(String presetId) async {
    try {
      final presets = await loadPresets();
      return presets.firstWhere(
        (p) => p.id == presetId,
        orElse: () => throw Exception('Preset não encontrado'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Preset não encontrado: $presetId');
      }
      return null;
    }
  }

  /// Busca presets por número de mix
  Future<List<Preset>> getPresetsByMix(int mixNumber) async {
    final presets = await loadPresets();
    return presets.where((p) => p.mixNumber == mixNumber).toList();
  }

  /// Verifica se existe um preset com o nome especificado
  Future<bool> presetNameExists(String name, {String? excludeId}) async {
    final presets = await loadPresets();
    return presets.any((p) => p.name.toLowerCase() == name.toLowerCase() && p.id != excludeId);
  }

  /// Limpa todos os presets (útil para testes)
  Future<bool> clearAllPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_presetsKey);

      if (kDebugMode) {
        print('Todos os presets foram removidos');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao limpar presets: $e');
      }
      return false;
    }
  }

  /// Exporta todos os presets como JSON (para backup)
  Future<String?> exportPresetsAsJson() async {
    try {
      final presets = await loadPresets();
      final presetsJson = presets.map((p) => p.toJson()).toList();
      return jsonEncode(presetsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao exportar presets: $e');
      }
      return null;
    }
  }

  /// Importa presets de JSON (para restaurar backup)
  Future<bool> importPresetsFromJson(String jsonString) async {
    try {
      final List<dynamic> presetsJson = jsonDecode(jsonString);
      final presets = presetsJson
          .map((json) => Preset.fromJson(json as Map<String, dynamic>))
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final presetsJsonStrings = presets.map((p) => p.toJsonString()).toList();
      await prefs.setStringList(_presetsKey, presetsJsonStrings);

      if (kDebugMode) {
        print('${presets.length} presets importados com sucesso!');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao importar presets: $e');
      }
      return false;
    }
  }
}

