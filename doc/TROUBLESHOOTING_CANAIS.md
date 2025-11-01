# 🔧 Troubleshooting: Canais não carregam informações

## 🎯 Problema

Você testou na tela de teste e funcionou, mas quando entra na tela dos canais (mixer), as informações definidas no teste não aparecem.

---

## ✅ Solução Passo a Passo

### **1. Execute o app com logs de debug**

```bash
flutter run
```

Observe o console/terminal. Agora o app mostra logs detalhados:

```
🎯 Selecionando Mix 1...
📡 Solicitando informações do Mix 1...
📋 Solicitando info de todos os canais para Mix 1...
✅ Solicitações enviadas para Mix 1!
✅ Mix 1 selecionado!

🎛️ MixerVM recebeu: /ch/01/config/name [Ch 01]
📝 Atualizando nome do canal 1: Ch 01

🎛️ MixerVM recebeu: /ch/01/mix/01/level [0.75]
🎚️ Atualizando nível do canal 1 no mix 1: 0.75
```

---

### **2. Teste o fluxo completo**

#### **Passo 1: Tela de Teste**
1. Abra a tela de teste (botão "Testar Conexão OSC")
2. Conecte ao emulador
3. Execute "Teste Completo"
4. Observe os logs:
   ```
   📤 ENVIANDO: Definir Canal 1 Mix 1 = 0.25
   ✅ RECEBIDO: /ch/01/mix/01/level
      Args: [0.25]
   ```

#### **Passo 2: Volte e Conecte Normalmente**
1. Volte para a tela inicial
2. Clique em "CONECTAR" (não no teste)
3. Digite o mesmo IP e porta
4. Conecte

#### **Passo 3: Observe a Tela do Mixer**
1. A tela deve mostrar "Mix 1 carregado!"
2. Observe o console do app para ver os logs
3. Observe o terminal do emulador

---

### **3. Use o botão Recarregar**

Na tela do mixer, clique no botão **↻ (Refresh)** no canto superior direito.

Isso vai:
- Solicitar novamente todas as informações do Mix 1
- Mostrar "✅ Informações recarregadas!"
- Atualizar os faders com os valores do emulador

---

### **4. Verifique o Terminal do Emulador**

Quando você entra na tela do mixer, o terminal do emulador deve mostrar:

```
->X,   20 B: /ch/01/config/name~
X->,   28 B: /ch/01/config/name~,s~~Ch 01~~~~

->X,   28 B: /ch/01/mix/01/level
X->,   28 B: /ch/01/mix/01/level,f~~[0.2500]

->X,   20 B: /ch/02/config/name~
X->,   28 B: /ch/02/config/name~,s~~Ch 02~~~~

->X,   28 B: /ch/02/mix/01/level
X->,   28 B: /ch/02/mix/01/level,f~~[0.5000]

... (continua para todos os 32 canais)
```

**Se você NÃO vê isso:**
- O app não está enviando as solicitações
- Verifique os logs do app

**Se você vê `->X` mas não vê `X->`:**
- O emulador está recebendo mas não está respondendo
- Reinicie o emulador

---

## 🐛 Problemas Comuns

### **Problema 1: Faders aparecem em 0%**

**Causa:** O emulador não tem valores definidos ou não está respondendo.

**Solução:**
1. Use a tela de teste para definir valores primeiro
2. Depois entre na tela do mixer
3. Clique em Recarregar (↻)

---

### **Problema 2: Nomes aparecem como "Ch 1", "Ch 2"...**

**Causa:** O emulador está retornando nomes padrão.

**Solução:**
- Isso é normal! O emulador usa nomes padrão
- Os nomes estão sendo carregados corretamente
- Se quiser nomes customizados, você precisaria de uma mesa real

---

### **Problema 3: Valores não atualizam quando movo o fader**

**Causa:** Conexão perdida ou emulador não está respondendo.

**Solução:**
1. Verifique se ainda está conectado (status no topo)
2. Observe o terminal do emulador
3. Quando você move um fader, deve aparecer:
   ```
   ->X,   28 B: /ch/01/mix/01/level,f~~[0.5000]
   ```
4. Se não aparecer, a conexão foi perdida
5. Desconecte e reconecte

---

### **Problema 4: App mostra "Carregando..." infinitamente**

