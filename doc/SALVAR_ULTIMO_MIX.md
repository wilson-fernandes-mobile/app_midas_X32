# 💾 Salvar Último Mix Usado

## 🎯 Problema

Quando você fecha o app, os valores se perdem. Você quer que o app:
1. **Salve** qual foi o último mix usado
2. **Salve** os valores dos faders (opcional)
3. **Carregue** automaticamente quando abrir de novo

---

## ✅ Solução 1: Salvar Último Mix (Simples)

Vamos usar **SharedPreferences** para salvar qual foi o último mix selecionado.

### **Passo 1: Adicionar dependência**

**Arquivo:** `pubspec.yaml`

Adicione:
```yaml
dependencies:
  shared_preferences: ^2.2.2
```

Execute:
```bash
flutter pub get
```

---

### **Passo 2: Modificar ConnectionViewModel**

Salvar o último IP e porta usados:

```dart
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionViewModel extends ChangeNotifier {
  // ... código existente ...
  
  // Salva o último IP e porta
  Future<void> _saveLastConnection(String ip, int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_ip', ip);
    await prefs.setInt('last_port', port);
  }
  
  // Carrega o último IP e porta
  Future<Map<String, dynamic>?> getLastConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('last_ip');
    final port = prefs.getInt('last_port');
    
    if (ip != null && port != null) {
      return {'ip': ip, 'port': port};
    }
    return null;
  }
  
  // Modifica o método connect para salvar
  Future<bool> connect(String ipAddress, {int port = 10023}) async {
    final success = await _oscService.connect(ipAddress, port);
    if (success) {
      await _saveLastConnection(ipAddress, port);
    }
    notifyListeners();
    return success;
  }
}
```

---

### **Passo 3: Modificar MixerViewModel**

Salvar o último mix selecionado:

```dart
import 'package:shared_preferences/shared_preferences.dart';

class MixerViewModel extends ChangeNotifier {
  // ... código existente ...
  
  // Salva o último mix selecionado
  Future<void> _saveLastMix(int mixNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_mix', mixNumber);
  }
  
  // Carrega o último mix selecionado
  Future<int> getLastMix() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('last_mix') ?? 1; // Padrão: Mix 1
  }
  
  // Modifica o método selectMix para salvar
  Future<void> selectMix(int mixNumber) async {
    if (kDebugMode) {
      print('🎯 Selecionando Mix $mixNumber...');
    }
    
    _isLoading = true;
    notifyListeners();

    _selectedMix = MixBus(
      number: mixNumber,
      name: 'Mix $mixNumber',
      channels: List.generate(32, (i) => i + 1),
    );

    if (kDebugMode) {
      print('📡 Solicitando informações do Mix $mixNumber...');
    }
    
    await _oscService.requestMixInfo(mixNumber);
    await _oscService.requestBusName(mixNumber);
    
    // Salva o último mix usado
    await _saveLastMix(mixNumber);

    if (kDebugMode) {
      print('✅ Mix $mixNumber selecionado e salvo!');
    }

    _isLoading = false;
    notifyListeners();
  }
}
```

---

### **Passo 4: Modificar ConnectionScreen**

Carregar o último IP/porta automaticamente:

```dart
class _ConnectionScreenState extends State<ConnectionScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '10023');

  @override
  void initState() {
    super.initState();
    _loadLastConnection();
  }
  
  Future<void> _loadLastConnection() async {
    final viewModel = context.read<ConnectionViewModel>();
    final lastConnection = await viewModel.getLastConnection();
    
    if (lastConnection != null) {
      setState(() {
        _ipController.text = lastConnection['ip'];
        _portController.text = lastConnection['port'].toString();
      });
    }
  }
  
  // ... resto do código ...
}
```

---

### **Passo 5: Modificar MixerScreen**

Carregar o último mix automaticamente:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadLastMix();
  });
}

Future<void> _loadLastMix() async {
  final viewModel = context.read<MixerViewModel>();
  final lastMix = await viewModel.getLastMix();
  
  await viewModel.selectMix(lastMix);
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mix $lastMix carregado! (último usado)'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );
  }
}
```

---

## ✅ Solução 2: Salvar Valores dos Faders (Avançado)

Se você quiser salvar os **valores dos faders** também (não só qual mix foi usado):

### **Opção A: Salvar no App (Offline)**

Salvar os valores localmente no app usando SharedPreferences ou SQLite.

**Vantagens:**
- ✅ Funciona offline
- ✅ Valores persistem mesmo sem emulador

**Desvantagens:**
- ❌ Valores do app podem ficar diferentes do console real
- ❌ Precisa sincronizar quando conectar

---

### **Opção B: Salvar no Emulador (Scene)**

O X32/M32 tem sistema de **Scenes** (cenas) que salvam todos os valores.

**Comandos OSC:**
- `/scene/store` - Salva cena atual
- `/scene/recall` - Carrega cena salva

**Exemplo:**
```dart
// Salvar cena 1
await oscService.sendMessage('/-snap/01');

// Carregar cena 1
await oscService.sendMessage('/-snap/load/01');
```

**Nota:** Não tenho certeza se o emulador suporta isso. Você teria que testar!

---

### **Opção C: Arquivo de Configuração do Emulador**

O emulador carrega um arquivo de inicialização. Você pode:

1. **Encontrar o arquivo** (provavelmente `X32.ini` ou similar)
2. **Editar manualmente** com os valores que você quer
3. **Reiniciar o emulador** para carregar os valores

---

## 🎯 Recomendação

Para o seu caso, recomendo:

### **Implementar Solução 1 (Salvar Último Mix)**

Isso vai fazer com que:
- ✅ O app lembre qual IP você usou
- ✅ O app lembre qual Mix você estava usando
- ✅ Quando você abrir o app de novo, ele já conecta no mesmo IP
- ✅ Quando você abrir o mixer, ele já seleciona o mesmo Mix

**Quanto aos valores dos faders:**
- O emulador **mantém os valores enquanto está rodando**
- Se você **não fechar o emulador**, os valores ficam lá
- Se você **fechar o emulador**, ele reseta (isso é normal)

---

## 🔧 Console Real vs Emulador

### **Console Real (M32/X32):**
- ✅ Mantém valores mesmo quando você desconecta o app
- ✅ Tem memória interna que persiste
- ✅ Pode salvar/carregar cenas

### **Emulador:**
- ⚠️ Mantém valores **enquanto está rodando**
- ❌ Reseta quando você fecha o emulador
- ❓ Pode ou não suportar cenas (precisa testar)

---

## 💡 Dica

Para testar sem perder valores:

1. **Deixe o emulador rodando** (não feche)
2. **Feche e abra o app** quantas vezes quiser
3. Os valores vão estar lá no emulador

Se você fechar o emulador, aí sim ele reseta tudo.

---

## 🚀 Quer que eu implemente?

Quer que eu implemente a **Solução 1** (salvar último IP e Mix)?

É bem simples e vai melhorar muito a experiência! 😊

Só me confirme e eu faço as modificações! 🎯

