# 🧪 Como Testar o App com X32 Emulator

## ✅ Pré-requisitos

Você já tem o X32 Emulator rodando! 🎉

```
X32 - v0.88 - An X32 Emulator - (c)2014-2019 Patrick-Gilles Maillot
Listening to port: 10023, X32 IP = 192.168.9.138
Reading init file... Done
```

---

## 🚀 Passo a Passo

### **1. Execute o App**

No terminal do projeto:

```bash
flutter run
```

Ou abra no Android Studio/VS Code e clique em "Run"

---

### **2. Na Tela Inicial do App**

Você verá a tela de conexão com:
- Campo de IP
- Campo de Porta
- Botão "CONECTAR"
- **Botão "Testar Conexão OSC"** ← Clique aqui!

---

### **3. Na Tela de Teste**

Agora você tem uma tela completa de testes com:

#### **📡 Campos de Conexão (no topo)**

Digite o IP conforme seu cenário:

| Cenário | IP a usar | Porta |
|---------|-----------|-------|
| **Emulador Android (mesmo PC)** | `10.0.2.2` | `10023` |
| **Celular físico (mesma rede)** | `192.168.9.138` | `10023` |
| **Desktop Windows** | `127.0.0.1` | `10023` |

Depois clique em **"CONECTAR"**

---

### **4. Teste os Comandos OSC**

Após conectar, use os botões:

#### **🎯 Teste Completo (Recomendado)**
Clique em **"Teste Completo"** para executar automaticamente:
- ✅ Solicitar info do console
- ✅ Enviar keep-alive
- ✅ Solicitar nomes dos canais 1, 2, 3
- ✅ Definir níveis: Canal 1 = 25%, Canal 2 = 50%, Canal 3 = 75%
- ✅ Definir Bus 1 = 60%

#### **📤 Testes Individuais**
- **`/info`** - Informações do console
- **`/xremote`** - Keep-alive (mantém conexão)
- **`Nome Ch1`** - Solicita nome do canal 1
- **`Ch1 → 75%`** - Define canal 1 em 75%
- **`Bus1 → 50%`** - Define bus 1 em 50%

---

### **5. Observe os Resultados**

#### **No App (área de logs):**

Você verá mensagens coloridas:

```
📤 ENVIANDO: /info
✅ RECEBIDO: /info
   Args: [X32]

📤 ENVIANDO: Definir Canal 1 Mix 1 = 0.75
📤 ENVIANDO: /ch/01/mix/01/level (solicitar confirmação)
✅ RECEBIDO: /ch/01/mix/01/level
   Args: [0.75]
```

**Legenda:**
- 📤 **Azul** = Comando enviado
- ✅ **Verde** = Resposta recebida do emulador
- ❌ **Vermelho** = Erro
- 💡 **Amarelo** = Informação

#### **No Terminal do Emulador:**

Você verá algo assim:

```
->X,   20 B: /info~~~~~~~~~~~~~~
X->,   28 B: /info~~~,s~~X32~~~~

->X,   28 B: /ch/01/mix/01/level,f~~[0.7500]
X->,   28 B: /ch/01/mix/01/level,f~~[0.7500]
```

**Legenda:**
- `->X` = Comando **recebido** pelo emulador
- `X->` = Resposta **enviada** pelo emulador

---

## ✅ Checklist de Sucesso

Se tudo estiver funcionando, você deve ver:

- [x] Status muda de "❌ Desconectado" para "✅ Conectado"
- [x] Logs aparecem na área preta
- [x] Comandos enviados (📤 azul)
- [x] Respostas recebidas (✅ verde)
- [x] Terminal do emulador mostra `->X` e `X->`
- [x] Valores enviados correspondem aos recebidos

---

## 🐛 Problemas Comuns

### **Problema 1: "❌ ERRO: Falha ao conectar"**

**Soluções:**

1. **Verifique se o emulador está rodando**
   - O terminal deve mostrar: `Listening to port: 10023`

2. **Verifique o IP correto:**
   - Emulador Android: `10.0.2.2`
   - Celular: `192.168.9.138`
   - Desktop: `127.0.0.1`

3. **Verifique a porta:** `10023`

4. **Firewall do Windows:**
   - Pode estar bloqueando a porta 10023
   - Tente desabilitar temporariamente

---

### **Problema 2: Conecta mas não recebe respostas**

**Soluções:**

1. **Verifique o terminal do emulador**
   - Se aparecer `->X`, os comandos estão chegando
   - Se não aparecer nada, o IP está errado

2. **Aguarde alguns segundos**
   - Algumas respostas podem demorar

3. **Use comandos de consulta**
   - Comandos sem parâmetros retornam valores
   - Ex: `/ch/01/mix/01/level` (sem valor)

---

### **Problema 3: App trava ou não responde**

**Soluções:**

1. **Reinicie o app**
2. **Limpe os logs** (botão 🗑️ no topo)
3. **Desconecte e conecte novamente**

---

## 📊 Valores de Teste

### **Níveis (Faders):**
- `0.0` = -∞ dB (mínimo/mute)
- `0.25` = -18 dB (baixo)
- `0.5` = -6 dB (médio)
- `0.75` = +3 dB (alto)
- `1.0` = +10 dB (máximo)

### **Canais Disponíveis:**
- Canais: `01` a `32`
- Aux: `01` a `08`

### **Mix Buses Disponíveis:**
- Mix Buses: `01` a `16`

---

## 🎉 Próximos Passos

Depois de confirmar que está funcionando:

1. ✅ Volte para a tela inicial
2. ✅ Conecte normalmente (sem modo teste)
3. ✅ Teste a tela principal do mixer
4. ✅ Teste os faders visuais
5. ✅ Teste a seleção de diferentes mix buses

---

## 💡 Dicas

- **Limpe os logs** regularmente para facilitar a leitura
- **Use "Teste Completo"** primeiro para validar tudo
- **Observe o terminal do emulador** para debug
- O emulador **mantém estado** (valores definidos são lembrados)
- Use **`/shutdown`** no emulador para salvar antes de fechar

---

## 📝 Comandos OSC Úteis

### **Informações:**
```
/info                           # Info do console
/xremote                        # Keep-alive
```

### **Canais:**
```
/ch/01/config/name              # Nome do canal
/ch/01/mix/01/level ,f 0.75     # Nível no mix
/ch/01/mix/01/pan ,f 0.5        # Pan (0=L, 0.5=C, 1=R)
/ch/01/mix/on ,i 1              # On/Off (0=mute, 1=on)
```

### **Buses:**
```
/bus/01/mix/fader ,f 0.75       # Fader do bus
/bus/01/config/name             # Nome do bus
```

---

## 🆘 Precisa de Ajuda?

Se algo não funcionar:

1. ✅ Verifique os logs na tela de teste
2. ✅ Verifique o terminal do emulador
3. ✅ Compare os IPs e portas
4. ✅ Teste com "Teste Completo"
5. ✅ Leia este guia novamente 😊

---

**Boa sorte! 🚀**

Se tudo funcionar, você verá comandos sendo enviados e recebidos em tempo real!

