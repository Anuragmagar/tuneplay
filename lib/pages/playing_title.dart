import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:text_scroll/text_scroll.dart';

class PlayingTitle extends ConsumerStatefulWidget {
  const PlayingTitle({super.key});

  @override
  _PlayingTitleState createState() => _PlayingTitleState();
}

class _PlayingTitleState extends ConsumerState<PlayingTitle> {
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
    player.currentIndexStream.listen((p) {
      if (p != songIndex) {
        setState(() {
          songIndex = p!;
          song = songs[songIndex];
        });
      }
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            PhosphorIconsBold.caretDown,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Flexible(
                  child: Text(
                    'ALBUM',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (song.album!.length < 35)
                  Flexible(
                    child: Text(
                      song.album.toString(),
                      style: const TextStyle(
                        fontFamily: 'CircularStd',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (song.album!.length >= 35)
                  SizedBox(
                    width: double.infinity,
                    height: 20,
                    child: TextScroll(
                      song.album.toString(),
                      mode: TextScrollMode.endless,
                      style: const TextStyle(
                        fontFamily: 'CircularStd',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                      velocity: const Velocity(pixelsPerSecond: Offset(50, 0)),
                      delayBefore: const Duration(milliseconds: 800),
                      pauseBetween: const Duration(milliseconds: 1000),
                      fadedBorder: true,
                      fadedBorderWidth: 0.1,
                    ),
                  )
              ],
            ),
          ),
        ),
        const Icon(PhosphorIconsBold.dotsThreeVertical)
      ],
    );
  }
}
