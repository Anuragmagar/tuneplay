import 'package:audio_app/providers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_app/manager/audio_player_manager.dart';
import 'package:rxdart/rxdart.dart';

class SliderPage extends ConsumerStatefulWidget {
  const SliderPage({super.key});

  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends ConsumerState<SliderPage> {
  // late Duration _position;
  // Duration _position = const Duration(minutes: 0);
  // Duration _bufferedPosition = const Duration(minutes: 0);

  late AudioPlayerManager manager;

  @override
  void initState() {
    super.initState();

    manager = AudioPlayerManager();
    manager.init();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    manager.dispose();
    durationState.drain();
    super.dispose();
  }

  // Stream<DurationState>? durationState;

// Stream<PositionData> get _positionDataStream =>
//       Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
//           _player.positionStream,
//           _player.bufferedPositionStream,
//           _player.durationStream,
//           (position, bufferedPosition, duration) => PositionData(
//               position, bufferedPosition, duration ?? Duration.zero));

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
    // final songs = ref.watch(songListProvider);

    // player.positionStream.listen((p) {
    //   setState(() {
    //     _position = p;
    //   });
    // });

    // player.bufferedPositionStream.listen((p) {
    //   setState(() {
    //     _bufferedPosition = p;
    //   });
    // });

    // return StreamBuilder<DurationState>(
    //   stream: _positionDataStream,
    //   builder: (context, snapshot) {
    //     final positionData = snapshot.data;
    //     return SizedBox.shrink();
    //     // return SeekBar(
    //     //   duration: positionData?.duration ?? Duration.zero,
    //     //   position: positionData?.position ?? Duration.zero,
    //     //   bufferedPosition:
    //     //       positionData?.bufferedPosition ?? Duration.zero,
    //     //   onChangeEnd: _player.seek,
    //     // );
    //   },
    // );

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
