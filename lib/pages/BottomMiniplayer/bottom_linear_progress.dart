import 'package:audio_app/manager/audio_player_manager.dart';
import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class BottomLinearProgress extends ConsumerStatefulWidget {
  const BottomLinearProgress({super.key});

  @override
  _BottomLinearProgressState createState() => _BottomLinearProgressState();
}

class _BottomLinearProgressState extends ConsumerState<BottomLinearProgress> {
  Stream<DurationState> durationState =
      Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
    player.positionStream,
    player.playbackEventStream,
    (position, playbackEvent) => DurationState(
      progress: position,
      buffered: playbackEvent.bufferedPosition,
      total: playbackEvent.duration,
      currentIndex: playbackEvent.currentIndex,
    ),
  ).asBroadcastStream();

  @override
  void dispose() {
    durationState.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final player = ref.read(playerProvider);

    return StreamBuilder<DurationState>(
      stream: durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;

        final percentage = progress.inMilliseconds / total.inMilliseconds;
        // print(currentIndex);

        return LinearProgressIndicator(
          minHeight: 2,
          value: percentage.isNaN || percentage.isInfinite ? 0 : percentage,
        );
      },
    );
  }
}
