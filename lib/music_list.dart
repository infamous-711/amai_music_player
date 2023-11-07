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
    final musicList = ref.watch(searchedMusicListProvider);
    final themeMode = ref.watch(currentThemeProvider);
    final selectedColor =
        themeMode == ThemeMode.dark ? Colors.white : Colors.black;
    final selectedTileColor = themeMode == ThemeMode.dark
        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
        : Theme.of(context).colorScheme.primary.withOpacity(0.6);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: musicList.length,
          itemBuilder: (context, trackIndex) {
            String titleName =
                path.basenameWithoutExtension(musicList[trackIndex]);

            return ListTile(
              title: Text(titleName),
              onTap: () => ref
                  .read(musicPlayerProvider.notifier)
                  .play(musicList, trackIndex),
              selected: trackIndex == ref.watch(currentIndexProvider),
              selectedColor: selectedColor,
              selectedTileColor: selectedTileColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            );
          },
        ),
      ),
    );
  }
}
