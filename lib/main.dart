import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'package:rinf/rinf.dart';
import 'dart:ui';
import 'music_controls.dart';
import 'music_list.dart';
import 'metadata_column.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'utils.dart';

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
      themeMode: ref.watch(currentThemeProvider),
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

class AppBody extends ConsumerWidget {
  const AppBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Uint8List blankBytes = Base64Codec().decode("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7");
    final metadata = ref.watch(metadataProvider);
    final art = metadata.when(
      data: (value) => MemoryImage(value.art),
      loading: () => MemoryImage(blankBytes),
      error: (_, __) => MemoryImage(blankBytes), 
    );

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: art,  
          opacity: 0.2,
          fit: BoxFit.cover,
        ), 
      ),
      child: 
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.8, sigmaY: 4.8),
        child: Container(
          child: Column(
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
          ),
        ),
      ),
    );
  }
}

class ThemeModeIcon extends ConsumerWidget {
  const ThemeModeIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(ref.watch(themeModeIconProvider)),
      onPressed: () => ref.read(currentThemeProvider.notifier).toggle(),
      tooltip: "Toggle theme",
    );
  }
}

class SearchMusicBar extends ConsumerWidget {
  const SearchMusicBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debouncer = Debouncer(milliseconds: 250);
    return SearchBar(
      hintText: "Search Music",
      onChanged: (value) =>
          debouncer.run(() => ref.read(searchInputProvider.notifier).search(value)),
      leading: const Icon(Icons.search),
    );
  }
}
