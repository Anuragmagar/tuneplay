import 'package:audio_app/manager/audio_player_manager.dart';
import 'package:audio_app/providers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';
import 'package:flutter_lyric/lyric_ui/ui_netease.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:rxdart/rxdart.dart';

class LyricsReaderLines extends ConsumerStatefulWidget {
  const LyricsReaderLines({super.key});

  @override
  _LyricsReaderLinesState createState() => _LyricsReaderLinesState();
}

class _LyricsReaderLinesState extends ConsumerState<LyricsReaderLines> {
  String? lyric;
  double? position = 0;
  final tagger = Audiotagger();

  var lyricUI = UINetease(
    highlight: false,
    defaultSize: 30,
    otherMainSize: 25,
    lyricAlign: LyricAlign.CENTER,
  );

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

  getLyrics(String data) async {
    // final tagger = Audiotagger();

    final String filePath = data;
    // final AudioFile? audioFile = await tagger.readAudioFile(path: filePath);
    final Map? map = await tagger.readTagsAsMap(path: filePath);
    // final lyricParsed =
    //     await parser.parse(map!['lyrics'], UrlSource(widget.song.data));
    if (map == null) {
      // return null;
      lyric = null;
    } else if (map['lyrics'] == null) {
      lyric = null;
    }
    // lyric = await parser.parse(map!['lyrics'], UrlSource(data));
    // lyric = LyricUtil.formatLyric(map!['lyrics']);

    lyric = map!['lyrics'];
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(songListProvider);

    return StreamBuilder<DurationState>(
        stream: durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final currentIndex = durationState?.currentIndex;
          // print(currentIndex);
          if (currentIndex != null) {
            getLyrics(songs![currentIndex].data);
          }

          if (lyric == null) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Column(
                children: [
                  const Center(
                    child: Text("No lyrics"),
                  ),
                  const Spacer(),
                  ProgressBar(
                    progress: progress,
                    // buffered: buffered,
                    total: durationState?.total ?? Duration.zero,
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
                  ),
                ],
              ),
            );
          }

          var lyricModel =
              LyricsModelBuilder.create().bindLyricToMain(lyric!).getModel();
          return Column(
            children: [
              Expanded(
                child: LyricsReader(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  model: lyricModel,
                  position: progress.inMilliseconds.toInt(),
                  lyricUi: lyricUI,
                  playing: false,
                  // size: Size(
                  //     // double.infinity, MediaQuery.of(context).size.height - 40),
                  //     double.infinity,
                  //     100),
                  emptyBuilder: () => const Center(
                    child: Text(
                      "No lyrics",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                player.seekToPrevious();
                              });
                            },
                            icon: const Icon(
                              PhosphorIconsFill.skipBack,
                            ),
                            iconSize: 25,
                          ),
                          GestureDetector(
                            onTap: () {
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
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Icon(
                                  player.playing
                                      ? PhosphorIconsFill.pause
                                      : PhosphorIconsFill.play,
                                  size: 25,
                                  color: const Color.fromRGBO(52, 35, 35, 1),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                setState(() {
                                  player.seekToNext();
                                });
                              });
                            },
                            icon: const Icon(
                              PhosphorIconsFill.skipForward,
                            ),
                            iconSize: 25,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ProgressBar(
                      progress: progress,
                      // buffered: buffered,
                      total: durationState?.total ?? Duration.zero,
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
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
