# 🎛️ Scripts de Monitoramento OSC

Scripts para monitorar e testar a comunicação OSC com o emulador X32/M32.

---

## 📋 Scripts Disponíveis

### 1. **monitor_canais.dart** - Snapshot único
Solicita os níveis uma vez e mostra o resultado.

### 2. **monitor_tempo_real.dart** - Monitoramento contínuo
Atualiza os níveis continuamente em tempo real.

---

## 🚀 Como Usar

### **Pré-requisitos:**

1. **Emulador X32 rodando:**
   ```
   X32 - v0.88 - An X32 Emulator
   Listening to port: 10023, X32 IP = 192.168.9.138
   Reading init file... Done
   ```

2. **Dart instalado** (vem com Flutter)

---

## 📊 Script 1: Monitor de Canais (Snapshot)

### **Uso:**
```bash
dart scripts/monitor_canais.dart <IP> <MIX>
```

### **Exemplos:**

**Emulador Android (mesmo PC):**
```bash
dart scripts/monitor_canais.dart 10.0.2.2 1
```

**PC na rede:**
```bash
dart scripts/monitor_canais.dart 192.168.9.138 1
```

**Localhost:**
```bash
dart scripts/monitor_canais.dart 127.0.0.1 1
```

### **O que faz:**
1. Conecta ao emulador
2. Solicita níveis de todos os 32 canais do Mix especificado
3. Solicita nível do bus (fader master)
4. Mostra os resultados com barras visuais
5. Encerra

### **Saída esperada:**
```
🎛️  Monitor de Canais - CCLMidas
════════════════════════════════════════════════════════════
📡 IP: 192.168.9.138:10023
🎚️  Mix: 1
════════════════════════════════════════════════════════════

✅ Socket criado na porta 54321
🔌 Conectando ao console...

🔍 Solicitando informações do Mix 1...

📝 Ch01: "Ch 01"
📊 Ch01: ████████████████░░░░ 75.0% (-5.0 dB)
📝 Ch02: "Ch 02"
📊 Ch02: ██████████░░░░░░░░░░ 50.0% (-10.0 dB)
...
🎛️  BUS01: ██████████░░░░░░░░░░ 50.0% (-10.0 dB)

════════════════════════════════════════════════════════════
📊 RESUMO DOS NÍVEIS:
════════════════════════════════════════════════════════════

Ch01: ████████████████░░░░ 75.0% (-5.0 dB)
Ch02: ██████████░░░░░░░░░░ 50.0% (-10.0 dB)
Ch03: ░░░░░░░░░░░░░░░░░░░░ 0.0% (-∞ dB)
...
Ch32: ░░░░░░░░░░░░░░░░░░░░ 0.0% (-∞ dB)

BUS: ██████████░░░░░░░░░░ 50.0% (-10.0 dB)

════════════════════════════════════════════════════════════
✅ Monitoramento concluído!
════════════════════════════════════════════════════════════
```

---

## 🔄 Script 2: Monitor em Tempo Real

### **Uso:**
```bash
dart scripts/monitor_tempo_real.dart <IP> <MIX> [INTERVALO_MS]
```

### **Parâmetros:**
- `IP` - Endereço IP do emulador
- `MIX` - Número do mix (1-16)
- `INTERVALO_MS` - Intervalo de atualização em milissegundos (padrão: 1000)

### **Exemplos:**

**Atualizar a cada 1 segundo:**
```bash
dart scripts/monitor_tempo_real.dart 192.168.9.138 1
```

**Atualizar a cada 500ms (mais rápido):**
```bash
dart scripts/monitor_tempo_real.dart 192.168.9.138 1 500
```

**Atualizar a cada 2 segundos (mais lento):**
```bash
dart scripts/monitor_tempo_real.dart 192.168.9.138 1 2000
```

### **O que faz:**
1. Conecta ao emulador
2. A cada X milissegundos:
   - Solicita níveis de todos os canais
   - Solicita nível do bus
   - Atualiza a tela com os valores
3. Continua rodando até você pressionar Ctrl+C

### **Saída esperada:**
```
🎛️  Monitor em Tempo Real - Mix 1
══════════════════════════════════════════════════════════════════════
⏰ 14:35:22

✅ Ch01: ████████░░ 75.0%  ✅ Ch17: ░░░░░░░░░░ 0.0%
✅ Ch02: █████░░░░░ 50.0%  ✅ Ch18: ░░░░░░░░░░ 0.0%
✅ Ch03: ░░░░░░░░░░ 0.0%   ✅ Ch19: ░░░░░░░░░░ 0.0%
✅ Ch04: ░░░░░░░░░░ 0.0%   ✅ Ch20: ░░░░░░░░░░ 0.0%
...
✅ Ch16: ░░░░░░░░░░ 0.0%   ✅ Ch32: ░░░░░░░░░░ 0.0%

──────────────────────────────────────────────────────────────────────
✅ BUS 01: ███████████████░░░░░░░░░░░░░░░ 50.0%
══════════════════════════════════════════════════════════════════════
💡 Pressione Ctrl+C para sair
```

