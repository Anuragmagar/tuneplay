class AudioPlayerManager {
  // final player = StateProvider<SongModel>((ref) {
  //   ref.read(playerProvider);
  // });

  // Stream<DurationState>? durationState;

  void init() {
    // durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
    //     player.positionStream,
    //     player.playbackEventStream,
    //     (position, playbackEvent) => DurationState(
    //           progress: position,
    //           buffered: playbackEvent.bufferedPosition,
    //           total: playbackEvent.duration,
    //         ));
    // player.setUrl(url);
  }

  void dispose() {
    // player.dispose();
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
    this.currentIndex,
  });
  final Duration progress;
  final Duration buffered;
  final Duration? total;
  final int? currentIndex;
}
