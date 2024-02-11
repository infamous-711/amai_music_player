import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

class MusicList extends ConsumerWidget {
  const MusicList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: ref.watch(searchedMusicListProvider).length,
          itemBuilder: (_, tileIndex) => MusicTile(tileIndex: tileIndex),
        ),
      ),
    );
  }
}

class MusicTile extends ConsumerWidget {
  final int tileIndex;
  
  const MusicTile({
    super.key,   
    required this.tileIndex,
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

    return ListTile(
      title: Text(musicList[tileIndex].name),
      onTap: () => ref
          .read(musicPlayerProvider.notifier)
          .play(musicList, tileIndex),
      selected: musicList[tileIndex].id == ref.watch(currentIndexProvider),
      selectedColor: selectedColor,
      selectedTileColor: selectedTileColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }
}
