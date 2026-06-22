import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:popbash/core/audio/audio_player_service.dart';

class LibraryScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  const LibraryScreen({super.key, this.onNavigate});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  bool _hasPermission = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Pedir permisos basados en la versión de Android
    var perm = await Permission.audio.status;
    if (perm.isDenied) {
      perm = await Permission.audio.request();
    }
    
    // Si falla el de audio (Android 12 o menor), pedir el de storage
    if (perm.isDenied) {
      perm = await Permission.storage.request();
    }

    if (perm.isGranted) {
      setState(() {
        _hasPermission = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('[!] PERMISSION DENIED', style: TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              const Text('Please grant storage access to read music files.'),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF89B4FA),
                  foregroundColor: const Color(0xFF1E1E2E),
                ),
                onPressed: _checkPermissions,
                child: const Text('RETRY / SUDO CHMOD'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('user@popbash:~/Music\$ ls -l'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Ocultar botón de atrás
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item) {
          if (item.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Scanning sectors... [====>   ]'));
          }

          if (item.data == null || item.data!.isEmpty) {
            return const Center(child: Text('total 0\nNo audio files found.', textAlign: TextAlign.center));
          }

          final songs = item.data!;
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              // Simular salida de 'ls -l' (Permisos, Usuario, Tamaño/Bitrate, Nombre)
              final sizeMb = ((song.size ?? 0) / (1024 * 1024)).toStringAsFixed(1);
              final timeStr = _formatDuration(song.duration);

              return InkWell(
                onTap: () async {
                  // Iniciar la canción y navegar al reproductor (Fase 3)
                  await AudioPlayerService().playSong(song, songs, index);
                  if (widget.onNavigate != null) {
                    widget.onNavigate!(2); // 2 es el índice de PLAYER
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('-rwxr-xr-x', style: TextStyle(color: Color(0xFF6C7086))),
                      const SizedBox(width: 8),
                      const Text('1 root', style: TextStyle(color: Color(0xFF89B4FA))),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 50,
                        child: Text('${sizeMb}M', style: TextStyle(color: const Color(0xFFF38BA8))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('> ${song.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('  ${song.artist ?? "Unknown"} • $timeStr', style: const TextStyle(fontSize: 12, color: Color(0xFFA6ADC8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDuration(int? ms) {
    if (ms == null) return "00:00";
    Duration duration = Duration(milliseconds: ms);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
}
