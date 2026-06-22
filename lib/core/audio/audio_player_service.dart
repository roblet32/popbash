import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer player = AudioPlayer();
  
  SongModel? currentSong;
  List<SongModel> currentPlaylist = [];
  int currentIndex = 0;

  Future<void> playSong(SongModel song, List<SongModel> playlist, int index) async {
    currentSong = song;
    currentPlaylist = playlist;
    currentIndex = index;
    
    try {
      // JustAudio soporta leer desde el path absoluto en local
      await player.setAudioSource(AudioSource.uri(Uri.parse('file://${song.data}')));
      player.play();
    } catch (e) {
      debugPrint("[ERROR] Could not play audio: $e");
    }
  }

  Future<void> togglePlayPause() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> next() async {
    if (currentIndex < currentPlaylist.length - 1) {
      playSong(currentPlaylist[currentIndex + 1], currentPlaylist, currentIndex + 1);
    }
  }

  Future<void> previous() async {
    if (currentIndex > 0) {
      playSong(currentPlaylist[currentIndex - 1], currentPlaylist, currentIndex - 1);
    }
  }
}
