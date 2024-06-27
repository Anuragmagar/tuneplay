import 'dart:async';
import 'dart:typed_data';

import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomePageCard extends ConsumerStatefulWidget {
  const HomePageCard(this.playlist, this.tapIndex, this.song, {super.key});
  final ConcatenatingAudioSource playlist;
  final int tapIndex;
  final SongModel song;

  @override
  ConsumerState<HomePageCard> createState() => _HomePageCardState();
}

class _HomePageCardState extends ConsumerState<HomePageCard> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  late Future<Uint8List?> artworkFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    artworkFuture =
        audioQuery.queryArtwork(widget.song.id, ArtworkType.AUDIO, size: 500);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ref
        //     .read(recentSongListProvider.notifier)
        //     .update((state) => song);
        ref.read(playingFromProvider.notifier).update((state) => 1);
        // ref.read(songListProvider.notifier).update((state) => song);
        ref.read(isMiniplayerOpenProvider.notifier).update((state) => true);
        player.setAudioSource(widget.playlist,
            initialIndex: widget.tapIndex, initialPosition: Duration.zero);
        player.play();
      },
      child: Container(
        margin: const EdgeInsets.only(left: 20),

        // height: 40,
        width: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: Colors.brown,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<Uint8List?>(
              future: artworkFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      snapshot.data!,
                      height: 160,
                      width: 160,
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  return Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      PhosphorIconsDuotone.musicNote,
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                }
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0, 0.8],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 15,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  widget.song.title,
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  widget.song.artist.toString() == '<unknown>'
                                      ? 'Unknown Artist'
                                      : widget.song.artist.toString(),
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    height: 1,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 35.0, right: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: const Color.fromRGBO(192, 192, 192, 0.5),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  PhosphorIconsFill.play,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
