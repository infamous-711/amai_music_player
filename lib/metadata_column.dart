import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

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
    return ref.watch(metadataProvider).when(
          data: (value) {
            if (value != null && value.art != null) {
              return ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 300,
                    maxHeight: 300,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: Image.memory(value.art!),
                  ));
            } else {
              return Container();
            }
          },
          error: (err, __) {
            print(err);

            return Container();
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }
}

class MusicName extends ConsumerWidget {
  const MusicName({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String pathName = ref.watch(currentTrackProvider)?.name ?? "";

    String name = ref.watch(metadataProvider).when(
          data: (value) => value?.title ?? pathName,
          error: (_, __) => pathName,
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
