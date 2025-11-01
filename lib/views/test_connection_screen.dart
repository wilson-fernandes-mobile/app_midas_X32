import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/connection_viewmodel.dart';
import '../services/osc_service.dart';

/// Tela de teste de conexão OSC
/// Permite testar comandos individuais e ver respostas
class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({Key? key}) : super(key: key);

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '10023');
  
  @override
  void initState() {
    super.initState();
    _loadSavedIP();
    _startListening();
  }

  void _loadSavedIP() {
    final viewModel = context.read<ConnectionViewModel>();
    if (viewModel.consoleInfo.ipAddress.isNotEmpty) {
      _ipController.text = viewModel.consoleInfo.ipAddress;
      _portController.text = viewModel.consoleInfo.port.toString();
    }
  }

  void _startListening() {
    final oscService = context.read<OSCService>();
    oscService.messageStream.listen((message) {
      setState(() {
        _logs.add('✅ RECEBIDO: ${message.address}');
        if (message.arguments.isNotEmpty) {
          _logs.add('   Args: ${message.arguments}');
        }
      });
      _scrollToBottom();
    });
  }

  Future<void> _connect() async {
    // Fecha o teclado
    FocusScope.of(context).unfocus();

    final viewModel = context.read<ConnectionViewModel>();
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text) ?? 10023;

    if (ip.isEmpty) {
      _addLog('❌ ERRO: Digite o endereço IP do console');
      return;
    }

    _addLog('📡 Conectando a $ip:$port...');

    final success = await viewModel.connect(ip, port: port);

    if (success) {
      _addLog('✅ CONECTADO com sucesso!');
      _addLog('💡 Use os botões abaixo para testar comandos OSC\n');
    } else {
      _addLog('❌ ERRO: Falha ao conectar');
      if (viewModel.errorMessage != null) {
        _addLog('   ${viewModel.errorMessage}');
      }
    }
  }

  Future<void> _disconnect() async {
    final viewModel = context.read<ConnectionViewModel>();
    await viewModel.disconnect();
    _addLog('🔌 Desconectado');
  }
  
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
    _scrollToBottom();
  }
  
  Future<void> _testInfo() async {
    final oscService = context.read<OSCService>();
    _addLog('📤 ENVIANDO: /info');
    await oscService.sendMessage('/info');
  }
  
  Future<void> _testXRemote() async {
    final oscService = context.read<OSCService>();
    _addLog('📤 ENVIANDO: /xremote');
    await oscService.sendMessage('/xremote');
  }
  
  Future<void> _testChannelName(int channel) async {
    final oscService = context.read<OSCService>();
    final address = '/ch/${channel.toString().padLeft(2, '0')}/config/name';
    _addLog('📤 ENVIANDO: $address');
    await oscService.sendMessage(address);
  }
  
  Future<void> _testSetChannelLevel(int channel, int mix, double level) async {
    final oscService = context.read<OSCService>();
    _addLog('📤 ENVIANDO: Definir Canal $channel Mix $mix = $level');
    await oscService.setChannelLevel(channel, mix, level);
    
    // Solicita o valor de volta para confirmar
    await Future.delayed(const Duration(milliseconds: 100));
    final address = '/ch/${channel.toString().padLeft(2, '0')}/mix/${mix.toString().padLeft(2, '0')}/level';
    _addLog('📤 ENVIANDO: $address (solicitar confirmação)');
    await oscService.sendMessage(address);
  }
  
  Future<void> _testBusFader(int bus, double level) async {
    final oscService = context.read<OSCService>();
    _addLog('📤 ENVIANDO: Definir Bus $bus fader = $level');
    await oscService.setBusLevel(bus, level);
    
    // Solicita o valor de volta
    await Future.delayed(const Duration(milliseconds: 100));
    final address = '/bus/${bus.toString().padLeft(2, '0')}/mix/fader';
    _addLog('📤 ENVIANDO: $address (solicitar confirmação)');
    await oscService.sendMessage(address);
  }
  
  Future<void> _runFullTest() async {
    _addLog('\n🧪 === INICIANDO TESTE COMPLETO ===\n');
    
    await _testInfo();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testXRemote();
    await Future.delayed(const Duration(milliseconds: 500));
    
    _addLog('\n--- Testando Nomes de Canais ---');
    for (int ch = 1; ch <= 3; ch++) {
      await _testChannelName(ch);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    _addLog('\n--- Testando Níveis de Canais ---');
    await _testSetChannelLevel(1, 1, 0.25);
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testSetChannelLevel(2, 1, 0.50);
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testSetChannelLevel(3, 1, 0.75);
    await Future.delayed(const Duration(milliseconds: 500));
    
    _addLog('\n--- Testando Bus Fader ---');
    await _testBusFader(1, 0.60);
    await Future.delayed(const Duration(milliseconds: 500));
    
    _addLog('\n✅ === TESTE COMPLETO FINALIZADO ===\n');
  }
  
  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final connectionVM = context.watch<ConnectionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de Conexão OSC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearLogs,
            tooltip: 'Limpar logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status da conexão
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: connectionVM.isConnected ? Colors.green : Colors.red,
            child: Text(
              connectionVM.isConnected
                ? '✅ Conectado'
                : '❌ Desconectado',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Campos de conexão (se não conectado)
          if (!connectionVM.isConnected)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[900],
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _ipController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'IP',
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: '192.168.9.138',
                            hintStyle: const TextStyle(color: Colors.white38),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _portController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Porta',
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _connect(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: connectionVM.isConnecting ? null : _connect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: connectionVM.isConnecting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('CONECTAR'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dica: Use 10.0.2.2 para emulador Android ou ${_ipController.text.isEmpty ? "IP do PC" : _ipController.text} para celular',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),

          // Botão de desconectar (se conectado)
          if (connectionVM.isConnected)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[900],
              child: ElevatedButton.icon(
                onPressed: _disconnect,
                icon: const Icon(Icons.power_off),
                label: const Text('DESCONECTAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          
          // Botões de teste
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: connectionVM.isConnected ? _runFullTest : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Teste Completo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: connectionVM.isConnected ? _testInfo : null,
                  child: const Text('/info'),
                ),
                ElevatedButton(
                  onPressed: connectionVM.isConnected ? _testXRemote : null,
                  child: const Text('/xremote'),
                ),
                ElevatedButton(
                  onPressed: connectionVM.isConnected 
                    ? () => _testChannelName(1) 
                    : null,
                  child: const Text('Nome Ch1'),
                ),
                ElevatedButton(
                  onPressed: connectionVM.isConnected 
                    ? () => _testSetChannelLevel(1, 1, 0.75) 
                    : null,
                  child: const Text('Ch1 → 75%'),
                ),
                ElevatedButton(
                  onPressed: connectionVM.isConnected 
                    ? () => _testBusFader(1, 0.5) 
                    : null,
                  child: const Text('Bus1 → 50%'),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Área de logs
          Expanded(
            child: Container(
              color: Colors.black87,
              child: _logs.isEmpty
                ? const Center(
                    child: Text(
                      'Aguardando comandos...\n\nClique nos botões acima para testar',
                      style: TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      Color textColor = Colors.white;
                      
                      if (log.startsWith('✅')) {
                        textColor = Colors.greenAccent;
                      } else if (log.startsWith('📤')) {
                        textColor = Colors.blueAccent;
                      } else if (log.startsWith('⚠️') || log.startsWith('❌')) {
                        textColor = Colors.redAccent;
                      } else if (log.startsWith('---')) {
                        textColor = Colors.yellowAccent;
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          log,
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}

