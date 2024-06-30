// import 'package:amlv/amlv.dart';
import 'package:audio_app/pages/lyrics/lyrics_reader_lines.dart';
import 'package:audio_app/pages/lyrics/lyrics_song_detail.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

class LyricsPage extends ConsumerStatefulWidget {
  final SongModel song;
  const LyricsPage(this.song, {super.key});

  @override
  _LyricsPageState createState() => _LyricsPageState();
}

class _LyricsPageState extends ConsumerState<LyricsPage>
    with TickerProviderStateMixin {
  String? lyric;
  double? position = 0;
  final tagger = Audiotagger();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
