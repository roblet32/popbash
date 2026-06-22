import 'package:flutter/material.dart';
import 'package:popbash/features/library/library_screen.dart';
import 'package:popbash/features/player/player_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Empezamos en la pestaña 1 (Explorar) para ver las canciones de inmediato
  int _currentIndex = 1; 

  // Lista de las 4 pantallas (Home, Explorar, Reproductor, Ajustes)
  late final List<Widget> _screens = [
    _buildPlaceholderScreen('~/home', 'Welcome to PopBash\nSelect a track from EXPLORE'),
    LibraryScreen(
      onNavigate: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    ),
    const PlayerScreen(),
    _buildPlaceholderScreen('~/config', 'User configuration file\nTheme: hacker_dark\nAutoplay: true'),
  ];

  static Widget _buildPlaceholderScreen(String path, String content) {
    return Scaffold(
      appBar: AppBar(
        title: Text('user@popbash:$path\$ cat README.txt'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          content,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF89B4FA)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF313244), width: 1.5), // Borde superior estilo terminal
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF181825), // Fondo un poco más oscuro
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFFA6E3A1), // Verde terminal activo
            unselectedItemColor: const Color(0xFF6C7086), // Gris inactivo
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.terminal_outlined),
                activeIcon: Icon(Icons.terminal),
                label: 'HOME',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined),
                activeIcon: Icon(Icons.list_alt),
                label: 'EXPLORE',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_arrow_outlined),
                activeIcon: Icon(Icons.play_arrow),
                label: 'PLAYER',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'CONFIG',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
