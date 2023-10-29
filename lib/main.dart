import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'package:rinf/rinf.dart';
import 'dart:ui';
import 'music_controls.dart';
import 'music_list.dart';
import 'metadata_column.dart';

const seedColor = Colors.cyan;

Future<void> main() async {
  // Wait for rust initialization to be completed first
  await Rinf.ensureInitialized();

  // run the flutter app
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> {
  final _appLifecycleListener = AppLifecycleListener(
    onExitRequested: () async {
      // Terminate Rust tasks before closing the Flutter app.
      await Rinf.ensureFinalized();
      return AppExitResponse.exit;
    },
  );

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MusicHome(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor, brightness: Brightness.dark),
      ),
      themeMode: ref.watch(themeModeProvider),
    );
  }
}

class MusicHome extends StatelessWidget {
  const MusicHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amai Music Player"),
        actions: const [AppBarActions()],
      ),
      body: const AppBody(),
    );
  }
}

class AppBarActions extends StatelessWidget {
  const AppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          SearchMusicBar(),
          ThemeModeIcon(),
        ],
      ),
    );
  }
}

class AppBody extends StatelessWidget {
  const AppBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: Row(
            children: [
              MusicList(),
              MetadataColumn(),
            ],
          ),
        ),
        MusicControls(),
      ],
    );
  }
}

class ThemeModeIcon extends ConsumerWidget {
  const ThemeModeIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(ref.watch(themeModeIconProvider)),
      onPressed: () => ref.read(themeModeProvider.notifier).update((theme) =>
          theme == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
      tooltip: "Toggle theme",
    );
  }
}

class SearchMusicBar extends ConsumerWidget {
  const SearchMusicBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchBar(
      hintText: "Search Music",
      onChanged: (value) =>
          ref.read(searchInputProvider.notifier).state = value,
      leading: const Icon(Icons.search),
    );
  }
}
