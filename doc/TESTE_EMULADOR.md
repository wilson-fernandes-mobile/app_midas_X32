# 🧪 Guia de Teste com X32 Emulator

## 📋 Pré-requisitos

✅ X32 Emulator rodando (você já tem!)
✅ IP do PC: `192.168.9.138`
✅ Porta: `10023`

---

## 🎯 Como Testar

### **Opção 1: Teste Visual no App (RECOMENDADO)**

1. **Execute o app CCLMidas**
   ```bash
   flutter run
   ```

2. **Na tela inicial, clique em "Testar Conexão OSC"**

3. **Digite o IP:**
   - Se testar no **mesmo PC** (emulador Android): `10.0.2.2`
   - Se testar no **celular**: `192.168.9.138`
   - Porta: `10023`

4. **Clique em "CONECTAR"**

5. **Use os botões de teste:**
   - **"Teste Completo"** - Executa todos os testes automaticamente
   - **"/info"** - Solicita informações do console
   - **"/xremote"** - Comando keep-alive
   - **"Nome Ch1"** - Solicita nome do canal 1
   - **"Ch1 → 75%"** - Define canal 1 em 75%
   - **"Bus1 → 50%"** - Define bus 1 em 50%

6. **Observe os logs:**
   - 📤 **Azul** = Comando enviado
   - ✅ **Verde** = Resposta recebida
   - ❌ **Vermelho** = Erro

---

### **Opção 2: Teste Manual com Comandos OSC**

Se você quiser testar manualmente os comandos OSC que o emulador aceita:

#### **Comandos Básicos:**

```
/info                           # Informações do console
/xremote                        # Keep-alive
```

#### **Nomes de Canais:**

```
/ch/01/config/name              # Nome do canal 1
/ch/02/config/name              # Nome do canal 2
...
/ch/32/config/name              # Nome do canal 32
```

#### **Níveis de Canais no Mix:**

```
/ch/01/mix/01/level ,f 0.75     # Canal 1 no Mix 1 = 75%
/ch/02/mix/01/level ,f 0.50     # Canal 2 no Mix 1 = 50%
/ch/03/mix/01/level ,f 0.25     # Canal 3 no Mix 1 = 25%
```

#### **Pan de Canais:**

```
/ch/01/mix/01/pan ,f 0.5        # Canal 1 no Mix 1 = Centro
/ch/01/mix/01/pan ,f 0.0        # Canal 1 no Mix 1 = Esquerda
/ch/01/mix/01/pan ,f 1.0        # Canal 1 no Mix 1 = Direita
```

#### **Faders de Bus:**

```
/bus/01/mix/fader ,f 0.75       # Bus 1 = 75%
/bus/02/mix/fader ,f 0.50       # Bus 2 = 50%
```

#### **Mute de Canais:**

```
/ch/01/mix/on ,i 0              # Mute canal 1
/ch/01/mix/on ,i 1              # Unmute canal 1
```

---

## 🔍 O Que Observar no Emulador

Quando você enviar comandos do app, o terminal do X32 Emulator deve mostrar:

```
->X,   20 B: /info~~~~~~~~~~~~~~
X->,   28 B: /info~~~,s~~X32~~~~

->X,   12 B: /xremote~~~
X->,   12 B: /xremote~~~

->X,   20 B: /ch/01/config/name~
X->,   28 B: /ch/01/config/name~,s~~Ch 01~~~~

->X,   28 B: /ch/01/mix/01/level,f~~[0.7500]
X->,   28 B: /ch/01/mix/01/level,f~~[0.7500]
```

**Legenda:**
- `->X` = Comando **recebido** pelo emulador
- `X->` = Resposta **enviada** pelo emulador

---

## ✅ Checklist de Testes

### **Teste 1: Conexão Básica**
- [ ] App conecta ao emulador
- [ ] Comando `/info` retorna resposta
- [ ] Comando `/xremote` é aceito

### **Teste 2: Nomes de Canais**
- [ ] Solicitar nome do canal 1
- [ ] Solicitar nome do canal 2
- [ ] Receber respostas com nomes

### **Teste 3: Controle de Níveis**
- [ ] Definir canal 1 em 25%
- [ ] Definir canal 2 em 50%
- [ ] Definir canal 3 em 75%
- [ ] Solicitar valores de volta
- [ ] Valores retornados correspondem aos enviados

### **Teste 4: Controle de Bus**
- [ ] Definir bus 1 em 60%
- [ ] Solicitar valor de volta
- [ ] Valor retornado corresponde ao enviado

### **Teste 5: Keep-Alive**
- [ ] Conexão permanece ativa por mais de 10 segundos
- [ ] Comandos `/xremote` são enviados automaticamente a cada 5s

---

## 🐛 Troubleshooting

### **Problema: App não conecta**

**Solução:**
1. Verifique se o emulador está rodando
2. Confirme o IP correto:
   - Emulador Android: `10.0.2.2`
   - Celular: `192.168.9.138`
3. Confirme a porta: `10023`
4. Verifique se o firewall não está bloqueando

### **Problema: Nenhuma resposta do emulador**

**Solução:**
1. Verifique o terminal do emulador
2. Se não aparecer `->X`, o comando não está chegando
3. Verifique a rede (mesmo WiFi)

### **Problema: Comandos chegam mas não há resposta**

**Solução:**
1. Alguns comandos não retornam resposta imediatamente
2. Use comandos de consulta (sem parâmetros) para obter respostas
3. Exemplo: `/ch/01/mix/01/level` (sem valor) solicita o valor atual

---

## 📊 Valores de Referência

### **Níveis (Level/Fader):**
- `0.0` = -∞ dB (mínimo)
- `0.25` = -18 dB
- `0.5` = -6 dB
- `0.75` = +3 dB
- `1.0` = +10 dB (máximo)

### **Pan:**
- `0.0` = Esquerda total (L)
- `0.5` = Centro (C)
- `1.0` = Direita total (R)

### **Canais:**
- Canais: `01` a `32`
- Aux: `01` a `08`

### **Mix Buses:**
- Mix Buses: `01` a `16`

---

## 🎉 Próximos Passos

Depois de confirmar que a comunicação está funcionando:

1. ✅ Teste a tela principal do mixer
2. ✅ Teste os faders visuais
3. ✅ Teste a seleção de mix bus
4. ✅ Teste múltiplos canais simultaneamente
5. ✅ Teste a persistência da conexão (keep-alive)

---

## 📝 Notas Importantes

- O emulador **não processa áudio**, apenas simula o protocolo OSC
- Todos os 32 canais estão disponíveis
- Todos os 16 mix buses estão disponíveis
- O emulador mantém estado (valores definidos são lembrados)
- Use `/shutdown` no emulador para salvar o estado antes de fechar

---

## 🆘 Precisa de Ajuda?

Se algo não funcionar:
1. Verifique os logs no terminal do emulador
2. Verifique os logs na tela de teste do app
3. Compare os comandos enviados com os esperados
4. Verifique a documentação do X32 OSC Protocol

**Boa sorte com os testes! 🚀**

