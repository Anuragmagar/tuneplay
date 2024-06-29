import 'dart:math';

import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Sorting extends ConsumerWidget {
  const Sorting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int songsCount = ref.watch(songsCountProvider);
    final playlist = ref.watch(songsPlaylist);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          child: Row(
            children: [
              const Text(
                'Name',
              ),
              const SizedBox(width: 10),
              Icon(
                PhosphorIcons.arrowUp(),
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
        SizedBox(
          child: Row(
            children: [
              (playlist == null)
                  ? CircularProgressIndicator()
                  : GestureDetector(
                      onTap: () async {
                        Random random = Random();
                        int randomNumber = random
                            .nextInt(songsCount); // from 0 upto 99 included

                        ref
                            .read(isMiniplayerOpenProvider.notifier)
                            .update((state) => true);
                        ref
                            .read(playingFromProvider.notifier)
                            .update((state) => 0);

                        await player.setAudioSource(playlist,
                            initialIndex: randomNumber,
                            initialPosition: Duration.zero);
                        await player.setShuffleModeEnabled(
                            true); // Shuffle playlist order (true|false)

                        await player.play();
                      },
                      child: Icon(
                        PhosphorIcons.shuffle(),
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
              const SizedBox(width: 10),
              Text('$songsCount Songs'),
            ],
          ),
        ),
      ],
    );
  }
}
