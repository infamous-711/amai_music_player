import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

class MusicControls extends StatelessWidget {
  const MusicControls({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
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
      onPressed: () => ref.read(repeatMusicProvider.notifier).toggle(),
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
      onPressed: () => ref.read(shuffleMusicProvider.notifier).toggle(),
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
    return IconButton(
      icon: Icon(ref.watch(playButtonIconProvider)),
      onPressed: () => ref.read(musicPlayerProvider.notifier).togglePlay(),
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
    final musicList = ref.watch(searchedMusicListProvider);
    final index = ref.watch(currentIndexProvider);
    return IconButton(
      icon: const Icon(Icons.skip_next),
      onPressed: () {
        if (index != null) {
          ref.read(musicPlayerProvider.notifier).playNext(musicList, index);
        }
      },
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
    final musicList = ref.watch(searchedMusicListProvider);
    final index = ref.watch(currentIndexProvider);
    return IconButton(
      icon: const Icon(Icons.skip_previous),
      onPressed: () {
        if (index != null) {
          ref.read(musicPlayerProvider.notifier).playPrevious(musicList, index);
        }
      },
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
    final volumeNotifier = ref.watch(volumeProvider.notifier);

    return Row(children: [
      IconButton(
        icon: Icon(ref.watch(volumeIconProvider)),
        onPressed: () => volumeNotifier.toggleMute(),
        tooltip: "Mute",
      ),
      Slider(
        value: volume,
        onChanged: (newVolume) => volumeNotifier.set(newVolume),
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
    final trackPlayer = ref.watch(trackPlayerProvider);
    final currentPosition = ref.watch(positionProvider);
    final audioDuration = ref.watch(trackDurationProvider);

    return Slider(
      min: 0.0,
      max: audioDuration.inMilliseconds.toDouble(),
      value: currentPosition.inMilliseconds.toDouble(),
      onChanged: (newPosition) {
        final position = Duration(milliseconds: newPosition.toInt());
        trackPlayer.seek(position);
        ref.read(positionProvider.notifier).set(position);
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
    final audioDuration = ref.watch(trackDurationProvider);

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
