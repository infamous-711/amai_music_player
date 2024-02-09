import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:amai_music_player/src/rust/api/utils.dart';

void playMusic(AudioPlayer audioPlayer, List<Track> musicList, int index) {
  final musicPath = musicList[index].path;
  audioPlayer.play(DeviceFileSource(musicPath));
}

int getRandomIndex(int length, int index) {
  int randomIndex = Random().nextInt(length);
  if (randomIndex == index) {
    randomIndex = getRandomIndex(length, index);
  }

  return randomIndex;
}
