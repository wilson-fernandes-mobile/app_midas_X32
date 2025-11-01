# 🎸 Ícones Material Design Icons - CCL Midas

## ✅ Pacote Instalado

```yaml
material_design_icons_flutter: ^7.0.7296
```

---

## 🎨 Ícones Disponíveis

### **🎤 Vocais**
- **Palavras-chave**: voc, vocal, mic, lead, backing
- **Ícone**: `MdiIcons.microphone`
- **Cor**: Azul
- **Exemplo**: "Vocal Lead", "Backing Voc", "Mic 1"

---

### **🥁 Bateria**
- **Palavras-chave**: kick, bumbo, snare, caixa, hat, chimbal, hihat, tom, drum, overhead, oh, cymbal
- **Ícone**: `MdiIcons.drum`
- **Cor**: Vermelho
- **Exemplo**: "Kick", "Snare Top", "Hi-Hat", "Tom 1", "Overhead L"

---

### **🎸 Baixo**
- **Palavras-chave**: bass, baixo, baixão, baixao, contra, bx
- **Ícone**: `MdiIcons.guitarElectric`
- **Cor**: Roxo
- **Exemplo**: "Bass DI", "Baixo Amp", "Contra Baixo"

---

### **🎸 Violão/Acústico**
- **Palavras-chave**: acoustic, violao, violão, acustic, acústic
- **Ícone**: `MdiIcons.guitarAcoustic`
- **Cor**: Laranja
- **Exemplo**: "Violão", "Acoustic Guitar", "Acústico"

---

### **🎸 Guitarra Elétrica**
- **Palavras-chave**: guitar, guitarra, gtr, gt
- **Ícone**: `MdiIcons.guitarElectric`
- **Cor**: Laranja
- **Exemplo**: "Guitar 1", "Guitarra Lead", "GTR L"

---

### **🎹 Teclados**
- **Palavras-chave**: key, piano, synth, teclado
- **Ícone**: `MdiIcons.piano`
- **Cor**: Verde
- **Exemplo**: "Keys L", "Piano", "Synth Pad", "Teclado"

---

### **🎵 Percussão**
- **Palavras-chave**: perc, conga, bongo, shaker
- **Ícone**: `MdiIcons.musicNote`
- **Cor**: Cinza
- **Exemplo**: "Perc", "Conga", "Bongo", "Shaker"

---

### **▶️ Playback/Track**
- **Palavras-chave**: play, track, bt, click
- **Ícone**: `MdiIcons.playCircleOutline`
- **Cor**: Amarelo
- **Exemplo**: "Playback L", "Track 1", "BT", "Click"

---

### **🔊 Retorno/Monitor**
- **Palavras-chave**: ret, mon, wedge
- **Ícone**: `MdiIcons.speaker`
- **Cor**: Cinza
- **Exemplo**: "Retorno 1", "Monitor", "Wedge"

---

### **〰️ Efeitos**
- **Palavras-chave**: fx, reverb, delay, effect
- **Ícone**: `MdiIcons.waveform`
- **Cor**: Cinza
- **Exemplo**: "FX Send", "Reverb", "Delay"

---

### **🎛️ Padrão**
- **Quando**: Nenhuma palavra-chave detectada
- **Ícone**: `MdiIcons.tuneVertical`
- **Cor**: Cinza
- **Exemplo**: "Ch 01", "Canal 15", "Input 8"

---

## 📋 Tabela Resumida

| Tipo | Ícone MDI | Cor | Exemplo |
|------|-----------|-----|---------|
| **Vocais** | `microphone` | 🔵 Azul | "Vocal Lead" |
| **Bateria** | `drum` | 🔴 Vermelho | "Kick", "Snare" |
| **Baixo** | `guitarElectric` | 🟣 Roxo | "Bass DI" |
| **Violão** | `guitarAcoustic` | 🟠 Laranja | "Violão" |
| **Guitarra** | `guitarElectric` | 🟠 Laranja | "Guitar 1" |
| **Teclados** | `piano` | 🟢 Verde | "Keys L" |
| **Percussão** | `musicNote` | ⚪ Cinza | "Conga" |
| **Playback** | `playCircleOutline` | 🟡 Amarelo | "Track 1" |
| **Monitor** | `speaker` | ⚪ Cinza | "Retorno 1" |
| **Efeitos** | `waveform` | ⚪ Cinza | "Reverb" |
| **Padrão** | `tuneVertical` | ⚪ Cinza | "Ch 01" |

---

## 🔧 Como Usar

### **1. Importar o Pacote**

```dart
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
```

### **2. Usar o Helper**

