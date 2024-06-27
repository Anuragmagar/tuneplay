import 'dart:async';

import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:text_scroll/text_scroll.dart';

class SongTitlePage extends ConsumerStatefulWidget {
  const SongTitlePage({super.key});

  @override
  _SongTitlePageState createState() => _SongTitlePageState();
}

class _SongTitlePageState extends ConsumerState<SongTitlePage> {
  late StreamSubscription<int?> indexStream;

  @override
  void dispose() {
    indexStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.read(playerProvider);
    final playingFrom = ref.watch(playingFromProvider);
    late final songs;
    if (playingFrom == 0) {
      songs = ref.watch(songListProvider);
    } else if (playingFrom == 1) {
      songs = ref.watch(recentSongListProvider);
    }
    int songIndex = player.currentIndex!;
    SongModel song = songs![songIndex];
    indexStream = player.currentIndexStream.listen((p) {
      if (p != songIndex) {
        setState(() {
          songIndex = p!;
          song = songs[songIndex];
        });
      }
    });

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (song.title.length < 35)
                Flexible(
                  child: Text(
                    song.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'CircularStd',
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (song.title.length >= 35)
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: TextScroll(
                    song.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'CircularStd',
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                    velocity: const Velocity(pixelsPerSecond: Offset(50, 0)),
                    delayBefore: const Duration(milliseconds: 800),
                    pauseBetween: const Duration(milliseconds: 1000),
                    fadedBorder: true,
                    fadedBorderWidth: 0.05,
                  ),
                ),
              Flexible(
                child: Text(
                  song.artist.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'CircularStd',
                    // fontWeight: FontWeight.w900,
                    // letterSpacing: -1,
                    color: Color.fromRGBO(179, 179, 178, 1),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Icon(PhosphorIconsRegular.heart),
        )
      ],
    );
  }
}
