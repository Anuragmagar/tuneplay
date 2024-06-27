import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Sorting extends ConsumerWidget {
  const Sorting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int songsCount = ref.watch(songsCountProvider);
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
              Icon(
                PhosphorIcons.shuffle(),
                size: 18,
                color: Colors.white,
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