**A tela atualiza automaticamente!** Você pode:
- Mover faders no app
- Ver os valores mudando em tempo real no terminal
- Verificar se o emulador está respondendo

---

## 🧪 Casos de Uso

### **Caso 1: Verificar se o emulador está respondendo**
```bash
dart scripts/monitor_canais.dart 192.168.9.138 1
```
Se você vê os valores, o emulador está funcionando! ✅

---

### **Caso 2: Testar se os valores mudam quando você move faders**

**Terminal 1 - Monitor em tempo real:**
```bash
dart scripts/monitor_tempo_real.dart 192.168.9.138 1 500
```

**Terminal 2 - App Flutter:**
```bash
flutter run
```

**Ação:**
1. No app, mova o fader do Canal 1 para 75%
2. Observe o terminal 1 - o valor deve mudar para 75%!

---

### **Caso 3: Comparar valores antes e depois**

**Antes de mover faders:**
```bash
dart scripts/monitor_canais.dart 192.168.9.138 1 > antes.txt
```

**Depois de mover faders:**
```bash
dart scripts/monitor_canais.dart 192.168.9.138 1 > depois.txt
```

**Compare:**
```bash
diff antes.txt depois.txt
```

---

## 🐛 Troubleshooting

### **Erro: "Nenhum canal respondeu!"**

**Causa:** Emulador não está rodando ou IP errado

**Solução:**
1. Verifique se o emulador está rodando
2. Verifique o IP correto com `ipconfig` (Windows) ou `ifconfig` (Linux/Mac)
3. Tente `127.0.0.1` se estiver no mesmo PC

---

### **Erro: "package:osc/osc.dart not found"**

**Causa:** Dependências não instaladas

**Solução:**
```bash
flutter pub get
```

---

### **Valores não mudam no monitor em tempo real**

**Causa:** Emulador não está atualizando ou intervalo muito longo

**Solução:**
1. Diminua o intervalo: `dart scripts/monitor_tempo_real.dart 192.168.9.138 1 200`
2. Verifique o terminal do emulador para ver se está recebendo comandos
3. Reinicie o emulador

---

## 💡 Dicas

### **Dica 1: Use dois terminais**
- Terminal 1: Monitor em tempo real
- Terminal 2: App Flutter
- Veja os valores mudando enquanto você usa o app!

### **Dica 2: Salve snapshots**
```bash
dart scripts/monitor_canais.dart 192.168.9.138 1 > snapshot.txt
```

### **Dica 3: Monitore diferentes mixes**
```bash
# Terminal 1 - Mix 1
dart scripts/monitor_tempo_real.dart 192.168.9.138 1

# Terminal 2 - Mix 2
dart scripts/monitor_tempo_real.dart 192.168.9.138 2
```

### **Dica 4: Intervalo mais rápido para testes**
```bash
dart scripts/monitor_tempo_real.dart 192.168.9.138 1 100
```
Atualiza 10x por segundo!

---

## 🎯 Exemplo Completo de Teste

### **Objetivo:** Verificar se o app está enviando valores corretamente

**Passo 1: Inicie o emulador**
```
X32.exe
```

**Passo 2: Inicie o monitor em tempo real**
```bash
dart scripts/monitor_tempo_real.dart 192.168.9.138 1 500
```

**Passo 3: Inicie o app**
```bash
flutter run
```

**Passo 4: No app:**
1. Conecte ao emulador
2. Mova o fader do Canal 1 para 50%
3. Mova o fader do Canal 2 para 75%
4. Mova o fader master do bus para 80%

**Passo 5: Observe o terminal do monitor**
Você deve ver:
```
✅ Ch01: █████░░░░░ 50.0%
✅ Ch02: ████████░░ 75.0%
...
✅ BUS 01: ████████████████░░░░░░░░░░░░░░ 80.0%
```

**Se os valores batem:** ✅ Tudo funcionando!
**Se os valores não batem:** ❌ Há um problema na comunicação

---

## 📊 Interpretando os Resultados

### **Símbolos:**
- ✅ = Canal respondeu
- ⏳ = Aguardando resposta
- ⚠️ = Sem resposta

### **Barras:**
- `█` = Nível preenchido
- `░` = Nível vazio

### **Percentagem:**
- 0% = Mudo / -∞ dB
- 50% = Meio caminho / ~-10 dB
- 75% = Alto / ~-5 dB
- 100% = Máximo / 0 dB

---

**Boa sorte com os testes! 🚀**

