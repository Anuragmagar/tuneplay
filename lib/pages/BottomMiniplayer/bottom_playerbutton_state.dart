import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BottomPlayerbuttonState extends ConsumerStatefulWidget {
  const BottomPlayerbuttonState({super.key});

  @override
  _BottomPlayerbuttonStateState createState() =>
      _BottomPlayerbuttonStateState();
}

class _BottomPlayerbuttonStateState
    extends ConsumerState<BottomPlayerbuttonState> {
  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);

    return IconButton(
      // icon: const Icon(Icons.play_arrow),
      icon: Icon(
          player.playing ? PhosphorIconsFill.pause : PhosphorIconsFill.play),
      onPressed: () {
        if (player.playing) {
          setState(() {
            player.pause();
          });
        } else {
          setState(() {
            player.play();
          });
        }
      },
    );
  }
}
