import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';
import 'audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:amai_music_player/src/rust/api/metadata.dart';
import 'package:amai_music_player/src/rust/api/utils.dart';

part 'providers.g.dart'; // needed for build_runner & riverpod_generator

@riverpod
int? currentIndex(CurrentIndexRef ref) => ref.watch(currentTrackProvider)?.id;

@riverpod
AudioPlayer trackPlayer(TrackPlayerRef ref) {
  AudioPlayer audioPlayer = AudioPlayer();
  audioPlayer.setVolume(0.5);

  return audioPlayer;
}

@riverpod
class MusicPlayer extends _$MusicPlayer {
  @override
  void build() {
    return;
  }

  void repeatTrack() {
    ref.watch(trackPlayerProvider).resume();
  }

  void shuffleTrack(List<Track> musicList, int index) {
    final randomIndex = getRandomIndex(musicList.length, index);
    play(musicList, randomIndex);
  }

  void togglePlay() {
    final trackPlayer = ref.watch(trackPlayerProvider);
    final isPlaying = trackPlayer.state == PlayerState.playing;
    ref.watch(isPlayingProvider.notifier).set(isPlaying);
    isPlaying ? trackPlayer.pause() : trackPlayer.resume();
  }

  void play(List<Track> musicList, int index) {
    final trackPlayer = ref.watch(trackPlayerProvider);

    if (trackPlayer.state == PlayerState.playing ||
        trackPlayer.state == PlayerState.paused) {
      trackPlayer.stop();
    }

    // change the current track
    ref.watch(currentTrackProvider.notifier).set(musicList[index]);

    playMusic(trackPlayer, musicList, index);

    final trackPosition = ref.watch(positionProvider.notifier);
    trackPlayer.onPositionChanged.listen((Duration position) {
      trackPosition.set(position);
    });

    final trackDuration = ref.watch(trackDurationProvider.notifier);
    trackPlayer.onDurationChanged.listen((Duration duration) {
      trackDuration.set(duration);
    });

    trackPlayer.onPlayerComplete.listen((_) {
      if (ref.read(repeatMusicProvider)) {
        repeatTrack();
      } else if (ref.read(shuffleMusicProvider)) {
        shuffleTrack(musicList, index);
      }
    });
  }

  void playNext(List<Track> musicList, int index) {
    if ((musicList.length - 1) != index && index >= 0) {
      play(musicList, index + 1); // increment the index by 1
    }
  }

  void playPrevious(List<Track> musicList, int index) {
    if (index > 0) {
      play(musicList, index - 1); // decrement the index by 1
    }
  }
}

@riverpod
class Position extends _$Position {
  @override
  Duration build() => const Duration();

  void set(Duration duration) => state = duration;
}

@riverpod
class TrackDuration extends _$TrackDuration {
  @override
  Duration build() => const Duration();

  void set(Duration duration) => state = duration;
}

@riverpod
class CurrentTrack extends _$CurrentTrack {
  @override
  Track? build() => null;

  void set(Track? track) => state = track;
}

@riverpod
class Volume extends _$Volume {
  @override
  double build() => ref.watch(trackPlayerProvider).volume;

  void set(double volume) {
    final musicPlayer = ref.watch(trackPlayerProvider);
    musicPlayer.setVolume(volume);
    state = volume;
  }

  void toggleMute() {
    set(state > 0.0 ? 0.0 : 1.0);
  }
}

@riverpod
IconData volumeIcon(VolumeIconRef ref) {
  final volume = ref.watch(volumeProvider);
  if (volume >= 0.5) {
    return Icons.volume_up_rounded;
  } else if (volume < 0.5 && volume != 0.0) {
    return Icons.volume_down_rounded;
  } else {
    return Icons.volume_off_rounded;
  }
}

@riverpod
IconData playButtonIcon(PlayButtonIconRef ref) =>
    ref.watch(isPlayingProvider) ? Icons.pause_outlined : Icons.play_arrow;

@riverpod
class IsPlaying extends _$IsPlaying {
  @override
  bool build() => false;

  set(bool playing) => state = playing;
}

@riverpod
List<Track> searchedMusicList(SearchedMusicListRef ref) {
  final query = ref.watch(searchInputProvider);

  return ref.watch(musicListProvider).when(
        data: (value) => value
            .where((track) => track.name.toLowerCase().contains(query.toLowerCase()))
            .toList(),
        loading: () => [],
        error: (_, __) => [],
      );
}

@riverpod
Future<List<Track>> musicList(MusicListRef ref) async => await getMusicFiles();

@Riverpod(keepAlive: true)
class RepeatMusic extends _$RepeatMusic {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
IconData repeatIcon(RepeatIconRef ref) => ref.watch(repeatMusicProvider)
    ? Icons.repeat_one_on_outlined
    : Icons.repeat_one_rounded;

@Riverpod(keepAlive: true)
class ShuffleMusic extends _$ShuffleMusic {
  @override
  bool build() => false; // turned off by default

  toggle() => state = !state;
}

@riverpod
IconData shuffleIcon(ShuffleIconRef ref) => ref.watch(shuffleMusicProvider)
    ? Icons.shuffle_on_outlined
    : Icons.shuffle_rounded;

@riverpod
class SearchInput extends _$SearchInput {
  @override
  String build() => '';

  void search(String query) => state = query;
}

@riverpod
class CurrentTheme extends _$CurrentTheme {
  @override
  ThemeMode build() => ThemeMode.dark; // dark theme by default

  void toggle() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
  }
}

@riverpod
IconData themeModeIcon(ThemeModeIconRef ref) =>
    ref.watch(currentThemeProvider) == ThemeMode.dark
        ? Icons.dark_mode
        : Icons.light_mode;

@riverpod
Future<Metadata?> metadata(MetadataRef ref) async {
  Track? currentTrack = ref.watch(currentTrackProvider);
  if (currentTrack != null) {
    return await getMetadata(path: currentTrack.path);
  } else {
    return null;
  }
}
