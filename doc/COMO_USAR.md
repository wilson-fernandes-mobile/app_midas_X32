# 📖 Como Usar o CCL Midas

## 🎯 Guia Rápido

### Passo 1: Preparar o Console

1. Ligue o console Midas M32 ou Behringer X32
2. Conecte o console à rede WiFi (via cabo ethernet ou WiFi)
3. Anote o endereço IP do console:
   - No console, vá em **SETUP** → **Network**
   - Você verá o IP (exemplo: `192.168.1.100`)

### Passo 2: Conectar seu Dispositivo

1. Conecte seu celular/tablet na **mesma rede WiFi** do console
2. Abra o app **CCL Midas**
3. Digite o IP do console
4. Toque em **CONECTAR**

### Passo 3: Selecionar seu Mix

1. Após conectar, toque no ícone de **configurações** (⚙️) no canto superior direito
2. Selecione o número do seu mix (bus de monitor)
   - Exemplo: Se você está no **Mix 1**, selecione **Mix 1**
   - Pergunte ao técnico de som qual é o seu mix se não souber

### Passo 4: Ajustar seu Som

1. **Faders verticais**: Arraste para cima/baixo para ajustar o volume de cada canal
2. **Botão MUTE**: Toque para silenciar um canal
3. **Indicador dB**: Mostra o nível em decibéis abaixo de cada fader

## 🔍 Como Descobrir o IP do Console

### Método 1: Pelo Console (Mais Fácil)

1. No console M32/X32, pressione **SETUP**
2. Vá em **Network**
3. O IP estará exibido na tela

### Método 2: Pelo Roteador

1. Acesse a interface web do seu roteador
2. Procure por "Dispositivos Conectados" ou "DHCP Clients"
3. Procure por um dispositivo chamado "M32" ou "X32"

### Método 3: Usando App de Scanner de Rede

1. Instale um app como **Fing** (Android/iOS)
2. Escaneie a rede
3. Procure por dispositivos com porta **10023** aberta

## 🎚️ Dicas de Uso

### Para Músicos

- **Comece com tudo baixo**: Suba os faders gradualmente
- **Priorize sua voz/instrumento**: Deixe seu canal principal mais alto
- **Use o mute**: Silencie canais que você não precisa ouvir
- **Comunique-se**: Avise o técnico se algo estiver errado no PA

### Para Técnicos de Som

- **Configure os mixes antes**: Deixe um mix base para cada músico
- **Ensine os músicos**: Mostre como usar o app antes do show
- **Monitore o PA**: O app só controla os mixes, não o PA principal
- **Tenha backup**: Mantenha controle manual caso o WiFi falhe

## ⚠️ Solução de Problemas

### Não consigo conectar

1. ✅ Verifique se está na mesma rede WiFi do console
2. ✅ Confirme o IP do console
3. ✅ Verifique se a porta 10023 não está bloqueada
4. ✅ Tente desligar e ligar o WiFi do celular
5. ✅ Reinicie o console se necessário

### Conexão cai frequentemente

1. ✅ Aproxime-se do roteador WiFi
2. ✅ Verifique se há muitos dispositivos na rede
3. ✅ Use WiFi 5GHz se disponível (menos interferência)
4. ✅ Evite usar durante passagem de som (muitos comandos simultâneos)

### Faders não respondem

1. ✅ Verifique se selecionou o mix correto
2. ✅ Confirme que o console está recebendo comandos (LED de rede piscando)
3. ✅ Desconecte e reconecte o app
4. ✅ Verifique se outro app não está controlando o console

### Nomes dos canais não aparecem

1. ✅ Aguarde alguns segundos após conectar
2. ✅ Toque no botão de **refresh** (🔄)
3. ✅ Verifique se os canais têm nomes configurados no console

## 🎵 Configuração Recomendada para Bandas

### Para Vocalista
- **Mix 1**: Vocal principal alto, backing vocals médio, instrumentos baixo

### Para Guitarrista
- **Mix 2**: Guitarra alta, bateria média, vocal médio, baixo baixo

### Para Baixista
- **Mix 3**: Baixo alto, bateria alta (bumbo e caixa), vocal médio

### Para Baterista
- **Mix 4**: Bateria completa, click track (se usar), vocal baixo

### Para Tecladista
- **Mix 5**: Teclado alto, vocal médio, bateria baixa

## 📱 Recursos do App

### Tela de Conexão
- Campo para IP do console
- Campo para porta (padrão: 10023)
- Botão de conectar
- Salva último IP usado

### Tela do Mixer
- 32 canais com faders verticais
- Nome de cada canal
- Número do canal
- Indicador de nível em dB
- Botão de mute por canal
- Seletor de mix (1-16)
- Botão de refresh
- Botão de desconectar

## 🔐 Segurança

- O app **não altera** o mix principal (PA)
- O app **não altera** configurações do console
- O app **só controla** os sends para os mixes de monitor
- O técnico de som mantém controle total do console

## 💡 Boas Práticas

1. **Teste antes do show**: Familiarize-se com o app durante o ensaio
2. **Tenha bateria**: Mantenha seu dispositivo carregado
3. **Modo avião + WiFi**: Evite chamadas durante a apresentação
4. **Não exagere**: Volumes muito altos podem danificar sua audição
5. **Comunique-se**: Fale com o técnico se precisar de ajustes no PA

## 🆘 Suporte

Se tiver problemas:
1. Leia este guia completamente
2. Verifique a seção de solução de problemas
3. Consulte o técnico de som
4. Abra uma issue no GitHub (se for bug do app)

---

**Bom show! 🎸🎤🥁🎹**

