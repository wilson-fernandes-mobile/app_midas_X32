# 🔍 Debug: Alguns Canais Carregam, Outros Não

## 🎯 Situação

Você reportou que **alguns canais carregam** e **outros não**.

---

## 📊 Teste de Diagnóstico

### **Passo 1: Execute o app com logs detalhados**

Agora o app mostra logs MUITO detalhados:

```
📤 Solicitando: /ch/01/mix/01/level
📥 OSC recebido: /ch/01/mix/01/level [0.0]
🎛️ MixerVM recebeu: /ch/01/mix/01/level [0.0]
🎚️ Atualizando nível do canal 1 no mix 1: 0.0

📤 Solicitando: /ch/02/mix/01/level
📥 OSC recebido: /ch/02/mix/01/level [0.0]
🎛️ MixerVM recebeu: /ch/02/mix/01/level [0.0]
🎚️ Atualizando nível do canal 2 no mix 1: 0.0

... (continua para todos os 32 canais)
```

---

### **Passo 2: Identifique o padrão**

Observe os logs e responda:

#### **Pergunta 1: Todos os canais são SOLICITADOS?**
- ✅ Você vê `📤 Solicitando: /ch/01/mix/01/level` até `/ch/32/mix/01/level`?
- ❌ Ou para em algum canal específico?

#### **Pergunta 2: Todos os canais são RECEBIDOS?**
- ✅ Você vê `📥 OSC recebido:` para todos os 32 canais?
- ❌ Ou alguns canais não têm resposta?

#### **Pergunta 3: Todos os canais são PROCESSADOS?**
- ✅ Você vê `🎚️ Atualizando nível do canal X` para todos?
- ❌ Ou alguns canais não são atualizados?

---

## 🐛 Cenários Possíveis

### **Cenário A: Solicitações param no meio**

**Sintoma:**
```
📤 Solicitando: /ch/01/mix/01/level
📤 Solicitando: /ch/02/mix/01/level
📤 Solicitando: /ch/03/mix/01/level
... (para aqui, não chega até 32)
```

**Causa:** Erro no loop ou timeout

**Solução:** Aumentar o delay entre solicitações

---

### **Cenário B: Emulador não responde para alguns canais**

**Sintoma:**
```
📤 Solicitando: /ch/01/mix/01/level
📥 OSC recebido: /ch/01/mix/01/level [0.0]

📤 Solicitando: /ch/02/mix/01/level
(sem resposta)

📤 Solicitando: /ch/03/mix/01/level
📥 OSC recebido: /ch/03/mix/01/level [0.0]
```

**Causa:** Emulador não está respondendo para alguns canais

**Solução:** Verificar terminal do emulador

---

### **Cenário C: Parsing falha para alguns canais**

**Sintoma:**
```
📤 Solicitando: /ch/01/mix/01/level
📥 OSC recebido: /ch/01/mix/01/level [0.0]
🎛️ MixerVM recebeu: /ch/01/mix/01/level [0.0]
🎚️ Atualizando nível do canal 1 no mix 1: 0.0

📤 Solicitando: /ch/02/mix/01/level
📥 OSC recebido: /ch/02/mix/01/level [0.0]
🎛️ MixerVM recebeu: /ch/02/mix/01/level [0.0]
(sem atualização)
```

**Causa:** Erro no parsing do número do canal

**Solução:** Verificar código de parsing

---

### **Cenário D: Só canais com valores definidos aparecem**

**Sintoma:**
- Canais que você testou na tela de teste aparecem
- Canais que você não testou ficam em 0% ou não aparecem

**Causa:** Isso é NORMAL! O emulador só retorna valores que foram definidos

**Solução:** Defina valores em todos os canais que você quer testar

---

## 🧪 Teste Específico

### **Teste 1: Defina valores em canais específicos**

1. **Tela de Teste:**
   - Conecte
   - Defina Canal 1 = 25%
   - Defina Canal 5 = 50%
   - Defina Canal 10 = 75%
   - Desconecte

2. **Tela Principal:**
   - Conecte
   - Observe quais canais aparecem com valores

3. **Resultado Esperado:**
   - Canal 1 deve mostrar 25%
   - Canal 5 deve mostrar 50%
   - Canal 10 deve mostrar 75%
   - Outros canais devem mostrar 0%

---

### **Teste 2: Verifique o terminal do emulador**

Quando você entra na tela do mixer, o terminal do emulador deve mostrar:

```
->X,   28 B: /ch/01/mix/01/level
X->,   28 B: /ch/01/mix/01/level,f~~[0.2500]

->X,   28 B: /ch/02/mix/01/level
X->,   28 B: /ch/02/mix/01/level,f~~[0.0000]

->X,   28 B: /ch/03/mix/01/level
X->,   28 B: /ch/03/mix/01/level,f~~[0.0000]

... (continua para todos os 32 canais)
```

**Verifique:**
- ✅ Você vê `->X` para todos os 32 canais?
- ✅ Você vê `X->` (resposta) para todos os 32 canais?
- ❌ Algum canal não tem resposta?

---

## 🔧 Possíveis Correções

### **Correção 1: Aumentar delay entre solicitações**

Se o emulador está perdendo algumas solicitações, podemos aumentar o delay:

**Arquivo:** `lib/services/osc_service.dart`

**Linha 161:** Mudar de `10ms` para `50ms`:
```dart
await Future.delayed(const Duration(milliseconds: 50));
```

---

### **Correção 2: Adicionar retry para canais sem resposta**

Podemos adicionar lógica para reenviar solicitações que não tiveram resposta.

---

### **Correção 3: Verificar parsing de números**

Vamos verificar se o parsing está funcionando para todos os números de canal (01-32).

---

## 📋 Checklist de Diagnóstico

Execute o app e marque:

- [ ] Vejo `📤 Solicitando:` para todos os 32 canais
- [ ] Vejo `📥 OSC recebido:` para todos os 32 canais
- [ ] Vejo `🎛️ MixerVM recebeu:` para todos os 32 canais
- [ ] Vejo `🎚️ Atualizando nível:` para todos os 32 canais
- [ ] Terminal do emulador mostra `->X` para todos os 32 canais
- [ ] Terminal do emulador mostra `X->` para todos os 32 canais
- [ ] Faders na tela mostram os valores corretos

---

## 💡 Próximos Passos

**Me envie:**

1. **Quais canais carregam?** (Ex: 1, 2, 3, 5, 7...)
2. **Quais canais NÃO carregam?** (Ex: 4, 6, 8, 9...)
3. **Copie alguns logs do console** mostrando o padrão
4. **Copie algumas linhas do terminal do emulador**

Com essas informações, posso identificar exatamente o problema! 🎯

---

**Execute o app agora e observe os logs!** 🚀

