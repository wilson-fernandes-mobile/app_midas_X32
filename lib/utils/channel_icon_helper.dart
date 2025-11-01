import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// Helper para determinar ícones de canais baseado no nome
class ChannelIconHelper {
  /// Retorna um ícone baseado no nome do canal
  static IconData getIconForChannelName(String name) {
    final nameLower = name.toLowerCase();

    // Vocais
    if (nameLower.contains('voc') ||
        nameLower.contains('vocal') ||
        nameLower.contains('mic') ||
        nameLower.contains('lead') ||
        nameLower.contains('backing')) {
      return MdiIcons.microphone; // 🎤 Microfone
    }

    // Bateria
    if (nameLower.contains('kick') ||
        nameLower.contains('bumbo') ||
        nameLower.contains('snare') ||
        nameLower.contains('caixa') ||
        nameLower.contains('hat') ||
        nameLower.contains('chimbal') ||
        nameLower.contains('hihat') ||
        nameLower.contains('tom') ||
        nameLower.contains('drum') ||
        nameLower.contains('overhead') ||
        nameLower.contains('oh') ||
        nameLower.contains('cymbal')) {
      return MdiIcons.musicCircle; // 🥁 Bateria
    }

    // Baixo (verifica primeiro para não confundir com guitarra)
    if (nameLower.contains('bass') ||
        nameLower.contains('baixo') ||
        nameLower.contains('baixão') ||
        nameLower.contains('baixao') ||
        nameLower.contains('contra') ||
        nameLower.contains('bx')) {
      return MdiIcons.guitarAcoustic; // 🎸 Baixo elétrico
    }

    // Violão/Acústico (verifica antes de guitarra elétrica)
    if (nameLower.contains('acoustic') ||
        nameLower.contains('violao') ||
        nameLower.contains('violão') ||
        nameLower.contains('acustic') ||
        nameLower.contains('acústic')) {
      return MdiIcons.guitarAcoustic; // 🎸 Violão
    }

    // Guitarras elétricas
    if (nameLower.contains('guitar') ||
        nameLower.contains('guitarra') ||
        nameLower.contains('gtr') ||
        nameLower.contains('gt')) {
      return MdiIcons.guitarElectric; // 🎸 Guitarra elétrica
    }

    // Teclados
    if (nameLower.contains('key') ||
        nameLower.contains('piano') ||
        nameLower.contains('synth') ||
        nameLower.contains('teclado')) {
      return MdiIcons.piano; // 🎹 Piano/Teclado
    }

    // Percussão
    if (nameLower.contains('perc') ||
        nameLower.contains('conga') ||
        nameLower.contains('bongo') ||
        nameLower.contains('shaker')) {
      return MdiIcons.musicNote; // 🎵 Nota musical
    }

    // Playback/Track
    if (nameLower.contains('play') ||
        nameLower.contains('track') ||
        nameLower.contains('bt') ||
        nameLower.contains('click')) {
      return MdiIcons.playCircleOutline; // ▶️ Play
    }

    // Retorno/Monitor
    if (nameLower.contains('ret') ||
        nameLower.contains('mon') ||
        nameLower.contains('wedge')) {
      return MdiIcons.speaker; // 🔊 Alto-falante
    }

    // Efeitos
    if (nameLower.contains('fx') ||
        nameLower.contains('reverb') ||
        nameLower.contains('delay') ||
        nameLower.contains('effect')) {
      return MdiIcons.waveform; // 〰️ Forma de onda
    }

    // Padrão
    return MdiIcons.tuneVertical; // 🎛️ Fader
  }

  /// Retorna um emoji baseado no nome do canal
  static String getEmojiForChannelName(String name) {
    final nameLower = name.toLowerCase();

    // Vocais
    if (nameLower.contains('voc') || 
        nameLower.contains('vocal') || 
        nameLower.contains('mic') ||
        nameLower.contains('lead') ||
        nameLower.contains('backing')) {
      return '🎤';
    }

    // Bateria
    if (nameLower.contains('kick') || 
        nameLower.contains('bumbo')) {
      return '🥁';
    }
    
    if (nameLower.contains('snare') || 
        nameLower.contains('caixa')) {
      return '🥁';
    }
    
    if (nameLower.contains('hat') || 
        nameLower.contains('chimbal') ||
        nameLower.contains('hihat')) {
      return '🥁';
    }
    
    if (nameLower.contains('tom') || 
        nameLower.contains('drum')) {
      return '🥁';
    }
    
    if (nameLower.contains('overhead') || 
        nameLower.contains('oh') ||
        nameLower.contains('cymbal')) {
      return '🥁';
    }

    // Baixo
    if (nameLower.contains('bass') || 
        nameLower.contains('baixo') ||
        nameLower.contains('contra')) {
      return '🎸';
    }

    // Guitarras
    if (nameLower.contains('guitar') || 
        nameLower.contains('guitarra') ||
        nameLower.contains('gtr')) {
      return '🎸';
    }

    // Teclados
    if (nameLower.contains('key') || 
        nameLower.contains('piano') ||
        nameLower.contains('synth') ||
        nameLower.contains('teclado')) {
      return '🎹';
    }

    // Percussão
    if (nameLower.contains('perc') || 
        nameLower.contains('conga') ||
        nameLower.contains('bongo') ||
        nameLower.contains('shaker')) {
      return '🪘';
    }

    // Playback/Track
    if (nameLower.contains('play') || 
        nameLower.contains('track') ||
        nameLower.contains('bt') ||
        nameLower.contains('click')) {
      return '▶️';
    }

    // Retorno/Monitor
    if (nameLower.contains('ret') || 
        nameLower.contains('mon') ||
        nameLower.contains('wedge')) {
      return '🔊';
    }

    // Efeitos
    if (nameLower.contains('fx') || 
        nameLower.contains('reverb') ||
        nameLower.contains('delay') ||
        nameLower.contains('effect')) {
      return '✨';
    }

    // Padrão
    return '🎛️';
  }

  /// Retorna cor baseada no tipo de canal
  static Color getColorForChannelName(String name) {
    final nameLower = name.toLowerCase();

    // Vocais - Azul
    if (nameLower.contains('voc') || 
        nameLower.contains('vocal') || 
        nameLower.contains('mic')) {
      return Colors.blue;
    }

    // Bateria - Vermelho
    if (nameLower.contains('kick') || 
        nameLower.contains('snare') ||
        nameLower.contains('tom') ||
        nameLower.contains('drum') ||
        nameLower.contains('hat')) {
      return Colors.red;
    }

    // Baixo - Roxo
    if (nameLower.contains('bass') || 
        nameLower.contains('baixo')) {
      return Colors.purple;
    }

    // Guitarras - Laranja
    if (nameLower.contains('guitar') || 
        nameLower.contains('guitarra')) {
      return Colors.orange;
    }

    // Teclados - Verde
    if (nameLower.contains('key') || 
        nameLower.contains('piano') ||
        nameLower.contains('synth')) {
      return Colors.green;
    }

    // Playback - Amarelo
    if (nameLower.contains('play') || 
        nameLower.contains('track')) {
      return Colors.yellow;
    }

    // Padrão - Cinza
    return Colors.grey;
  }
}

