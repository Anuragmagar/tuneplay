import 'package:audio_app/providers.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/audiofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class SongInfo extends ConsumerStatefulWidget {
  const SongInfo({super.key});

  @override
  _SongInfoState createState() => _SongInfoState();
}

class _SongInfoState extends ConsumerState<SongInfo> {
  final tagger = Audiotagger();
  int? bitrate;
  String? encodingType;
  double? sampleRate;

  getSongInfo(String data) async {
    // final tagger = Audiotagger();

    final String filePath = data;
    final AudioFile? map = await tagger.readAudioFile(path: filePath);

    bitrate = map?.bitRate;
    encodingType = map?.encodingType.toString();
    sampleRate = map!.sampleRate!.toDouble() / 1000;
  }

  Stream<int?> ddurationState = Rx.combineLatest2<int?, PlaybackEvent, int>(
      player.currentIndexStream,
      player.playbackEventStream,
      (position, playbackEvent) => playbackEvent.currentIndex!);
  @override
  Widget build(BuildContext context) {
    final playingFrom = ref.watch(playingFromProvider);
    late final songs;
    if (playingFrom == 0) {
      songs = ref.watch(songListProvider);
    } else if (playingFrom == 1) {
      songs = ref.watch(recentSongListProvider);
    }
    return StreamBuilder<int?>(
      stream: ddurationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        getSongInfo(songs![durationState!].data);

        if (bitrate == null || encodingType == null || sampleRate == null) {
          return const Text(
            'M4A · 162 KBPS · 44.1 KHZ',
            style: TextStyle(color: Colors.white60),
          );
        }

        return Text(
          '${encodingType!.toUpperCase()} · $bitrate KBPS · $sampleRate KHZ',
          style: const TextStyle(color: Colors.white60),
        );
      },
    );
  }
}
