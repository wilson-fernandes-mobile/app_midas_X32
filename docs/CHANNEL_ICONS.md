# 🎨 Ícones de Canais - Sistema Automático

## 🎯 Como Funciona

O app **detecta automaticamente** o tipo de instrumento baseado no **nome do canal** e mostra um **ícone** e **cor** apropriados!

---

## 📋 Mapeamento de Ícones

### 🎤 **Vocais** (Azul)
**Palavras-chave:** `voc`, `vocal`, `mic`, `lead`, `backing`

**Ícone:** 🎤 (Microfone)

**Exemplos:**
- "Vocal Lead" → 🎤 Azul
- "Backing Voc" → 🎤 Azul
- "Mic 1" → 🎤 Azul

---

### 🥁 **Bateria** (Vermelho)
**Palavras-chave:** `kick`, `bumbo`, `snare`, `caixa`, `tom`, `drum`, `hat`, `chimbal`, `hihat`, `overhead`, `oh`, `cymbal`

**Ícone:** 🥁 (Bateria)

**Exemplos:**
- "Kick" → 🥁 Vermelho
- "Snare" → 🥁 Vermelho
- "Tom 1" → 🥁 Vermelho
- "Hi-Hat" → 🥁 Vermelho
- "Overhead L" → 🥁 Vermelho

---

### 🎸 **Baixo** (Roxo)
**Palavras-chave:** `bass`, `baixo`, `contra`

**Ícone:** 🎸 (Guitarra)

**Exemplos:**
- "Bass DI" → 🎸 Roxo
- "Baixo" → 🎸 Roxo
- "Contrabaixo" → 🎸 Roxo

---

### 🎸 **Guitarras** (Laranja)
**Palavras-chave:** `guitar`, `guitarra`, `gtr`

**Ícone:** 🎸 (Guitarra)

**Exemplos:**
- "Guitar 1" → 🎸 Laranja
- "Guitarra Solo" → 🎸 Laranja
- "Gtr Rhythm" → 🎸 Laranja

---

### 🎹 **Teclados** (Verde)
**Palavras-chave:** `key`, `piano`, `synth`, `teclado`

**Ícone:** 🎹 (Teclado)

**Exemplos:**
- "Keys" → 🎹 Verde
- "Piano" → 🎹 Verde
- "Synth Pad" → 🎹 Verde
- "Teclado" → 🎹 Verde

---

### 🪘 **Percussão** (Cinza)
**Palavras-chave:** `perc`, `conga`, `bongo`, `shaker`

**Ícone:** 🪘 (Percussão)

**Exemplos:**
- "Percussion" → 🪘 Cinza
- "Conga" → 🪘 Cinza
- "Shaker" → 🪘 Cinza

---

### ▶️ **Playback/Track** (Amarelo)
**Palavras-chave:** `play`, `track`, `bt`, `click`

**Ícone:** ▶️ (Play)

**Exemplos:**
- "Playback" → ▶️ Amarelo
- "Track 1" → ▶️ Amarelo
- "BT" → ▶️ Amarelo
- "Click" → ▶️ Amarelo

---

### 🔊 **Retorno/Monitor** (Cinza)
**Palavras-chave:** `ret`, `mon`, `wedge`

**Ícone:** 🔊 (Alto-falante)

**Exemplos:**
- "Retorno 1" → 🔊 Cinza
- "Monitor" → 🔊 Cinza
- "Wedge" → 🔊 Cinza

---

### ✨ **Efeitos** (Cinza)
**Palavras-chave:** `fx`, `reverb`, `delay`, `effect`

**Ícone:** ✨ (Ondas)

**Exemplos:**
- "FX Return" → ✨ Cinza
- "Reverb" → ✨ Cinza
- "Delay" → ✨ Cinza

---

### 🎛️ **Padrão** (Cinza)
**Quando:** Nenhuma palavra-chave encontrada

**Ícone:** 🎛️ (Mixer)

