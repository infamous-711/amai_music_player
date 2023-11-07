import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

void playMusic(AudioPlayer audioPlayer, List<String> musicList, int index) {
  final musicPath = musicList[index];
  audioPlayer.play(DeviceFileSource(musicPath));
}

int getRandomIndex(int length, int index) {
  int randomIndex = Random().nextInt(length);
  if (randomIndex == index) {
    randomIndex = getRandomIndex(length, index);
  }

  return randomIndex;
}