```dart
import 'package:cclmidas/utils/channel_icon_helper.dart';

// Obter ícone baseado no nome
IconData icon = ChannelIconHelper.getIconForChannelName('Vocal Lead');
// Retorna: MdiIcons.microphone

// Obter cor baseada no nome
Color color = ChannelIconHelper.getColorForChannelName('Kick');
// Retorna: Colors.red
```

### **3. Exemplo Completo**

```dart
Icon(
  ChannelIconHelper.getIconForChannelName(channel.name),
  size: 24,
  color: isMuted 
      ? Colors.grey[700] 
      : ChannelIconHelper.getColorForChannelName(channel.name),
)
```

---

## 🎯 Exemplos de Nomes e Ícones

### **Setup de Banda Completa:**

```
Canal 01: "Vocal Lead"     → 🎤 microphone (Azul)
Canal 02: "Backing Voc 1"  → 🎤 microphone (Azul)
Canal 03: "Backing Voc 2"  → 🎤 microphone (Azul)
Canal 04: "Kick In"        → 🥁 drum (Vermelho)
Canal 05: "Kick Out"       → 🥁 drum (Vermelho)
Canal 06: "Snare Top"      → 🥁 drum (Vermelho)
Canal 07: "Snare Bottom"   → 🥁 drum (Vermelho)
Canal 08: "Hi-Hat"         → 🥁 drum (Vermelho)
Canal 09: "Tom 1"          → 🥁 drum (Vermelho)
Canal 10: "Tom 2"          → 🥁 drum (Vermelho)
Canal 11: "Tom 3"          → 🥁 drum (Vermelho)
Canal 12: "Overhead L"     → 🥁 drum (Vermelho)
Canal 13: "Overhead R"     → 🥁 drum (Vermelho)
Canal 14: "Bass DI"        → 🎸 guitarElectric (Roxo)
Canal 15: "Bass Amp"       → 🎸 guitarElectric (Roxo)
Canal 16: "Guitar 1"       → 🎸 guitarElectric (Laranja)
Canal 17: "Guitar 2"       → 🎸 guitarElectric (Laranja)
Canal 18: "Violão"         → 🎸 guitarAcoustic (Laranja)
Canal 19: "Keys L"         → 🎹 piano (Verde)
Canal 20: "Keys R"         → 🎹 piano (Verde)
Canal 21: "Synth"          → 🎹 piano (Verde)
Canal 22: "Conga"          → 🎵 musicNote (Cinza)
Canal 23: "Shaker"         → 🎵 musicNote (Cinza)
Canal 24: "Playback L"     → ▶️ playCircleOutline (Amarelo)
Canal 25: "Playback R"     → ▶️ playCircleOutline (Amarelo)
Canal 26: "Click"          → ▶️ playCircleOutline (Amarelo)
```

---

## 📦 Instalação do Pacote

### **1. Adicionar ao pubspec.yaml**

```yaml
dependencies:
  material_design_icons_flutter: ^7.0.7296
```

### **2. Baixar Pacote**

**No Android Studio:**
1. Abra `pubspec.yaml`
2. Clique em **"Pub get"** no banner azul no topo
3. Ou clique em **"Pub get"** no canto superior direito

**No VS Code:**
1. Abra `pubspec.yaml`
2. Clique em **"Get Packages"** no banner amarelo
3. Ou pressione `Ctrl+Shift+P` → `Flutter: Get Packages`

### **3. Hot Restart**

Depois de baixar o pacote:
- Pressione **Shift+R** (terminal Flutter)
- Ou clique em **⚡ Hot Restart** (Android Studio)

---

## ✅ Verificar Instalação

Depois de rodar `pub get`, você deve ver:

```
Running "flutter pub get" in CCLMidas...
Resolving dependencies...
+ material_design_icons_flutter 7.0.7296
Changed 1 dependency!
```

---

## 🎨 Ícones Disponíveis no Pacote

O pacote `material_design_icons_flutter` contém **mais de 7.000 ícones**!

Alguns úteis para áudio:
- `MdiIcons.microphone` - Microfone
- `MdiIcons.drum` - Bateria
- `MdiIcons.guitarElectric` - Guitarra elétrica
- `MdiIcons.guitarAcoustic` - Violão
- `MdiIcons.piano` - Piano
- `MdiIcons.musicNote` - Nota musical
- `MdiIcons.speaker` - Alto-falante
- `MdiIcons.waveform` - Forma de onda
- `MdiIcons.tuneVertical` - Fader vertical
- `MdiIcons.playCircleOutline` - Play

**Ver todos os ícones**: https://pictogrammers.com/library/mdi/

---

## 🎉 Pronto!

Agora você tem ícones profissionais de instrumentos musicais no app! 🎸🥁🎹🎤

**Faça um Hot Restart (Shift+R) depois de baixar o pacote!** 🚀

