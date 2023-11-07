import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'providers.dart';
import 'utils.dart';

class MusicList extends ConsumerWidget {
  const MusicList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueWidget<List<String>>(
      value: ref.watch(searchedMusicListProvider),
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
                selectedColor: Theme.of(context).colorScheme.onPrimary,
                selectedTileColor: Theme.of(context).colorScheme.primary,
                onTap: () => ref
                    .read(musicPlayerProvider.notifier)
                    .play(value, trackIndex),
                selected: trackIndex == ref.watch(currentIndexProvider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
