import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../viewmodels/connection_viewmodel.dart';
import 'mixer_screen.dart';
import 'test_connection_screen.dart';

/// Tela de conexão com o console
class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '10023');
  bool _hasLoadedSavedConnection = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    // Aguarda o ViewModel carregar e então preenche os campos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToViewModel();
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  void _listenToViewModel() {
    final viewModel = context.read<ConnectionViewModel>();

    // Adiciona listener para quando o ViewModel mudar
    viewModel.addListener(_onViewModelChanged);

    // Tenta carregar imediatamente também
    _tryLoadSavedConnection();
  }

  void _onViewModelChanged() {
    _tryLoadSavedConnection();
  }

  void _tryLoadSavedConnection() {
    if (_hasLoadedSavedConnection) return;

    final viewModel = context.read<ConnectionViewModel>();

    print('🔍 ConnectionScreen: Verificando IP salvo...');
    print('   IP do ViewModel: "${viewModel.consoleInfo.ipAddress}"');
    print('   Porta do ViewModel: ${viewModel.consoleInfo.port}');

    if (viewModel.consoleInfo.ipAddress.isNotEmpty) {
      print('Preenchendo campos com IP salvo');
      setState(() {
        _ipController.text = viewModel.consoleInfo.ipAddress;
        _portController.text = viewModel.consoleInfo.port.toString();
        _hasLoadedSavedConnection = true;
      });

      // Mostra mensagem que carregou o último IP usado
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Última conexão carregada: ${viewModel.consoleInfo.ipAddress}'),
      //       duration: const Duration(seconds: 2),
      //       backgroundColor: Colors.blue[700],
      //     ),
      //   );
      // }

      // Remove o listener após carregar
      viewModel.removeListener(_onViewModelChanged);
    } else {
      print('⚠️  Nenhum IP salvo para preencher (ainda)');
    }
  }

  @override
  void dispose() {
    // Remove listener se ainda estiver registrado
    try {
      final viewModel = context.read<ConnectionViewModel>();
      viewModel.removeListener(_onViewModelChanged);
    } catch (e) {
      // Ignora se já foi removido
    }

    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    // Fecha o teclado
    FocusScope.of(context).unfocus();

    final viewModel = context.read<ConnectionViewModel>();
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text) ?? 10023;

    if (ip.isEmpty) {
      _showError('Digite o endereço IP do console');
      return;
    }

    final success = await viewModel.connect(ip, port: port);

    if (success && mounted) {
      // Navega para a tela do mixer
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MixerScreen()),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Conteúdo principal
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[900]!,
                  Colors.black,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  // Logo/Título
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback caso a imagem não seja encontrada
                      return const Icon(
                        Icons.graphic_eq,
                        size: 80,
                        color: Color(0xFFFF723A),
                      );
                    },
                  ),

                  Text(
                    'Personal Monitor Mixer',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Card de conexão
                  Card(
                    color: Colors.grey[850],
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Conectar ao Console',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[100],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Campo IP
                          TextField(
                            controller: _ipController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Endereço IP',
                              labelStyle: TextStyle(color: Colors.grey[400]),
                              hintText: '192.168.1.100',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: const Icon(Icons.router, color: Color(0xFFFF723A)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[700]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFFF723A), width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          // Campo Porta
                          TextField(
                            controller: _portController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Porta',
                              labelStyle: TextStyle(color: Colors.grey[400]),
                              hintText: '10023',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: const Icon(Icons.settings_ethernet, color: Color(0xFFFF723A)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[700]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFFF723A), width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _connect(),
                          ),
                          const SizedBox(height: 24),

                          // Botão conectar
                          Consumer<ConnectionViewModel>(
                            builder: (context, viewModel, _) {
                              if (viewModel.errorMessage != null) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _showError(viewModel.errorMessage!);
                                });
                              }

                              return ElevatedButton(
                                onPressed: viewModel.isConnecting ? null : _connect,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF723A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: viewModel.isConnecting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'CONECTAR',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão de teste (ESCONDIDO - descomente para debug)
                  // TextButton.icon(
                  //   onPressed: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (_) => const TestConnectionScreen(),
                  //       ),
                  //     );
                  //   },
                  //   icon: const Icon(Icons.bug_report, color: Color(0xFFFF723A)),
                  //   label: Text(
                  //     'Testar Conexão OSC',
                  //     style: TextStyle(color: Colors.grey[400]),
                  //   ),
                  // ),

                  // const SizedBox(height: 16),

                  // Info
                  Text(
                    'Compatível com Midas M32 e Behringer X32',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Versão do app no canto inferior direito

          // Positioned(
          //   bottom: 16,
          //   left: 16,
          //   child:
          //   Text(
          //     _appVersion,
          //     style: TextStyle(
          //       fontSize: 12,
          //       color: Colors.grey[600],
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),

          // TEXTO DIREITO
          Positioned(
            bottom: 16,
            right: 16,
            child: Image.asset(
              'assets/images/ic_animal_version.png',
              width: 30,
              height: 30,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