**Causa:** O app está esperando respostas que não chegam.

**Solução:**
1. Feche o app
2. Reinicie o emulador
3. Abra o app novamente
4. Conecte

---

### **Problema 5: Valores do teste não aparecem no mixer**

**Causa:** Você pode ter conectado em sessões diferentes.

**Explicação:**
- Quando você testa na "Tela de Teste", cria uma conexão
- Quando você "Conecta" na tela principal, cria OUTRA conexão
- São duas conexões diferentes!

**Solução Correta:**

**Opção A: Teste primeiro, depois use**
1. Tela de Teste → Conecte → Defina valores → Desconecte
2. Tela Principal → Conecte → Use o mixer
3. Os valores devem estar lá (emulador mantém estado)

**Opção B: Use só a tela principal**
1. Tela Principal → Conecte
2. Use os faders para definir valores
3. Valores são enviados automaticamente

---

## 📊 Como Verificar se Está Funcionando

### **Teste Rápido:**

1. **Conecte na tela principal**
2. **Mova o fader do Canal 1 para 50%**
3. **Observe o terminal do emulador:**
   ```
   ->X,   28 B: /ch/01/mix/01/level,f~~[0.5000]
   ```
4. **Observe o console do app:**
   ```
   🎚️ Atualizando nível do canal 1 no mix 1: 0.5
   ```

Se você vê ambos, **está funcionando perfeitamente!** ✅

---

## 🔍 Logs Importantes

### **Logs do App (Console Flutter):**

```
🎯 Selecionando Mix 1...                    # Iniciando seleção
📡 Solicitando informações do Mix 1...      # Enviando solicitações
📋 Solicitando info de todos os canais...   # Loop pelos 32 canais
✅ Solicitações enviadas para Mix 1!        # Todas enviadas
✅ Mix 1 selecionado!                       # Concluído

🎛️ MixerVM recebeu: /ch/01/mix/01/level    # Resposta recebida
🎚️ Atualizando nível do canal 1: 0.75      # Valor atualizado
```

### **Logs do Emulador (Terminal):**

```
->X,   28 B: /ch/01/mix/01/level            # Solicitação recebida
X->,   28 B: /ch/01/mix/01/level,f~~[0.75]  # Resposta enviada
```

---

## 🎯 Fluxo Correto de Uso

### **Para Testar Comunicação:**
1. Tela Inicial → "Testar Conexão OSC"
2. Conecte
3. Execute testes
4. Observe logs
5. Desconecte

### **Para Usar o Mixer:**
1. Tela Inicial → "CONECTAR"
2. Aguarde "Mix 1 carregado!"
3. Use os faders
4. Clique em ↻ para recarregar se necessário

---

## 💡 Dicas

### **Dica 1: Sempre observe os logs**
Os logs mostram exatamente o que está acontecendo:
- 📤 = Enviado
- ✅ = Recebido
- 🎚️ = Atualizado

### **Dica 2: Use o botão Recarregar**
Se algo não aparece, clique em ↻ (Refresh)

### **Dica 3: Emulador mantém estado**
Os valores que você define ficam salvos no emulador até você fechá-lo

### **Dica 4: Keep-alive automático**
O app envia `/xremote` a cada 5 segundos automaticamente

### **Dica 5: Verifique o terminal do emulador**
É a melhor forma de saber se os comandos estão chegando

---

## 🆘 Ainda Não Funciona?

Se depois de tudo isso ainda não funcionar:

1. **Copie os logs do console do app**
2. **Copie os logs do terminal do emulador**
3. **Descreva exatamente o que você fez**
4. **Descreva o que esperava vs o que aconteceu**

---

## ✅ Checklist Final

- [ ] Emulador rodando e mostrando "Listening to port: 10023"
- [ ] App conectado (status verde)
- [ ] Logs do app mostram "🎯 Selecionando Mix 1..."
- [ ] Logs do app mostram "✅ Mix 1 selecionado!"
- [ ] Terminal do emulador mostra `->X` quando você move faders
- [ ] Faders respondem quando você os move
- [ ] Botão ↻ recarrega as informações

Se todos os itens estão ✅, **está funcionando perfeitamente!** 🎉

---

**Boa sorte! 🚀**

