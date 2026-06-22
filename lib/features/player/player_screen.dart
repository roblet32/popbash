import 'package:flutter/material.dart';
import 'package:popbash/core/audio/audio_player_service.dart';
import 'package:popbash/core/theme/settings_service.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayerService _audioService = AudioPlayerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('user@popbash:~/player\$ ./play --visualize'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _audioService.currentSong == null
          ? const Center(child: Text('NO MEDIA PLAYING.\n\nGo to EXPLORE to select a track.', textAlign: TextAlign.center))
          : _buildPlayer(),
    );
  }

  Widget _buildPlayer() {
    final song = _audioService.currentSong!;
    final primaryColor = SettingsService().primaryColorNotifier.value;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Arte ASCII gigante en el medio (simulando visualizador)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: SettingsService().customAsciiNotifier,
                    builder: (context, ascii, _) {
                      final logo = ascii.isNotEmpty ? ascii : r'''
   _  _  ___  __  __   _   ___   _  _ 
  | || |/ _ \|  \/  | /_\ |   \ | || |
  | __ | (_) | |\/| |/ _ \| |) || __ |
  |_||_|\___/|_|  |_/_/ \_\___/ |_||_|
                    ''';
                      return Text(
                        logo,
                        style: TextStyle(color: primaryColor, fontSize: 12),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    song.title,
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    song.artist ?? 'Unknown Artist',
                    style: const TextStyle(color: Color(0xFFA6ADC8)),
                  ),
                ],
              ),
            ),
          ),
          
          // Información de archivo simulada
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF313244)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('> FILE: ${song.data.split('/').last}', style: const TextStyle(fontSize: 10, color: Color(0xFF6C7086))),
                Text('> CODEC: MP3/FLAC  BITRATE: ${song.size ~/ 1024} kb', style: const TextStyle(fontSize: 10, color: Color(0xFF6C7086))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stream del progreso (Barra ASCII)
          StreamBuilder<Duration>(
            stream: _audioService.player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = _audioService.player.duration ?? const Duration(milliseconds: 1);
              
              // Evitar división por cero
              double percent = position.inMilliseconds / duration.inMilliseconds;
              if (percent.isNaN || percent.isInfinite) percent = 0.0;
              if (percent > 1.0) percent = 1.0;

              // Barra de 30 caracteres
              int totalChars = 30;
              int filledChars = (totalChars * percent).floor();
              int emptyChars = totalChars - filledChars - 1;
              if (emptyChars < 0) emptyChars = 0;
              
              String bar = '[';
              bar += '=' * filledChars;
              if (filledChars < totalChars) bar += '>';
              bar += '-' * emptyChars;
              bar += ']';

              return Column(
                children: [
                  Text(bar, style: TextStyle(color: primaryColor, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(position), style: TextStyle(color: primaryColor)),
                      Text(_formatDuration(duration), style: const TextStyle(color: Color(0xFFF38BA8))),
                    ],
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Controles de reproducción estilo botones CLI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCliButton('[PREV]', () async {
                await _audioService.previous();
                setState(() {});
              }, primaryColor: primaryColor),
              StreamBuilder<bool>(
                stream: _audioService.player.playingStream,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data ?? false;
                  return _buildCliButton(isPlaying ? '[PAUSE]' : '[PLAY]', () {
                    _audioService.togglePlayPause();
                  }, highlight: true, primaryColor: primaryColor);
                },
              ),
              _buildCliButton('[NEXT]', () async {
                await _audioService.next();
                setState(() {});
              }, primaryColor: primaryColor),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCliButton(String text, VoidCallback onTap, {bool highlight = false, required Color primaryColor}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: highlight ? primaryColor : Colors.transparent,
          border: Border.all(color: primaryColor),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: highlight ? const Color(0xFF1E1E2E) : primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
}
