import 'dart:async';
import 'dart:ui';

import 'package:audio_app/pages/artwork_widget.dart';
import 'package:audio_app/pages/playing_title.dart';
import 'package:audio_app/pages/slider_page.dart';
import 'package:audio_app/pages/song_info.dart';
import 'package:audio_app/pages/song_title_page.dart';
import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final SongModel song;
  const PlayerScreen(this.song, {super.key});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  final OnAudioQuery audioQuery = OnAudioQuery();
  late StreamSubscription<int?> indexStream;

  late String lyric;

  List<Color> colors = [
    const Color(0xFF101115),
    Colors.black,
  ];
  // List<double> stops = [1, 0.6];
  List<double> stops = [0.6, 1];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _generateGradientFromImage();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromRGBO(42, 41, 49, 1),
      systemNavigationBarDividerColor: Color.fromRGBO(42, 41, 49, 1),
    ));

    final songs = ref.read(songListProvider);
    int songIndex = player.currentIndex!;
    SongModel song = songs![songIndex];
    indexStream = player.currentIndexStream.listen((p) {
      if (p != songIndex) {
        setState(() {
          songIndex = p!;
          song = songs[songIndex];
          // _generateGradientFromImage();
        });
      }
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    indexStream.cancel();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromRGBO(42, 41, 49, 1),
      systemNavigationBarDividerColor: Color.fromRGBO(42, 41, 49, 1),
    ));

    _controller.dispose();

    super.dispose();
  }

  _generateGradientFromImage() async {
    final player = ref.watch(playerProvider);
    final songs = ref.read(songListProvider);
    int songIndex = player.currentIndex!;
    SongModel selectedSong = songs![songIndex];

    final imageBytes = await getArtworkBytes(selectedSong.id);

    if (imageBytes == null) {
      return null;
    }

    final image = await decodeImageFromList(imageBytes);

    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImage(image);

    setState(() {
      colors = [
        // paletteGenerator.mutedColor?.color ?? Colors.white,
        // const Color.fromRGBO(24, 24, 26, 1),
        const Color(0xFF101115),

        paletteGenerator.vibrantColor?.color ?? const Color(0xFF101115),
      ];
    });
  }

  Future<Uint8List?> getArtworkBytes(int audioId) async {
    final player = ref.watch(playerProvider);
    final songs = ref.read(songListProvider);
    int songIndex = player.currentIndex!;
    SongModel selectedSong = songs![songIndex];

    return await audioQuery.queryArtwork(
      selectedSong.id,
      ArtworkType.AUDIO,
    );
  }

  @override
  void didUpdateWidget(covariant PlayerScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _generateGradientFromImage();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.read(playerProvider);
    // final songs = ref.watch(songListProvider);
    final String loopMode = ref.watch(loopModeProvider);
    final bool isShuffle = ref.watch(isShuffleModeProvider);
    // int songIndex = player.currentIndex!;
    // SongModel song = songs![songIndex];

    _generateGradientFromImage();

    return Scaffold(
      // backgroundColor: const Color.fromRGBO(24, 24, 26, 1),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            stops: stops,
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10),
          child: Container(
            width: double.infinity,
            color: Colors.black.withOpacity(0.3),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // mainAxisSize: MainAxisSize.max,
                  children: [
                    const PlayingTitle(),
                    const SizedBox(height: 50),
                    const ArtworkWidget(),
                    const SizedBox(height: 50),
                    const SongTitlePage(),
                    const SizedBox(height: 25),
                    const SliderPage(),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (loopMode == 'off') {
                              await player.setLoopMode(LoopMode.all);
                              ref
                                  .read(loopModeProvider.notifier)
                                  .update((ref) => 'all');
                            }
                            if (loopMode == 'all') {
                              await player.setLoopMode(LoopMode.one);
                              ref
                                  .read(loopModeProvider.notifier)
                                  .update((ref) => 'one');
                            }
                            if (loopMode == 'one') {
                              await player.setLoopMode(LoopMode.off);
                              ref
                                  .read(loopModeProvider.notifier)
                                  .update((ref) => 'off');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              (loopMode == 'off')
                                  ? PhosphorIconsRegular.repeat
                                  : (loopMode == 'all')
                                      ? PhosphorIconsRegular.repeat
                                      : PhosphorIconsRegular.repeatOnce,
                              size: 25,
                              color: loopMode == 'off'
                                  ? Colors.white54
                                  : Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              player.seekToPrevious();
                            });
                          },
                          icon: const Icon(
                            PhosphorIconsFill.skipBack,
                            color: Colors.white,
                          ),
                          iconSize: 25,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (player.playing) {
                              setState(() {
                                player.pause();
                                // _controller.forward();
                              });
                            } else {
                              setState(() {
                                player.play();
                                // _controller.reverse();
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Icon(
                                player.playing
                                    ? PhosphorIconsFill.pause
                                    : PhosphorIconsFill.play,
                                size: 25,
                                color: const Color.fromRGBO(52, 35, 35, 1),
                              ),
                              // child: AnimatedIcon(
                              //   icon: AnimatedIcons.pause_play,
                              //   size: 35,
                              //   progress: _controller,
                              //   color: const Color.fromRGBO(52, 35, 35, 1),
                              // ),
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
                            color: Colors.white,
                          ),
                          iconSize: 25,
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (isShuffle) {
                              await player.setShuffleModeEnabled(false);
                              ref
                                  .read(isShuffleModeProvider.notifier)
                                  .update((state) => false);
                            } else {
                              await player.setShuffleModeEnabled(true);
                              ref
                                  .read(isShuffleModeProvider.notifier)
                                  .update((state) => true);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              PhosphorIconsRegular.shuffle,
                              size: 25,
                              color: isShuffle ? Colors.white : Colors.white54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const SongInfo(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
