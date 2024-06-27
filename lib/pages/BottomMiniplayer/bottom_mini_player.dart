import 'dart:async';

import 'package:audio_app/pages/BottomMiniplayer/bottom_miniplayer_container.dart';
import 'package:audio_app/pages/player_screen.dart';
import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

class BottomMiniPlayer extends ConsumerStatefulWidget {
  const BottomMiniPlayer({super.key});

  @override
  _BottomMiniPlayerState createState() => _BottomMiniPlayerState();
}

class _BottomMiniPlayerState extends ConsumerState<BottomMiniPlayer> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  late StreamSubscription<int?> indexStream;
  List<SongModel>? songs;
  late SongModel song;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final playingFrom = ref.watch(playingFromProvider);
    if (playingFrom == 0) {
      songs = ref.watch(songListProvider);
    } else if (playingFrom == 1) {
      songs = ref.watch(recentSongListProvider);
    }

    final player = ref.read(playerProvider);
    int songIndex = player.currentIndex!;
    song = songs![songIndex];

    indexStream = player.currentIndexStream.listen((p) {
      if (p != null && p != songIndex) {
        setState(() {
          songIndex = p;
          song = songs![songIndex];
        });
      }
    });
  }

  @override
  void dispose() {
    indexStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final player = ref.watch(playerProvider);
    // final songs = ref.read(songListProvider);
    // int songIndex = player.currentIndex!;
    // SongModel selectedSong = songs![songIndex];

    // SongModel song = songs![songIndex];
    // player.currentIndexStream.listen((p) {
    //   if (p != songIndex) {
    //     setState(() {
    //       selectedSong = songs[songIndex];
    //     });
    //   }
    // });

    return GestureDetector(
      onTap: () {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Color.fromRGBO(24, 24, 26, 1),
          systemNavigationBarDividerColor: Color.fromRGBO(24, 24, 26, 1),
        ));
        Get.to(
          () => PlayerScreen(song),
          transition: Transition.downToUp,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
            color: Color.fromRGBO(42, 41, 49, 1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        child: const BottomMiniplayerContainer(),
      ),
    );
  }
}
