import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../utils/fader_color_helper.dart';
import '../viewmodels/mixer_viewmodel.dart';
import '../viewmodels/connection_viewmodel.dart';
import '../viewmodels/preset_viewmodel.dart';
import '../models/channel.dart';
import '../utils/channel_icon_helper.dart';
import 'connection_screen.dart';
import 'preset_list_screen.dart';

/// Localização customizada do FAB para landscape (com offset à esquerda da toolbar)
class _CustomFabLocation extends FloatingActionButtonLocation {
  const _CustomFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Posição em landscape: sobrepondo a toolbar, com margem bottom maior
    final double fabX = scaffoldGeometry.scaffoldSize.width -
                        scaffoldGeometry.floatingActionButtonSize.width -
                        8.0; // margem direita pequena (fica em cima da toolbar)

    final double fabY = scaffoldGeometry.scaffoldSize.height -
                        scaffoldGeometry.floatingActionButtonSize.height -
                        24.0; // margem inferior maior

    return Offset(fabX, fabY);
  }
}

/// Tela principal do mixer
class MixerScreen extends StatefulWidget {
  const MixerScreen({super.key});

  @override
  State<MixerScreen> createState() => _MixerScreenState();
}

class _MixerScreenState extends State<MixerScreen> {
  MixerViewModel? _viewModel;
  final PageController _pageController = PageController(viewportFraction: 1.0);

