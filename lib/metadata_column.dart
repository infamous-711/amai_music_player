import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'package:path/path.dart' as path;

class MetadataColumn extends StatelessWidget {
  const MetadataColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child:
          const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TrackArt(),
        SizedBox(height: 50.0),
        MusicName(),
      ]),
    );
  }
}

class TrackArt extends ConsumerWidget {
  const TrackArt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = ref.watch(metadataProvider);

    return metadata.when(
      data: (value) => ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 300,
          maxHeight: 300,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Image.memory(value.art),
        ),
      ),
      error: (error, _) => Text("Error: $error"),
      loading: () => const CircularProgressIndicator(),
    );
  }
}

class MusicName extends ConsumerWidget {
  const MusicName({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = ref.watch(metadataProvider);
    final name = metadata.when(
      data: (value) => value.title,
      error: (_, __) =>
          path.basenameWithoutExtension(ref.watch(currentTrackProvider)),
      loading: () => "",
    );

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        name,
        overflow: TextOverflow.fade,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18.0,
        ),
        maxLines: 5,
        textAlign: TextAlign.center,
      ),
    );
  }
}
