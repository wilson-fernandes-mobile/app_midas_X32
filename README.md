# CCL Midas - Personal Monitor Mixer

Aplicativo Flutter para controle pessoal de monitor (in-ear) para consoles **Midas M32** e **Behringer X32**.

## 🎵 Funcionalidades

- ✅ Conexão via WiFi com console M32/X32
- ✅ Controle de volume (faders) de todos os 32 canais
- ✅ **Fader Master do Bus** - Controle de volume geral do mix
- ✅ Seleção de mix (bus de monitor) de 1 a 16
- ✅ Botões de Mute por canal
- ✅ Visualização de nível em dB
- ✅ Interface intuitiva e responsiva com tema laranja (#FF723A)
- ✅ Salva último IP conectado
- ✅ Comunicação OSC em tempo real
- ✅ Permissões de rede configuradas para iOS e Android

## 🏗️ Arquitetura

O projeto utiliza **MVVM (Model-View-ViewModel)** com **Provider** para gerenciamento de estado:

```
lib/
├── models/              # Modelos de dados
│   ├── channel.dart
│   ├── mix_bus.dart
│   └── console_info.dart
├── viewmodels/          # Lógica de negócio
│   ├── connection_viewmodel.dart
│   └── mixer_viewmodel.dart
├── views/               # Telas da interface
│   ├── connection_screen.dart
│   └── mixer_screen.dart
├── services/            # Serviços (OSC)
│   └── osc_service.dart
└── main.dart
```

## 🚀 Como usar

### 1. Pré-requisitos

- Flutter 3.24 ou superior
- Console Midas M32 ou Behringer X32
- Dispositivo móvel/tablet conectado na mesma rede WiFi do console

### 2. Permissões de Rede

O app requer permissões de rede para se comunicar com o console via protocolo OSC/UDP:

**iOS (Info.plist):**
- ✅ `NSLocalNetworkUsageDescription` - Acesso à rede local
- ✅ `NSBonjourServices` - Descoberta de serviços OSC

**Android (AndroidManifest.xml):**
- ✅ `INTERNET` - Acesso à internet
- ✅ `ACCESS_NETWORK_STATE` - Estado da rede
- ✅ `ACCESS_WIFI_STATE` - Estado do WiFi
- ✅ `CHANGE_WIFI_MULTICAST_STATE` - Multicast UDP

> **Nota:** No iOS, o usuário verá um popup solicitando permissão para acessar a rede local na primeira vez que o app tentar se conectar ao console.

### 3. Instalação

```bash
# Instale as dependências
flutter pub get

# Execute o app
flutter run
```

### 3. Conectando ao console

1. Certifique-se de que seu dispositivo está na mesma rede WiFi do console
2. Abra o app
3. Digite o endereço IP do console (ex: `192.168.1.100`)
4. A porta padrão é `10023` (não precisa alterar)
5. Toque em **CONECTAR**

### 4. Usando o mixer

1. Após conectar, selecione seu mix (bus de monitor) tocando no ícone de configurações
2. Ajuste o volume de cada canal usando os faders verticais
3. Use os botões **MUTE** para silenciar canais
4. O nível em dB é exibido abaixo de cada fader

## 🔧 Protocolo OSC

O app se comunica com o console usando o protocolo **OSC (Open Sound Control)** via UDP na porta **10023**.

### Comandos principais:

```
/ch/01/mix/01/level    # Volume do canal 1 no mix 1
/ch/01/mix/01/pan      # Pan do canal 1 no mix 1
/ch/01/config/name     # Nome do canal 1
/bus/01/config/name    # Nome do bus 1
/xremote               # Keep-alive (necessário a cada 10s)
```

## 📱 Plataformas suportadas

- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ Linux
- ✅ macOS
- ✅ Web

## 🛠️ Tecnologias utilizadas

- **Flutter** - Framework multiplataforma
- **Provider** - Gerenciamento de estado
- **OSC** - Protocolo de comunicação com o console
- **SharedPreferences** - Armazenamento local

## 📝 Notas importantes

- O console desconecta automaticamente após 10 segundos sem receber mensagens. O app envia comandos keep-alive automaticamente.
- Certifique-se de que não há firewall bloqueando a porta UDP 10023.
- O app foi testado com Midas M32, mas é compatível com Behringer X32 (mesmo protocolo).

## 🎯 Próximas melhorias

- [ ] Controle de Pan (panorama)
- [ ] Grupos de canais (MCA - Mix Control Association)
- [ ] Equalização por canal
- [ ] Presets de mix
- [ ] Descoberta automática de console na rede
- [ ] Modo landscape otimizado
- [ ] Medidores de nível (VU meters)

---

Desenvolvido com ❤️ para músicos que querem controlar seu próprio som!