**Exemplos:**
- "Ch 1" → 🎛️ Cinza
- "Canal 5" → 🎛️ Cinza
- "Input 10" → 🎛️ Cinza

---

## 🧪 Como Testar

### **Passo 1: Hot Restart**
```bash
# Pressione Shift+R no terminal do Flutter
```

### **Passo 2: Conecte ao Emulador**
- IP: `192.168.9.138`
- Porta: `10023`

### **Passo 3: Configure Nomes no Emulador X32**

No emulador, configure os nomes dos canais:

1. Abra o emulador X32
2. Vá em **Setup** → **Config** → **Channel**
3. Configure os nomes:
   - Canal 1: "Vocal Lead"
   - Canal 2: "Kick"
   - Canal 3: "Snare"
   - Canal 4: "Bass DI"
   - Canal 5: "Guitar 1"
   - Canal 6: "Keys"
   - Canal 7: "Playback"

### **Passo 4: Recarregue no App**

No app, clique no botão **↻ (Refresh)** no canto superior direito.

### **Passo 5: Observe os Ícones**

Você deve ver:
- Canal 1: 🎤 (Azul) - "Vocal Lead"
- Canal 2: 🥁 (Vermelho) - "Kick"
- Canal 3: 🥁 (Vermelho) - "Snare"
- Canal 4: 🎸 (Roxo) - "Bass DI"
- Canal 5: 🎸 (Laranja) - "Guitar 1"
- Canal 6: 🎹 (Verde) - "Keys"
- Canal 7: ▶️ (Amarelo) - "Playback"

---

## 🎨 Personalização

### **Adicionar Novos Ícones:**

Edite `lib/utils/channel_icon_helper.dart`:

```dart
// Adicionar novo tipo de instrumento
if (nameLower.contains('sax') || 
    nameLower.contains('saxofone')) {
  return Icons.music_note; // Ícone
}
```

### **Adicionar Novas Cores:**

```dart
// Adicionar nova cor
if (nameLower.contains('sax')) {
  return Colors.pink; // Cor
}
```

### **Adicionar Novos Emojis:**

```dart
// Adicionar novo emoji
if (nameLower.contains('sax')) {
  return '🎷'; // Emoji
}
```

---

## 📊 Código Implementado

### **Arquivo:** `lib/utils/channel_icon_helper.dart`

```dart
class ChannelIconHelper {
  /// Retorna um ícone baseado no nome do canal
  static IconData getIconForChannelName(String name) {
    final nameLower = name.toLowerCase();
    
    if (nameLower.contains('voc')) {
      return Icons.mic;
    }
    
    // ... mais mapeamentos
    
    return Icons.graphic_eq; // Padrão
  }
  
  /// Retorna cor baseada no tipo de canal
  static Color getColorForChannelName(String name) {
    final nameLower = name.toLowerCase();
    
    if (nameLower.contains('voc')) {
      return Colors.blue;
    }
    
    // ... mais mapeamentos
    
    return Colors.grey; // Padrão
  }
}
```

### **Uso no MixerScreen:**

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

## 🌍 Suporte a Português e Inglês

O sistema detecta palavras em **português** e **inglês**:

| Português | Inglês | Ícone |
|-----------|--------|-------|
| Vocal | Vocal | 🎤 |
| Bumbo | Kick | 🥁 |
| Caixa | Snare | 🥁 |
| Chimbal | Hi-Hat | 🥁 |
| Baixo | Bass | 🎸 |
| Guitarra | Guitar | 🎸 |
| Teclado | Keys | 🎹 |

---

## ✅ Benefícios

- ✅ **Identificação visual rápida** dos canais
- ✅ **Cores diferentes** para cada tipo de instrumento
- ✅ **Automático** - não precisa configurar manualmente
- ✅ **Suporte a português e inglês**
- ✅ **Fácil de personalizar**

---

## 🎉 Resultado

Agora o mixer fica muito mais **visual** e **fácil de usar**! 

Cada canal tem seu próprio ícone e cor, facilitando a identificação rápida durante shows ao vivo! 🎛️✨

