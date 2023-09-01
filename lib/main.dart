import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'audio.dart';

const seedColor = Colors.cyan;

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MusicHome(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor, brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.dark,
    );
  }
}

// Providers
class MusicHome extends ConsumerWidget {
  const MusicHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amai Music Player'),
      ),
      body: const Column(
        children: [
          Expanded(
            child: MusicList(),
          ),
          Column(
            children: [MusicName(), MusicControls()],
          ),
        ],
      ),
    );
  }
}

class MusicName extends ConsumerWidget {
  const MusicName({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicName = ref.watch(musicNameProvider);

    return Text(musicName, overflow: TextOverflow.fade);
  }
}

class MusicControls extends ConsumerWidget {
  const MusicControls({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Row(children: [
      PlayPrevious(),
      PlayButton(),
      PlayNext(),
      SizedBox(width: 10),
      MusicProgress(),
      Expanded(child: PositionSlider()),
      VolumeSlider(),
    ]);
  }
}

class PlayButton extends ConsumerWidget {
  const PlayButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerProvider);

    return IconButton(
      icon: Icon(ref.watch(playButtonIconProvider)),
      onPressed: () => ref.read(isPlayingProvider.notifier).update((isPlaying) {
        isPlaying ? audioPlayer.pause() : audioPlayer.resume();
        return !isPlaying;
      }),
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

    return IconButton(
      icon: const Icon(Icons.skip_next),
      onPressed: () => ref.read(indexProvider.notifier).update((state) {
        int index = state;
        if ((musicFiles.length - 1) != state && state > 0) {
          index += 1;
          playMusic(ref, musicFiles, index);
        }
        return index;
      }),
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

    return IconButton(
      icon: const Icon(Icons.skip_previous),
      onPressed: () => ref.read(indexProvider.notifier).update((state) {
        int index = state;
        if (index > 0) {
          index -= 1;
          playMusic(ref, musicFiles, index);
        }
        return index;
      }),
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
      Icon(ref.watch(volumeIconProvider)),
      Slider(
          value: volume,
          onChanged: (newVolume) =>
              ref.watch(volumeProvider.notifier).update((state) {
                ref.read(audioPlayerProvider).setVolume(newVolume);
                return newVolume;
              }),
          max: 1.0,
          min: 0.0),
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
        ref.read(positionProvider.notifier).update((_) => position);
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

    return Text(
        '${currentPosition.inMinutes}:${currentPosition.inSeconds - (currentPosition.inMinutes * 60)}'
        '/${audioDuration.inMinutes}:${audioDuration.inSeconds - (audioDuration.inMinutes * 60)}');
  }
}

class MusicList extends ConsumerWidget {
  const MusicList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicFiles = ref.watch(musicFilesProvider);
    final index = ref.watch(indexProvider);

    return ListView.builder(
      itemCount: musicFiles.length,
      itemBuilder: (context, trackIndex) {
        String titleName = musicFiles[trackIndex].split('/').last;
        return ListTile(
          title: Text(titleName),
          onTap: () {
            ref.watch(musicNameProvider.notifier).update((_) => titleName);
            playMusic(ref, musicFiles, trackIndex);
          },
          selected: trackIndex == index,
          selectedColor: Theme.of(context).colorScheme.onPrimary,
          selectedTileColor: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}
