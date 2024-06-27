// import 'package:amlv/amlv.dart';
import 'dart:async';

import 'package:audio_app/manager/audio_player_manager.dart';
import 'package:audio_app/pages/lyrics/lyrics_reader_lines.dart';
import 'package:audio_app/pages/lyrics/lyrics_song_detail.dart';
import 'package:audio_app/providers.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:mmoo_lyric/lyric.dart';
// import 'package:mmoo_lyric/lyric_controller.dart';
// import 'package:mmoo_lyric/lyric_util.dart';
// import 'package:mmoo_lyric/lyric_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:rxdart/rxdart.dart';

class LyricsPage extends ConsumerStatefulWidget {
  final SongModel song;
  const LyricsPage(this.song, {super.key});

  @override
  _LyricsPageState createState() => _LyricsPageState();
}

class _LyricsPageState extends ConsumerState<LyricsPage>
    with TickerProviderStateMixin {
  // LyricController? controller;

  // LrcLyricParser parser = LrcLyricParser();
  // Lyric? lyric;

  // List<Lyric>? lyric = [];
  String? lyric;
  double? position = 0;
  // Duration? position = const Duration(seconds: 0);
  // late StreamSubscription<Duration> durationState;
  final tagger = Audiotagger();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // durationState.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(68, 18, 11, 1),
            Color.fromRGBO(36, 5, 10, 1),
          ],
          // stops: stops,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).viewPadding.top + 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: LyricsSongDetail(),
          ),
          const Expanded(child: LyricsReaderLines()),
        ],
      ),
    ));
  }
}
