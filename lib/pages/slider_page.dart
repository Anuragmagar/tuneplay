import 'package:audio_app/providers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_app/manager/audio_player_manager.dart';
import 'package:rxdart/rxdart.dart';

class SliderPage extends ConsumerStatefulWidget {
  const SliderPage({super.key});

  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends ConsumerState<SliderPage> {
  late AudioPlayerManager manager;

  @override
  void initState() {
    super.initState();

    manager = AudioPlayerManager();
    manager.init();
  }

  @override
  void dispose() {
    manager.dispose();
    durationState.drain();
    super.dispose();
  }

  Stream<DurationState> durationState =
      Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
    player.positionStream,
    player.playbackEventStream,
    (position, playbackEvent) => DurationState(
      progress: position,
      buffered: playbackEvent.bufferedPosition,
      total: playbackEvent.duration,
    ),
  ).asBroadcastStream();

  @override
  Widget build(BuildContext context) {
    final player = ref.read(playerProvider);

    return StreamBuilder<DurationState>(
      stream: durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return ProgressBar(
          progress: progress,
          buffered: buffered,
          total: total,
          onSeek: (value) {
            player.seek(value);
          },
          barHeight: 5,
          thumbRadius: 7,
          progressBarColor: Colors.white,
          thumbColor: Colors.white,
          bufferedBarColor: Colors.grey,
          baseBarColor: Colors.white24,
          thumbGlowRadius: 20,
        );
      },
    );
  }
}
