import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../viewmodels/preset_viewmodel.dart';
import '../viewmodels/mixer_viewmodel.dart';
import '../models/preset.dart';
import '../widgets/preset_dialog.dart';

/// Tela de listagem e gerenciamento de presets
class PresetListScreen extends StatefulWidget {
  const PresetListScreen({super.key});

  @override
  State<PresetListScreen> createState() => _PresetListScreenState();
}

class _PresetListScreenState extends State<PresetListScreen> {
  @override
  void initState() {
    super.initState();
    // Força orientação portrait (vertical apenas)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Restaura orientações ao sair da tela
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Row(
          children: [
            Icon(Icons.bookmark, color: Color(0xFFFF723A)),
            SizedBox(width: 12),
            Text('Presets Salvos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PresetViewModel>().loadPresets();
            },
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Consumer<PresetViewModel>(
        builder: (context, viewModel, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: viewModel.isLoading
                ? Center(
                    key: const ValueKey('loading'),
                    child: Lottie.asset(
                      'assets/animation/settings_icon.json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  )
                : viewModel.presets.isEmpty
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 80,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum preset salvo',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajuste os faders e salve um preset!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        key: const ValueKey('list'),
                        padding: const EdgeInsets.all(16),
                        itemCount: viewModel.presets.length,
                        itemBuilder: (context, index) {
                          final preset = viewModel.presets[index];
                          return _PresetCard(preset: preset);
                        },
                      ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSavePresetDialog(context),
        backgroundColor: const Color(0xFFFF723A),
        icon: const Icon(Icons.add),
        label: const Text('Salvar Atual'),
      ),
    );
  }

  Future<void> _showSavePresetDialog(BuildContext context) async {
    final name = await showSavePresetDialog(context);
    if (name != null && context.mounted) {
      final viewModel = context.read<PresetViewModel>();
      final success = await viewModel.saveCurrentAsPreset(name);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Preset "$name" salvo com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage ?? 'Erro ao salvar preset'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

/// Card individual de preset
class _PresetCard extends StatelessWidget {
  final Preset preset;

  const _PresetCard({required this.preset});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final mixerViewModel = context.read<MixerViewModel>();
    final currentMix = mixerViewModel.selectedMix?.number;

    return Consumer<PresetViewModel>(
      builder: (context, presetViewModel, _) {
        final isApplied = presetViewModel.appliedPreset?.id == preset.id;
        final hasChanges = isApplied && presetViewModel.hasUnsavedChanges;

        return Card(
          color: isApplied ? Colors.green[900] : Colors.grey[850],
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isApplied
                ? BorderSide(
                    color: hasChanges ? Colors.orange : Colors.green,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () => _applyPreset(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Indicador de preset aplicado
                      if (isApplied)
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: hasChanges ? Colors.orange : Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            hasChanges ? Icons.edit : Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      // Ícone e nome
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    preset.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isApplied)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: hasChanges ? Colors.orange : Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      hasChanges ? 'EDITANDO' : 'APLICADO',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.graphic_eq,
                                  size: 16,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Mix ${preset.mixNumber}',
                                  style: TextStyle(
                                    color: preset.mixNumber == currentMix
                                        ? const Color(0xFFFF723A)
                                        : Colors.grey[500],
                                    fontSize: 14,
                                    fontWeight: preset.mixNumber == currentMix
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.tune,
                                  size: 16,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${preset.channelLevels.length} canais',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Botões de ação
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editPreset(context),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePreset(context),
                            tooltip: 'Deletar',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Informações adicionais
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Atualizado: ${dateFormat.format(preset.updatedAt)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _applyPreset(BuildContext context) async {
    final viewModel = context.read<PresetViewModel>();
    final mixerViewModel = context.read<MixerViewModel>();

    // Verifica se o mix atual é o mesmo do preset
    if (mixerViewModel.selectedMix?.number != preset.mixNumber) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text(
            '⚠️ Mix Diferente',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Este preset foi salvo para o Mix ${preset.mixNumber}, mas você está no Mix ${mixerViewModel.selectedMix?.number}.\n\nDeseja aplicar mesmo assim?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF723A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Aplicar'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    final success = await viewModel.applyPreset(preset.id);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Preset "${preset.name}" aplicado!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Erro ao aplicar preset'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editPreset(BuildContext context) async {
    final newName = await showEditPresetDialog(context, preset.name);
    if (newName != null && context.mounted) {
      final viewModel = context.read<PresetViewModel>();
      final success = await viewModel.updatePreset(preset.id, newName: newName);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Preset atualizado!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage ?? 'Erro ao atualizar preset'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deletePreset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text(
          '🗑️ Deletar Preset',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja deletar o preset "${preset.name}"?\n\nEsta ação não pode ser desfeita.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final viewModel = context.read<PresetViewModel>();
      final success = await viewModel.deletePreset(preset.id);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🗑️ Preset deletado!'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage ?? 'Erro ao deletar preset'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

