import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:popbash/features/shell/main_shell.dart';
import 'package:popbash/core/theme/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService().init();
  runApp(const PopBashApp());
}

class PopBashApp extends StatelessWidget {
  const PopBashApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos un tema oscuro estilo terminal (basado en colores Catppuccin)
    return ValueListenableBuilder<Color>(
      valueListenable: SettingsService().primaryColorNotifier,
      builder: (context, primaryColor, child) {
        return MaterialApp(
          title: 'PopBash',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1E1E2E), // Fondo oscuro profundo
            // Configuración de la tipografía base usando Google Fonts (Monoespaciada)
            textTheme: GoogleFonts.firaCodeTextTheme(
              Theme.of(context).textTheme.apply(
                bodyColor: primaryColor,
                displayColor: primaryColor,
              ),
            ),
            useMaterial3: true,
          ),
          home: const MainTerminalScreen(),
        );
      },
    );
  }
}

class MainTerminalScreen extends StatefulWidget {
  const MainTerminalScreen({super.key});

  @override
  State<MainTerminalScreen> createState() => _MainTerminalScreenState();
}

class _MainTerminalScreenState extends State<MainTerminalScreen> {
  @override
  void initState() {
    super.initState();
    // Simular un tiempo de carga de la terminal y luego ir a la shell principal
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('root@popbash:~# ./start_player.sh'),
              const SizedBox(height: 16),
              const Text('[INFO] Loading audio engine... OK'),
              const Text('[INFO] Scanning local files... OK'),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Arte ASCII simple del título
                      Text(
                        r'''
 ____            ____            _     
|  _ \ ___ _ __ | __ )  __ _ ___| |__  
| |_) / _ \ '_ \|  _ \ / _` / __| '_ \ 
|  __/  __/ |_) | |_) | (_| \__ \ | | |
|_|   \___| .__/|____/ \__,_|___/_| |_|
          |_|                          
''',
                        style: TextStyle(
                          color: const Color(0xFF89B4FA), // Azul brillante
                          fontSize: 10, // Tamaño ajustado para encajar en pantallas móviles
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Terminal Music Player v1.0',
                        style: TextStyle(color: Color(0xFFF38BA8)), // Rojo/Rosa
                      ),
                    ],
                  ),
                ),
              ),
              const Text('root@popbash:~# _', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
