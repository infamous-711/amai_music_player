import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinf/rinf.dart';
import 'package:amai_music_player/messages/get_music_files.pb.dart'
    as get_music_files;
import 'package:amai_music_player/messages/get_metadata.pb.dart'
    as get_metadata;
import 'dart:typed_data';

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

final musicFilesProvider = FutureProvider<List<String>>((ref) async {
  const rustRequest = RustRequest(
    resource: get_music_files.ID,
    operation: RustOperation.Create,
  );

  final rustResponse = await requestToRust(rustRequest);
  final responseMessage = get_music_files.CreateResponse.fromBuffer(
    rustResponse.message!,
  );

  final searchInput = ref.watch(searchInputProvider);

  return responseMessage.musicFiles
      .where((name) => name.toLowerCase().contains(searchInput.toLowerCase()))
      .toList();
});

final repeatMusicProvider = StateProvider((ref) => false);
final repeatIconProvider = StateProvider((ref) => ref.watch(repeatMusicProvider)
    ? Icons.repeat_one_on_outlined
    : Icons.repeat_one_rounded);

final shuffleMusicProvider = StateProvider((ref) => false);
final shuffleIconProvider = StateProvider((ref) =>
    ref.watch(shuffleMusicProvider)
        ? Icons.shuffle_on_outlined
        : Icons.shuffle_rounded);

final musicFinishedProvider = StateProvider((ref) => false);

final searchInputProvider = StateProvider((ref) => "");

final themeModeProvider = StateProvider((ref) => ThemeMode.dark);
final themeModeIconProvider = StateProvider((ref) =>
    ref.watch(themeModeProvider) == ThemeMode.dark
        ? Icons.dark_mode
        : Icons.light_mode);

class Metadata {
  Uint8List art;
  String title;

  Metadata({
    required this.art,
    required this.title,
  });
}

final metadataProvider = FutureProvider<Metadata>((ref) async {
  final currentTrack = ref.watch(currentTrackProvider);

  final rustRequestMessage = get_metadata.ReadRequest(
    path: currentTrack,
  );

  final rustRequest = RustRequest(
    resource: get_metadata.ID,
    operation: RustOperation.Read,
    message: rustRequestMessage.writeToBuffer(),
  );

  final rustResponse = await requestToRust(rustRequest);
  final responseMessage = get_metadata.ReadResponse.fromBuffer(
    rustResponse.blob!,
  );

  return Metadata(
    art: Uint8List.fromList(responseMessage.art),
    title: responseMessage.title,
  );
});
