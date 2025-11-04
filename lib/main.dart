import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/osc_service.dart';
import 'services/preset_service.dart';
import 'viewmodels/connection_viewmodel.dart';
import 'viewmodels/mixer_viewmodel.dart';
import 'viewmodels/preset_viewmodel.dart';
import 'views/connection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cria uma única instância do OSCService para compartilhar
    final oscService = OSCService();
    final presetService = PresetService();

    // Cria os ViewModels ANTES do MultiProvider para garantir inicialização
    final connectionViewModel = ConnectionViewModel(oscService);
    final mixerViewModel = MixerViewModel(oscService);
    final presetViewModel = PresetViewModel(presetService, mixerViewModel);

    return MultiProvider(
      providers: [
        // Provider do serviço OSC
        Provider<OSCService>.value(value: oscService),

        // Provider do serviço de Presets
        Provider<PresetService>.value(value: presetService),

        // ViewModel de conexão (usando .value para usar instância já criada)
        ChangeNotifierProvider<ConnectionViewModel>.value(
          value: connectionViewModel,
        ),

        // ViewModel do mixer (usando .value para usar instância já criada)
        ChangeNotifierProvider<MixerViewModel>.value(
          value: mixerViewModel,
        ),

        // ViewModel de presets (usando .value para usar instância já criada)
        ChangeNotifierProvider<PresetViewModel>.value(
          value: presetViewModel,
        ),
      ],
      child: MaterialApp(
        title: 'MixBot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFFF723A),
          scaffoldBackgroundColor: Colors.grey[900],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 4,
          ),
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFFFF723A),
            secondary: const Color(0xFFFF723A),
            surface: Colors.grey[850]!,
          ),
        ),
        home: const ConnectionScreen(),
      ),
    );
  }
}
