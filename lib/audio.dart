import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'providers.dart';

void playMusic(WidgetRef ref, List<String> musicFiles, int index) {
  final audioPlayer = ref.watch(audioPlayerProvider);

  if (audioPlayer.state == PlayerState.playing ||
      audioPlayer.state == PlayerState.paused) {
    audioPlayer.stop();
    ref.watch(isPlayingProvider.notifier).update((_) => false);
  }

  ref.watch(indexProvider.notifier).update((_) => index);

  String musicPath = musicFiles[index];
  audioPlayer.play(DeviceFileSource(musicPath));

  ref.watch(isPlayingProvider.notifier).update((_) => true);
  ref
      .watch(musicNameProvider.notifier)
      .update((_) => path.basenameWithoutExtension(musicFiles[index]));

  audioPlayer.onDurationChanged.listen((Duration duration) {
    ref.watch(durationProvider.notifier).state = duration;
  });

  audioPlayer.onPositionChanged.listen((Duration position) {
    ref.watch(positionProvider.notifier).state = position;
  });
}

String getMusicDirectory() {
  if (Platform.isLinux) {
    String homeDir = path.join('/home', Platform.environment['USER']);
    String musicDir = path.join(homeDir, 'Music');
    return musicDir;
  } else {
    // TODO: Handle other platforms (Windows, macOS)
    return '';
  }
}

List<String> loadMusicFiles() {
  String musicDir = getMusicDirectory(); // Get the external storage directory
  String musicDir = getMusicDirectory(); // Get the music directory

  return Directory(musicDir)
      .listSync()
      .where((file) => file.path.endsWith('.mp3') || file.path.endsWith('.ogg'))
      .map((file) => file.path)
      .toList();
}
