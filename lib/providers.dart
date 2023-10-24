import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio.dart';

final indexProvider = StateProvider((_) => -1);
final positionProvider = StateProvider((_) => const Duration());
final durationProvider = StateProvider((_) => const Duration());
final musicNameProvider = StateProvider((_) => '');

final volumeProvider =
    StateProvider((ref) => ref.watch(audioPlayerProvider).volume);
final volumeIconProvider = Provider((ref) {
  final volume = ref.watch(volumeProvider);
  if (volume >= 0.5) {
    return Icons.volume_up_rounded;
  } else if (volume < 0.5 && volume != 0.0) {
    return Icons.volume_down_rounded;
  } else {
    return Icons.volume_off_rounded;
  }
});
final playButtonIconProvider = StateProvider((ref) =>
    ref.watch(isPlayingProvider) ? Icons.pause_outlined : Icons.play_arrow);
final isPlayingProvider = StateProvider(
    (ref) => ref.watch(audioPlayerProvider).state == PlayerState.playing);
final audioPlayerProvider = Provider((ref) {
  final audioPlayer = AudioPlayer();

  audioPlayer.setVolume(0.5); // initial volume of 0.5

  return audioPlayer;
});

final musicFilesProvider = StateProvider((ref) {
  final musicFiles = loadMusicFiles();
  final searchInput = ref.watch(searchInputProvider);

  if (searchInput.isEmpty) {
    return musicFiles;
  } else {
    return musicFiles
        .where((musicName) =>
            musicName.toLowerCase().contains(searchInput.toLowerCase()))
        .toList();
  }
});


final searchInputProvider = StateProvider((ref) => "");

final themeModeProvider = StateProvider((ref) => ThemeMode.dark);
final themeModeIconProvider = StateProvider((ref) =>
    ref.watch(themeModeProvider) == ThemeMode.dark
        ? Icons.dark_mode
        : Icons.light_mode);
