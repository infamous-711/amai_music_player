import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'providers.dart';
import 'audio.dart';

class MusicList extends ConsumerWidget {
  const MusicList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicFiles = ref.watch(musicFilesProvider);
    final index = ref.watch(indexProvider);

    return musicFiles.when(
      data: (value) => Expanded(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, trackIndex) {
              String titleName =
                  path.basenameWithoutExtension(value[trackIndex]);
              return ListTile(
                title: Text(titleName),
                onTap: () => playMusic(ref, value, trackIndex),
                selected: trackIndex == index,
                selectedColor: Theme.of(context).colorScheme.onPrimary,
                selectedTileColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              );
            },
          ),
        ),
      ),
      error: (error, _) => Text("Error $error"),
      loading: () => const CircularProgressIndicator.adaptive(),
    );
  }
}
