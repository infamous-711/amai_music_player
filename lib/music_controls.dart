import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'audio.dart';

class MusicControls extends StatelessWidget {
  const MusicControls({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Row(children: [
        PlayPrevious(),
        PlayButton(),
        PlayNext(),
        SizedBox(width: 10),
        MusicProgress(),
        Expanded(child: PositionSlider()),
        RepeatButton(),
        ShuffleButton(),
        VolumeSlider(),
      ]),
    );
  }
}

class RepeatButton extends ConsumerWidget {
  const RepeatButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(ref.watch(repeatIconProvider)),
      onPressed: () =>
          ref.read(repeatMusicProvider.notifier).update((repeat) => !repeat),
      tooltip: "Repeat",
    );
  }
}

class ShuffleButton extends ConsumerWidget {
  const ShuffleButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(ref.watch(shuffleIconProvider)),
      onPressed: () =>
          ref.read(shuffleMusicProvider.notifier).update((shuffle) => !shuffle),
      tooltip: "Shuffle",
    );
  }
}

class PlayButton extends ConsumerWidget {
  const PlayButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerProvider);
    final isPlaying = ref.watch(isPlayingProvider.notifier);

    bool togglePlay(bool isPlaying) {
      isPlaying ? audioPlayer.pause() : audioPlayer.resume();
      return !isPlaying;
    }

    return IconButton(
      icon: Icon(ref.watch(playButtonIconProvider)),
      onPressed: () => isPlaying.update(togglePlay),
      color: Theme.of(context).colorScheme.onPrimary,
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).colorScheme.primary)),
      tooltip: "Play",
    );
  }
}

class PlayNext extends ConsumerWidget {
  const PlayNext({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicFiles = ref.watch(musicFilesProvider);
    final currentIndex = ref.watch(indexProvider);

    return IconButton(
      icon: const Icon(Icons.skip_next),
      onPressed: () => musicFiles.whenData((value) {
        if ((value.length - 1) != currentIndex && currentIndex >= 0) {
          playMusic(ref, value, currentIndex + 1);
        }
      }),
      tooltip: "Play Next",
    );
  }
}

class PlayPrevious extends ConsumerWidget {
  const PlayPrevious({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicFiles = ref.watch(musicFilesProvider);
    final currentIndex = ref.watch(indexProvider);

    return IconButton(
      icon: const Icon(Icons.skip_previous),
      onPressed: () => musicFiles.whenData((value) {
        if (currentIndex > 0) {
          playMusic(ref, value, currentIndex - 1);
        }
      }),
      tooltip: "Play Previous",
    );
  }
}

class VolumeSlider extends ConsumerWidget {
  const VolumeSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(volumeProvider);

    return Row(children: [
      IconButton(
        icon: Icon(ref.watch(volumeIconProvider)),
        onPressed: () => ref.watch(volumeProvider.notifier).update((state) {
          // if it is mute, restore the volume to its full capacity
          // mute the volume if it is not already
          var newVolume = state > 0.0 ? 0.0 : 1.0;

          ref.read(audioPlayerProvider).setVolume(newVolume);
          return newVolume;
        }),
        tooltip: "Mute",
      ),
      Slider(
        value: volume,
        onChanged: (newVolume) =>
            ref.watch(volumeProvider.notifier).update((state) {
          ref.read(audioPlayerProvider).setVolume(newVolume);
          return newVolume;
        }),
        max: 1.0,
        min: 0.0,
        divisions: 20,
        label: "${(volume * 100).round()}",
      ),
    ]);
  }
}

class PositionSlider extends ConsumerWidget {
  const PositionSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerProvider);
    final currentPosition = ref.watch(positionProvider);
    final audioDuration = ref.watch(durationProvider);

    return Slider(
      min: 0.0,
      max: audioDuration.inMilliseconds.toDouble(),
      value: currentPosition.inMilliseconds.toDouble(),
      onChanged: (newPosition) {
        final position = Duration(milliseconds: newPosition.toInt());
        audioPlayer.seek(position);
        ref.read(positionProvider.notifier).state = position;
      },
    );
  }
}

class MusicProgress extends ConsumerWidget {
  const MusicProgress({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = ref.watch(positionProvider);
    final audioDuration = ref.watch(durationProvider);

    String progress;
    String totalDuration;

    // the below trick is taken from: https://flutterigniter.com/how-to-format-duration/
    if (audioDuration.inHours >= 1) {
      // for the duration as HH:mm::ss (if the length of the audio is larger than or equal to an hour)
      progress = currentPosition.toString().split('.').first.padLeft(8, "0");
      totalDuration = audioDuration.toString().split('.').first.padLeft(8, "0");
    } else {
      // format the duration as mm:ss
      progress = currentPosition.toString().substring(2, 7);
      totalDuration = audioDuration.toString().substring(2, 7);
    }

    return Text('$progress/$totalDuration');
  }
}
