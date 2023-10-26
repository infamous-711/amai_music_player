import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'providers.dart';

void playMusic(WidgetRef ref, List<String> musicFiles, int index) {
  final audioPlayer = ref.watch(audioPlayerProvider);

  if (audioPlayer.state == PlayerState.playing ||
      audioPlayer.state == PlayerState.paused) {
    audioPlayer.stop();
    ref.watch(isPlayingProvider.notifier).update((_) => false);
  }

  ref.watch(indexProvider.notifier).state = index;

  final musicPath = musicFiles[index];
  audioPlayer.play(DeviceFileSource(musicPath));

  ref.watch(isPlayingProvider.notifier).state = true;

  ref.watch(currentTrackProvider.notifier).state = musicPath;

  audioPlayer.onDurationChanged.listen((Duration duration) {
    ref.watch(durationProvider.notifier).state = duration;
  });

  audioPlayer.onPositionChanged.listen((Duration position) {
    ref.watch(positionProvider.notifier).state = position;
  });

  audioPlayer.onPlayerComplete.listen((_) {
    if (ref.watch(repeatMusicProvider)) {
      playMusic(ref, musicFiles, index);
    } else if (ref.watch(shuffleMusicProvider)) {
      final randomIndex = getRandomIndex(musicFiles.length, index);
      playMusic(ref, musicFiles, randomIndex);
    }

    ref.watch(musicFinishedProvider.notifier).state = true;
  });
}

int getRandomIndex(int length, int index) {
  int randomIndex = Random().nextInt(length);
  if (randomIndex == index) {
    randomIndex = getRandomIndex(length, index);
  }

  return randomIndex;
}
