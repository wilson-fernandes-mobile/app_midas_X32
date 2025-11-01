import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/mixer_viewmodel.dart';
import '../viewmodels/connection_viewmodel.dart';
import '../models/channel.dart';
import '../utils/channel_icon_helper.dart';
import 'connection_screen.dart';

/// Tela principal do mixer
class MixerScreen extends StatefulWidget {
  const MixerScreen({super.key});

  @override
  State<MixerScreen> createState() => _MixerScreenState();
}

class _MixerScreenState extends State<MixerScreen> {
  MixerViewModel? _viewModel;

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
      _viewModel?.startMetersPolling(demoMode: true);
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

  @override
  Widget build(BuildContext context) {
    // Detecta orientação do dispositivo
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      // Esconde AppBar quando estiver na horizontal
      appBar: isLandscape ? null : AppBar(
        title: Consumer<MixerViewModel>(
          builder: (context, viewModel, _) {
            final mixName = viewModel.selectedMix?.name ?? 'CCL Midas';
            return Text(mixName);
          },
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final viewModel = context.read<MixerViewModel>();
              await viewModel.refresh();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Informações recarregadas!'),
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
      body: Consumer<MixerViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF723A),
              ),
            );
          }

          // Mostra os canais mesmo sem Mix selecionado (Main LR)
          return LayoutBuilder(
            builder: (context, constraints) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: viewModel.channels.length,
                itemBuilder: (context, index) {
                  final channel = viewModel.channels[index];
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
                },
              );
            },
          );
        },
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

    return Container(
      width: 110,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
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

          // Ícone do canal (baseado no nome)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Icon(
              ChannelIconHelper.getIconForChannelName(channel.name),
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
                color: isMuted ? Colors.grey[600] : _getLevelColor(channel.level),
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
                      // Background track com marcações
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  width: 6,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        _getLevelColor(channel.level).withOpacity(0.3),
                                        Colors.grey[800]!,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
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
                                levelColor: _getLevelColor(channel.level),
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 24,
                              ),
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                              thumbColor: Colors.transparent,
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
                      isMuted ? 'MUTE' : 'ON',
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

  /// Retorna a cor do indicador de dB baseado no nível
  Color _getLevelColor(double level) {
    if (level < 0.74) {
      // Abaixo de 0dB = Amarelo
      return Colors.amber;
    } else if (level >= 0.74 && level <= 0.76) {
      // Em 0dB (com tolerância) = Verde
      return Colors.green;
    } else {
      // Acima de 0dB = Vermelho
      return Colors.red;
    }
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
                                color: _getLevelColor(viewModel.selectedMix!.level),
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
                            activeTrackColor: _getLevelColor(viewModel.selectedMix!.level),
                            inactiveTrackColor: Colors.grey[700],
                            thumbColor: _getLevelColor(viewModel.selectedMix!.level),
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

  /// Retorna a cor do indicador de dB baseado no nível
  Color _getLevelColor(double level) {
    if (level < 0.74) {
      // Abaixo de 0dB = Amarelo
      return Colors.amber;
    } else if (level >= 0.74 && level <= 0.76) {
      // Em 0dB (com tolerância) = Verde
      return Colors.green;
    } else {
      // Acima de 0dB = Vermelho
      return Colors.red;
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

class _PeakMeterState extends State<_PeakMeter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animação demo (simula sinal de áudio)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.6)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 0.3)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.8)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Usa o valor real do peakLevel (que agora reflete o fader)
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
      },
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
class _PeakMeterHorizontal extends StatefulWidget {
  final double peakLevel; // 0.0 a 1.0

  const _PeakMeterHorizontal({
    required this.peakLevel,
  });

  @override
  State<_PeakMeterHorizontal> createState() => _PeakMeterHorizontalState();
}

class _PeakMeterHorizontalState extends State<_PeakMeterHorizontal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animação demo (simula sinal de áudio)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.6)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 0.3)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.8)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Usa o valor real do peakLevel (que agora reflete o bus fader)
        final displayLevel = widget.peakLevel;

        return Container(
          height: 12, // Aumentei um pouco para ficar mais visível
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
                peakLevel: displayLevel,
              ),
            ),
          ),
        );
      },
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