  @override
  void initState() {
    super.initState();
    // Carrega o último Mix selecionado após conectar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = context.read<MixerViewModel>();
      _loadInitialMix();
      // Inicia polling de meters (VU/Peak meters em tempo real)
      // demoMode: true = Simula meters (para emuladores que não suportam)
      // demoMode: false = Usa meters reais do console
      _viewModel?.startMetersPolling(demoMode: false);
    });
  }

  Future<void> _loadInitialMix() async {
    final viewModel = context.read<MixerViewModel>();
    // Tenta carregar o último Mix selecionado
    await viewModel.loadLastSelectedMix();
  }

  @override
  void dispose() {
    // Para polling de meters quando sair da tela
    _viewModel?.stopMetersPolling();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _disconnect() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desconectar'),
        content: const Text('Deseja desconectar do console?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<ConnectionViewModel>().disconnect();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ConnectionScreen()),
      );
    }
  }

  void _showMasterControl() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _MasterControlBottomSheet(),
    );
  }

  /// Constrói a toolbar vertical para modo landscape (lado direito)
  Widget _buildVerticalToolbar(BuildContext context) {
    return Container(
      width: 60,
      color: Colors.grey[900],
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Indicador de preset aplicado
          Consumer<PresetViewModel>(
            builder: (context, presetViewModel, _) {
              final appliedPreset = presetViewModel.appliedPreset;
              final hasChanges = presetViewModel.hasUnsavedChanges;

              if (appliedPreset == null) {
                return const SizedBox(height: 48);
              }

              return Column(
                children: [
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: hasChanges ? Colors.orange : Colors.green,
                        ),
                        onPressed: () {
                          presetViewModel.clearAppliedPreset();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Auto-save desativado!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: hasChanges
                            ? 'Salvando...'
                            : appliedPreset.name,
                      ),
                      if (hasChanges)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 1, color: Colors.grey),
                ],
              );
            },
          ),
          // Botão de Presets
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PresetListScreen()),
              );
            },
            tooltip: 'Presets',
          ),
          const Divider(height: 1, color: Colors.grey),
          // Botão de Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              final viewModel = context.read<MixerViewModel>();
              await viewModel.refresh();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Informações recarregadas!'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            tooltip: 'Recarregar',
          ),
          const Divider(height: 1, color: Colors.grey),
          // Botão de Desconectar
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _disconnect,
            tooltip: 'Desconectar',
          ),
          const Spacer(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detecta orientação do dispositivo
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      // Esconde AppBar quando estiver na horizontal
      appBar: isLandscape ? null : AppBar(
        title: Consumer2<MixerViewModel, PresetViewModel>(
          builder: (context, mixerViewModel, presetViewModel, _) {
            final mixName = mixerViewModel.selectedMix?.name ?? 'CCL Midas';
            final appliedPreset = presetViewModel.appliedPreset;
            final hasChanges = presetViewModel.hasUnsavedChanges;

            if (appliedPreset == null) {
              return Text(mixName);
            }

            // Mostra nome do mix + preset aplicado de forma compacta
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mixName,
                  style: const TextStyle(fontSize: 16),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasChanges ? Icons.edit : Icons.tune,
                      size: 12,
                      color: hasChanges ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appliedPreset.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: hasChanges ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        backgroundColor: Colors.grey[900],
        actions: [
          // Indicador visual compacto de preset aplicado
          Consumer<PresetViewModel>(
            builder: (context, presetViewModel, _) {
              if (presetViewModel.appliedPreset == null) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: Stack(
                  children: [
                    Icon(
                      Icons.tune,
                      color: presetViewModel.hasUnsavedChanges
                          ? Colors.orange
                          : Colors.green,
                    ),
                    if (presetViewModel.hasUnsavedChanges)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  presetViewModel.clearAppliedPreset();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Auto-save desativado'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: presetViewModel.hasUnsavedChanges
                    ? 'Salvando... (toque para desativar)'
                    : 'Preset aplicado (toque para desativar)',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PresetListScreen()),
              );
            },
            tooltip: 'Presets',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final viewModel = context.read<MixerViewModel>();
              await viewModel.refresh();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Informações recarregadas!'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            tooltip: 'Recarregar informações do console',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _disconnect,
            tooltip: 'Desconectar',
          ),
        ],
      ),
      body: Row(
        children: [
          // Espaço vazio à esquerda em landscape (evita câmera/alto-falante)
          if (isLandscape) Container(
            width: 40,
            color: Colors.grey[900],
          ),
          // Lista de canais
          Expanded(
            child: Consumer<MixerViewModel>(
              builder: (context, viewModel, _) {
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
                      : _buildChannelsList(viewModel),
                );
              },
            ),
          ),
          // Toolbar vertical em landscape (lado direito)
          if (isLandscape) _buildVerticalToolbar(context),
        ],
      ),
      floatingActionButton: Consumer<MixerViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.selectedMix == null) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: _showMasterControl,
            backgroundColor: const Color(0xFFFF723A),
            icon: const Icon(Icons.tune),
            label: Text(viewModel.selectedMix!.name),
          );
        },
      ),
      // Em landscape, usa localização customizada para não ficar atrás da toolbar
      floatingActionButtonLocation: isLandscape
          ? const _CustomFabLocation()
          : FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildChannelsList(MixerViewModel viewModel) {
    return LayoutBuilder(
      key: const ValueKey('channels'),
      builder: (context, constraints) {
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

        // Calcula quantos canais cabem na tela
        final channelWidth = isLandscape ? 80.0 : 110.0;
        final channelMargin = isLandscape ? 8.0 : 12.0; // horizontal margin * 2
        final totalChannelWidth = channelWidth + channelMargin;
        final channelsPerPage = (constraints.maxWidth / totalChannelWidth).floor();

        // Agrupa canais em páginas
        final channels = viewModel.channels;
        final pageCount = (channels.length / channelsPerPage).ceil();

        // Listener para scroll com mouse (Windows/Desktop)
        return Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              final currentPage = _pageController.page ?? 0;

              // Scroll para direita (delta positivo) ou esquerda (delta negativo)
              if (pointerSignal.scrollDelta.dy > 0) {
                // Scroll down = próxima página
                final nextPage = (currentPage + 1).clamp(0.0, (pageCount - 1).toDouble());
                _pageController.animateToPage(
                  nextPage.toInt(),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (pointerSignal.scrollDelta.dy < 0) {
                // Scroll up = página anterior
                final prevPage = (currentPage - 1).clamp(0.0, (pageCount - 1).toDouble());
                _pageController.animateToPage(
                  prevPage.toInt(),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          },
          child: PageView.builder(
            itemCount: pageCount,
            controller: _pageController,
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * channelsPerPage;
              final endIndex = (startIndex + channelsPerPage).clamp(0, channels.length);
              final pageChannels = channels.sublist(startIndex, endIndex);

              return Row(
                mainAxisAlignment: MainAxisAlignment.center, // Centraliza os canais
                children: pageChannels.map((channel) {
                  return SizedBox(
                    height: constraints.maxHeight,
                    child: _ChannelStrip(
                      channel: channel,
                      onLevelChanged: (level) {
                        viewModel.setChannelLevel(channel.number, level);
                      },
                      onMuteToggled: () {
                        viewModel.toggleChannelMute(channel.number);
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }

}

/// Widget de um canal (fader strip)
class _ChannelStrip extends StatelessWidget {
  final Channel channel;
  final ValueChanged<double> onLevelChanged;
  final VoidCallback onMuteToggled;

  const _ChannelStrip({
    required this.channel,
    required this.onLevelChanged,
    required this.onMuteToggled,
  });

  @override
  Widget build(BuildContext context) {
    final isMuted = channel.mute;
    final levelPercent = (channel.level * 100).toInt();
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      width: isLandscape ? 80 : 110, // Mais estreito em landscape
      margin: EdgeInsets.symmetric(
        horizontal: isLandscape ? 4 : 6,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[850]!,
            Colors.grey[900]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMuted ? Colors.red.withOpacity(0.3) : Colors.grey[800]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isMuted
                ? Colors.red.withOpacity(0.2)
                : Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabeçalho com número do canal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isMuted
                    ? [Colors.red[900]!, Colors.red[800]!]
                    : [const Color(0xFFFF723A), const Color(0xFFFF8C5A)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Text(
              'CH ${channel.number}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Ícone do canal (baseado no nome) - Usa imagens reais quando disponíveis
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ChannelIconHelper.getIconWidgetForChannelName(
              channel.name,
              size: 24,
              color: isMuted
                  ? Colors.grey[700]
                  : ChannelIconHelper.getColorForChannelName(channel.name),
            ),
          ),

          const SizedBox(height: 4),

          // Indicador de nível (dB) - Topo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(
              minWidth: 70, // Largura mínima para acomodar "-∞" e "+10.0dB"
            ),
            child: Text(
              _levelToDb(channel.level),
              style: TextStyle(
                color: isMuted ? Colors.grey[600] : FaderColorHelper.getLevelColor(channel.level),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 12),

          // Fader com track visual e Peak Meter
          Expanded(
            flex: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 150, // Altura mínima para o fader
              ),
              child: Stack(
                children: [
                  // Fader (centralizado)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background track com marcações de régua
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: _FaderTrackWithMarkers(
                            level: channel.level,
                          ),
                        ),
                      ),

                      // Slider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 50,
                              thumbShape: _CustomThumbShape(
                                isMuted: isMuted,
                                level: channel.level,
                                levelColor: FaderColorHelper.getLevelColor(channel.level),
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 24,
                              ),
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                              thumbColor: Colors.transparent,
                              // Remove padding padrão do Slider
                              trackShape: const _CustomSliderTrackShape(),
                              // Remove padding vertical
                              overlayColor: Colors.transparent,
                            ),
                            child: Slider(
                              value: channel.level,
                              onChanged: isMuted ? null : onLevelChanged,
                              min: 0.0,
                              max: 1.0, // Máximo em +10dB
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Peak Meter (canto esquerdo) - Mostra áudio real dos meters
                  Positioned(
                    left: 4,
                    top: 0,
                    bottom: 0,
                    child: _PeakMeter(
                      peakLevel: channel.peakLevel, // Vem de /meters/1 (áudio real)
                      isMuted: isMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Indicador de porcentagem
          Text(
            '$levelPercent%',
            style: TextStyle(
              color: isMuted ? Colors.grey[700] : Colors.grey[400],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // Botão Mute redesenhado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: InkWell(
              onTap: onMuteToggled,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isMuted
                        ? [Colors.red[700]!, Colors.red[800]!]
                        : [Colors.grey[700]!, Colors.grey[800]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isMuted ? Colors.red[400]! : Colors.grey[600]!,
                    width: 1.5,
                  ),
                  boxShadow: isMuted ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isMuted ? 'OFF' : 'ON',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Converte level (0.0-1.0) para dB aproximado
  /// No M32/X32: 0.0 = -89dB, 0.75 = 0dB (unity), 1.0 = +10dB
  String _levelToDb(double level) {
    if (level <= 0.0) return '-∞';
    if (level < 0.75) {
      // De 0.0 a 0.75 = -89dB a 0dB (escala logarítmica aproximada)
      final db = (level / 0.75 - 1.0) * 89; // -89dB a 0dB
      return '${db.toStringAsFixed(1)}dB';
    } else if (level == 0.75) {
      // Exatamente em 0dB
      return '0.0dB';
    } else {
      // De 0.75 a 1.0 = 0dB a +10dB
      final db = (level - 0.75) / 0.25 * 10; // 0dB a +10dB
      return '+${db.toStringAsFixed(1)}dB';
    }
  }
}

/// Widget que desenha o track do fader com marcadores de régua
class _FaderTrackWithMarkers extends StatelessWidget {
  final double level;

  const _FaderTrackWithMarkers({
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        return Stack(
          children: [
            // Track de fundo
            Center(
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      FaderColorHelper.getLevelColor(level).withOpacity(0.3),
                      Colors.grey[800]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Marcadores de régua
            CustomPaint(
              size: Size(constraints.maxWidth, height),
              painter: _FaderRulerPainter(),
            ),
          ],
        );
      },
    );
  }
}

/// Painter para desenhar os marcadores de régua no fader
class _FaderRulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Conversão: level 0.75 = 0dB
    // Slider invertido: level 0.75 → posição visual 1.0 - 0.75 = 0.25 (25% do topo)
    final zeroDB = 1.0 - 0.75; // 0.25

    // Destaque especial na zona verde (0dB) - DESENHA PRIMEIRO (fundo)
    final greenZoneY = size.height * zeroDB;
    final greenZonePaint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Retângulo de destaque na zona verde (mais alto para cobrir mais área)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, greenZoneY),
          width: 40,
          height: 30,
        ),
        const Radius.circular(6),
      ),
      greenZonePaint,
    );

    // Paints para os marcadores
    final thickPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final mediumPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final thinPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final greenPaint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Marcadores principais com labels
    // Conversão de dB para position visual (invertido):
    // +10dB (level 1.0) → position 0.0 (topo)
    // 0dB (level 0.75) → position 0.25 (25% do topo)
    // -∞dB (level 0.0) → position 1.0 (fundo)
    final markers = [
      {'position': 1.0 - 1.0, 'length': 14.0, 'paint': thickPaint, 'label': '+10'},      // level 1.0
      {'position': 1.0 - 0.875, 'length': 6.0, 'paint': thinPaint, 'label': null},       // level 0.875
      {'position': 1.0 - 0.8125, 'length': 10.0, 'paint': mediumPaint, 'label': '+5'},   // level 0.8125 (+5dB)
      {'position': 1.0 - 0.78125, 'length': 6.0, 'paint': thinPaint, 'label': null},     // level 0.78125

      // 0dB - ZONA VERDE (destaque especial) - level 0.75
      {'position': zeroDB, 'length': 18.0, 'paint': greenPaint, 'label': '0'},

      {'position': 1.0 - 0.70, 'length': 6.0, 'paint': thinPaint, 'label': null},
      {'position': 1.0 - 0.65, 'length': 8.0, 'paint': mediumPaint, 'label': '-5'},
      {'position': 1.0 - 0.60, 'length': 6.0, 'paint': thinPaint, 'label': null},
      {'position': 1.0 - 0.55, 'length': 10.0, 'paint': mediumPaint, 'label': '-10'},
      {'position': 1.0 - 0.50, 'length': 6.0, 'paint': thinPaint, 'label': null},
      {'position': 1.0 - 0.45, 'length': 8.0, 'paint': mediumPaint, 'label': '-15'},
      {'position': 1.0 - 0.40, 'length': 10.0, 'paint': mediumPaint, 'label': '-20'},
      {'position': 1.0 - 0.35, 'length': 6.0, 'paint': thinPaint, 'label': null},
      {'position': 1.0 - 0.30, 'length': 8.0, 'paint': mediumPaint, 'label': '-30'},
      {'position': 1.0 - 0.20, 'length': 10.0, 'paint': mediumPaint, 'label': '-40'},
      {'position': 1.0 - 0.10, 'length': 10.0, 'paint': mediumPaint, 'label': '-50'},
      {'position': 1.0 - 0.05, 'length': 14.0, 'paint': thickPaint, 'label': '-60'},
    ];

    // Desenha os marcadores
    for (final marker in markers) {
      final position = marker['position'] as double;
      final length = marker['length'] as double;
      final paint = marker['paint'] as Paint;
      final label = marker['label'] as String?;

      final y = size.height * position;

      // Linha à esquerda
      canvas.drawLine(
        Offset(centerX - 3 - length, y),
        Offset(centerX - 3, y),
        paint,
      );

      // Linha à direita
      canvas.drawLine(
        Offset(centerX + 3, y),
        Offset(centerX + 3 + length, y),
        paint,
      );

      // Desenha label se existir (apenas do lado direito para não poluir)
      if (label != null) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: position == 0.25 ? Colors.green : Colors.white.withOpacity(0.5),
              fontSize: 9,
              fontWeight: position == 0.25 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(centerX + 3 + length + 3, y - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom track shape que remove o padding padrão do Slider
class _CustomSliderTrackShape extends SliderTrackShape {
  const _CustomSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2;
    final double trackWidth = parentBox.size.width;

    // Remove padding - usa toda a largura disponível
    return Rect.fromLTWH(
      offset.dx,
      offset.dy + (parentBox.size.height - trackHeight) / 2,
      trackWidth,
      trackHeight,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    // Não desenha nada - track é transparente
  }
}

/// Custom thumb shape para o fader
class _CustomThumbShape extends SliderComponentShape {
  final bool isMuted;
  final double level;
  final Color levelColor;

  const _CustomThumbShape({
    required this.isMuted,
    required this.level,
    required this.levelColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(60, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center + const Offset(0, 2), width: 56, height: 22),
      const Radius.circular(11),
    );
    canvas.drawRRect(shadowRect, shadowPaint);

    // Fundo do thumb (gradiente)
    final rect = Rect.fromCenter(center: center, width: 56, height: 22);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(11));

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isMuted
          ? [Colors.grey[700]!, Colors.grey[800]!]
          : [levelColor.withOpacity(0.9), levelColor],
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(rRect, gradientPaint);

    // Borda
    final borderPaint = Paint()
      ..color = isMuted ? Colors.grey[600]! : Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(rRect, borderPaint);

    // Linhas decorativas (grip)
    final gripPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = -1; i <= 1; i++) {
      final x = center.dx + (i * 6);
      canvas.drawLine(
        Offset(x, center.dy - 6),
        Offset(x, center.dy + 6),
        gripPaint,
      );
    }
  }
}

/// Bottom Sheet para controle master e seleção de mix
class _MasterControlBottomSheet extends StatelessWidget {
  const _MasterControlBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle (barra de arrastar)
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Conteúdo
          Consumer<MixerViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.selectedMix == null) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Nenhum mix selecionado',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título com nome do mix
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF723A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mix Selecionado',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                viewModel.selectedMix!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botão trocar mix
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showMixSelector(context);
                          },
                          icon: const Icon(Icons.swap_horiz, color: Color(0xFFFF723A)),
                          label: const Text(
                            'Trocar',
                            style: TextStyle(color: Color(0xFFFF723A)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Volume Master (horizontal)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.volume_up,
                              color: Color(0xFFFF723A),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Volume Master',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _levelToDb(viewModel.selectedMix!.level),
                              style: TextStyle(
                                color: FaderColorHelper.getLevelColor(viewModel.selectedMix!.level),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Slider horizontal
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 8,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 12,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 20,
                            ),
                            activeTrackColor: FaderColorHelper.getLevelColor(viewModel.selectedMix!.level),
                            inactiveTrackColor: Colors.grey[700],
                            thumbColor: FaderColorHelper.getLevelColor(viewModel.selectedMix!.level),
                          ),
                          child: Slider(
                            value: viewModel.selectedMix!.level,
                            onChanged: (value) {
                              viewModel.setBusLevel(value);
                            },
                            min: 0.0,
                            max: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Peak Meter horizontal
                        _PeakMeterHorizontal(
                          peakLevel: viewModel.selectedMix!.peakLevel,
                        ),
                      ],
                    ),
                  ),

                  // Espaço inferior (safe area)
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showMixSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text(
          'Selecionar Mix',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 16,
            itemBuilder: (context, index) {
              final mixNumber = index + 1;
              return ListTile(
                leading: const Icon(Icons.headset, color: Color(0xFFFF723A)),
                title: Text('Mix $mixNumber'),
                subtitle: Text('Bus $mixNumber'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<MixerViewModel>().selectMix(mixNumber);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  /// Converte level (0.0-1.0) para dB aproximado
  /// No M32/X32: 0.0 = -89dB, 0.75 = 0dB (unity), 1.0 = +10dB
  String _levelToDb(double level) {
    if (level <= 0.0) return '-∞';
    if (level < 0.75) {
      // De 0.0 a 0.75 = -89dB a 0dB (escala logarítmica aproximada)
      final db = (level / 0.75 - 1.0) * 89; // -89dB a 0dB
      return '${db.toStringAsFixed(1)}dB';
    } else if (level == 0.75) {
      // Exatamente em 0dB
      return '0.0dB';
    } else {
      // De 0.75 a 1.0 = 0dB a +10dB
      final db = (level - 0.75) / 0.25 * 10; // 0dB a +10dB
      return '+${db.toStringAsFixed(1)}dB';
    }
  }

}

/// Widget de Peak Meter vertical moderno com animação demo
class _PeakMeter extends StatefulWidget {
  final double peakLevel; // 0.0 a 1.0
  final bool isMuted;

  const _PeakMeter({
    required this.peakLevel,
    required this.isMuted,
  });

  @override
  State<_PeakMeter> createState() => _PeakMeterState();
}

class _PeakMeterState extends State<_PeakMeter> {
  @override
  Widget build(BuildContext context) {
    // Usa o valor real do peakLevel (vem do ViewModel via meters)
    final displayLevel = widget.isMuted ? 0.0 : widget.peakLevel;

    return Container(
      width: 8,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: CustomPaint(
          painter: _PeakMeterPainter(
            peakLevel: displayLevel,
          ),
        ),
      ),
    );
  }
}

/// Painter customizado para desenhar o Peak Meter vertical
class _PeakMeterPainter extends CustomPainter {
  final double peakLevel;

  _PeakMeterPainter({required this.peakLevel});

  @override
  void paint(Canvas canvas, Size size) {
    // Altura preenchida baseada no peakLevel
    final filledHeight = size.height * peakLevel;

    // Gradiente do meter (de baixo para cima)
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Colors.green,           // Baixo (seguro)
        Colors.green,           //
        Colors.yellow,          // Médio (atenção)
        Colors.orange,          //
        Colors.red,             // Alto (perigo)
      ],
      stops: const [0.0, 0.5, 0.7, 0.85, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, size.height - filledHeight, size.width, filledHeight),
      );

    // Desenha o meter preenchido de baixo para cima
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - filledHeight, size.width, filledHeight),
      paint,
    );

    // Desenha marcações horizontais (segmentos)
    final segmentPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 1; i < 10; i++) {
      final y = size.height * (i / 10);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        segmentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_PeakMeterPainter oldDelegate) {
    return oldDelegate.peakLevel != peakLevel;
  }
}

/// Widget de Peak Meter horizontal para o bus master
class _PeakMeterHorizontal extends StatelessWidget {
  final double peakLevel; // 0.0 a 1.0

  const _PeakMeterHorizontal({
    required this.peakLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: CustomPaint(
          painter: _PeakMeterHorizontalPainter(
            peakLevel: peakLevel,
          ),
        ),
      ),
    );
  }
}

/// Painter customizado para desenhar o Peak Meter horizontal
class _PeakMeterHorizontalPainter extends CustomPainter {
  final double peakLevel;

  _PeakMeterHorizontalPainter({required this.peakLevel});

  @override
  void paint(Canvas canvas, Size size) {
    // Largura preenchida baseada no peakLevel (da esquerda para direita)
    final filledWidth = size.width * peakLevel;

    // Gradiente do meter (da esquerda para direita)
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.green,           // Início (seguro)
        Colors.green,           //
        Colors.yellow,          // Médio (atenção)
        Colors.orange,          //
        Colors.red,             // Final (perigo)
      ],
      stops: const [0.0, 0.5, 0.7, 0.85, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, filledWidth, size.height),
      );

    // Desenha o meter preenchido da esquerda para direita
    canvas.drawRect(
      Rect.fromLTWH(0, 0, filledWidth, size.height),
      paint,
    );

    // Desenha marcações verticais (segmentos)
    final segmentPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 1; i < 10; i++) {
      final x = size.width * (i / 10);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        segmentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_PeakMeterHorizontalPainter oldDelegate) {
    return oldDelegate.peakLevel != peakLevel;
  }
}
