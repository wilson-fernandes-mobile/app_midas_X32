import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/console_info.dart';
import '../services/osc_service.dart';

/// ViewModel para gerenciar a conexão com o console
class ConnectionViewModel extends ChangeNotifier {
  final OSCService _oscService;
  ConsoleInfo _consoleInfo = ConsoleInfo(ipAddress: '');
  bool _isConnecting = false;
  String? _errorMessage;

  ConnectionViewModel(this._oscService) {
    // Carrega a conexão salva imediatamente
    _loadSavedConnection();
  }

  /// Retorna true se já carregou os dados salvos
  bool get hasLoadedSavedData => _consoleInfo.ipAddress.isNotEmpty;

  ConsoleInfo get consoleInfo => _consoleInfo;
  bool get isConnecting => _isConnecting;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _consoleInfo.isConnected;

  /// Carrega o último IP salvo
  Future<void> _loadSavedConnection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString('console_ip');
      final savedPort = prefs.getInt('console_port') ?? 10023;

      if (kDebugMode) {
        print('💾 Carregando conexão salva...');
        print('   IP salvo: $savedIp');
        print('   Porta salva: $savedPort');
      }

      if (savedIp != null && savedIp.isNotEmpty) {
        _consoleInfo = ConsoleInfo(
          ipAddress: savedIp,
          port: savedPort,
        );

        if (kDebugMode) {
          print('✅ Conexão carregada: $savedIp:$savedPort');
        }

        notifyListeners();
      } else {
        if (kDebugMode) {
          print('⚠️  Nenhuma conexão salva encontrada');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao carregar conexão salva: $e');
      }
    }
  }

  /// Salva o IP para próxima conexão
  Future<void> _saveConnection(String ip, int port) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('console_ip', ip);
      await prefs.setInt('console_port', port);

      if (kDebugMode) {
        print('💾 Conexão salva: $ip:$port');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar conexão: $e');
      }
    }
  }

  /// Conecta ao console
  Future<bool> connect(String ipAddress, {int port = 10023}) async {
    _isConnecting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _oscService.connect(ipAddress, port: port);
      
      if (success) {
        _consoleInfo = ConsoleInfo(
          ipAddress: ipAddress,
          port: port,
          isConnected: true,
        );
        await _saveConnection(ipAddress, port);
        _errorMessage = null;
      } else {
        _errorMessage = 'Não foi possível conectar ao console';
        _consoleInfo = _consoleInfo.copyWith(isConnected: false);
      }
    } catch (e) {
      _errorMessage = 'Erro ao conectar: $e';
      _consoleInfo = _consoleInfo.copyWith(isConnected: false);
    } finally {
      _isConnecting = false;
      notifyListeners();
    }

    return _consoleInfo.isConnected;
  }

  /// Desconecta do console
  Future<void> disconnect() async {
    await _oscService.disconnect();
    _consoleInfo = _consoleInfo.copyWith(isConnected: false);
    _errorMessage = null;
    notifyListeners();
  }

  /// Atualiza o IP no campo (sem conectar)
  void updateIpAddress(String ip) {
    _consoleInfo = _consoleInfo.copyWith(ipAddress: ip);
    notifyListeners();
  }

  @override
  void dispose() {
    _oscService.dispose();
    super.dispose();
  }
}

