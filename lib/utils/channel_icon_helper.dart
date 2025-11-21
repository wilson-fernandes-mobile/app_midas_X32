import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// Helper para determinar ícones de canais baseado no nome
class ChannelIconHelper {
  /// Retorna um Widget (Image ou Icon) baseado no nome do canal
  /// Usa imagens reais quando disponíveis (SEM pintar), senão usa ícones Material (COM cor)
  static Widget getIconWidgetForChannelName(String name, {double size = 24, Color? color}) {
    final nameLower = name.toLowerCase();

    // Vocais - Microfone (IMAGEM - sem pintar)
    if (nameLower.contains('voc') ||
        nameLower.contains('vocal') ||
        nameLower.contains('mic') ||
        nameLower.contains('lead') ||
        nameLower.contains('backing')) {
      // Diferencia por gênero se possível
      if (nameLower.contains('male') || nameLower.contains('man') || nameLower.contains('masculino') || nameLower.contains('homem')) {
        return Image.asset('assets/images/ic_voz_male.png', width: size, height: size);
      } else if (nameLower.contains('woman') || nameLower.contains('feminino') || nameLower.contains('mulher')) {
        return Image.asset('assets/images/ic_voz_famale.png', width: size, height: size);
      }
      return Image.asset('assets/images/ic_mic.png', width: size, height: size);
    }


    if (nameLower.contains('mic') ||
        nameLower.contains('mic-backing') ||
        nameLower.contains('microfone') ||
        nameLower.contains('voicefone')) {
      // Diferencia por gênero se possível
      if (nameLower.contains('male') || nameLower.contains('man') || nameLower.contains('masculino') || nameLower.contains('homem')) {
        return Image.asset('assets/images/ic_voz_male.png', width: size, height: size);
      } else if (nameLower.contains('woman') || nameLower.contains('feminino') || nameLower.contains('mulher')) {
        return Image.asset('assets/images/ic_voz_famale.png', width: size, height: size);
      }
      return Image.asset('assets/images/ic_mic.png', width: size, height: size);
    }


    // Bateria - Kick/Bumbo (IMAGEM - sem pintar)
    if (nameLower.contains('kick') || nameLower.contains('bumbo')) {
      return Image.asset('assets/images/ic_bumbo.png', width: size, height: size);
    }

    // Bateria - Snare/Caixa (IMAGEM - sem pintar)
    if (nameLower.contains('snare') || nameLower.contains('caixa')) {
      return Image.asset('assets/images/ic_snare.png', width: size, height: size);
    }

    // Bateria - Pratos/Overhead/Cymbal (IMAGEM - sem pintar)
    if (nameLower.contains('overhead') ||
        nameLower.contains('oh') ||
        nameLower.contains('cymbal') ||
        nameLower.contains('prato')) {
      return Image.asset('assets/images/ic_cymbal.png', width: size, height: size);
    }

    // Bateria - Hi-Hat/Chimbal (IMAGEM - sem pintar)
    if (nameLower.contains('hat') || nameLower.contains('chimbal') || nameLower.contains('hihat')) {
      return Image.asset('assets/images/ic_cymbal.png', width: size, height: size);
    }

    // Bateria - Toms/Drums genéricos (ÍCONE - com cor)
    if (nameLower.contains('tom') || nameLower.contains('drum')) {
      return Icon(MdiIcons.musicCircle, size: size, color: color);
    }

    // Bateria eletrônica/Pads (IMAGEM - sem pintar)
    if (nameLower.contains('pad') || nameLower.contains('eletronic') || nameLower.contains('eletron')) {
      return Image.asset('assets/images/ic_drum_machine_pad.png', width: size, height: size);
    }

    // Baixo (IMAGEM - sem pintar)
    if (nameLower.contains('bass') ||
        nameLower.contains('baixo') ||
        nameLower.contains('baixão') ||
        nameLower.contains('baixao') ||
        nameLower.contains('contra') ||
        nameLower.contains('bx')) {
      return Image.asset('assets/images/ic_bass.png', width: size, height: size);
    }

    // Violão/Acústico (IMAGEM - sem pintar)
    if (nameLower.contains('acoustic') ||
        nameLower.contains('violao') ||
        nameLower.contains('violão') ||
        nameLower.contains('acustic') ||
        nameLower.contains('acústic')) {
      return Image.asset('assets/images/ic_acustic_guitar.png', width: size, height: size);
    }

    // Bandolim/Mandolin (IMAGEM - sem pintar)
    if (nameLower.contains('mandolin') || nameLower.contains('bandolim')) {
      return Image.asset('assets/images/ic_mandolin.png', width: size, height: size);
    }

    // Guitarras elétricas (IMAGEM - sem pintar)
    if (nameLower.contains('guitar') ||
        nameLower.contains('guitarra') ||
        nameLower.contains('gtr') ||
        nameLower.contains('gt')) {
      return Image.asset('assets/images/ic_electric_guitar.png', width: size, height: size);
    }

    // Teclados (IMAGEM - sem pintar)
    if (nameLower.contains('key') ||
        nameLower.contains('piano') ||
        nameLower.contains('synth') ||
        nameLower.contains('teclado')) {
      return Image.asset('assets/images/ic_teclado.png', width: size, height: size);
    }

    // Percussão (ÍCONE - com cor)
    if (nameLower.contains('perc') ||
        nameLower.contains('conga') ||
        nameLower.contains('bongo') ||
        nameLower.contains('shaker')) {
      return Icon(MdiIcons.musicNote, size: size, color: color);
    }

    // Click/Metrônomo (IMAGEM - sem pintar)
    if (nameLower.contains('click') || nameLower.contains('metronome') || nameLower.contains('metrônomo')) {
      return Image.asset('assets/images/ic_metronome_click.png', width: size, height: size);
    }

    // Playback/Track (IMAGEM - sem pintar)
    if (nameLower.contains('play') || nameLower.contains('track') || nameLower.contains('bt')) {
      return Image.asset('assets/images/ic_play_back.png', width: size, height: size);
    }

    // Retorno/Monitor (ÍCONE - com cor)
    if (nameLower.contains('ret') ||
        nameLower.contains('mon') ||
        nameLower.contains('wedge')) {
      return Icon(MdiIcons.speaker, size: size, color: color);
    }

    // Efeitos (ÍCONE - com cor)
    if (nameLower.contains('fx') ||
        nameLower.contains('reverb') ||
        nameLower.contains('delay') ||
        nameLower.contains('effect')) {
      return Icon(MdiIcons.waveform, size: size, color: color);
    }

    // Padrão (ÍCONE - com cor)
    return Icon(MdiIcons.tuneVertical, size: size, color: color);
  }

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

