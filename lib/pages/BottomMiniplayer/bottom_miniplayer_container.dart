import 'dart:async';
import 'dart:typed_data';

import 'package:audio_app/pages/BottomMiniplayer/bottom_playerbutton_state.dart';
import 'package:audio_app/pages/BottomMiniplayer/bottom_linear_progress.dart';
import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BottomMiniplayerContainer extends ConsumerStatefulWidget {
  const BottomMiniplayerContainer({super.key});

  @override
  _BottomMiniplayerContainerState createState() =>
      _BottomMiniplayerContainerState();
}

class _BottomMiniplayerContainerState
    extends ConsumerState<BottomMiniplayerContainer> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  late StreamSubscription<int?> indexStream;
  late Future<Uint8List?> artworkFuture;
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

    artworkFuture = audioQuery.queryArtwork(song.id, ArtworkType.AUDIO);

    indexStream = player.currentIndexStream.listen((p) {
      if (p != null && p != songIndex) {
        setState(() {
          songIndex = p;
          song = songs![songIndex];
          artworkFuture = audioQuery.queryArtwork(song.id, ArtworkType.AUDIO);
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
    // final playingFrom = ref.watch(playingFromProvider);
    // late final songs;
    // if (playingFrom == 0) {
    //   songs = ref.watch(songListProvider);
    // } else if (playingFrom == 1) {
    //   songs = ref.watch(recentSongListProvider);
    // }
    // int songIndex = player.currentIndex!;
    // SongModel selectedSong = songs![songIndex];

    // // SongModel song = songs![songIndex];
    // player.currentIndexStream.listen((p) {
    //   if (p != songIndex) {
    //     setState(() {
    //       selectedSong = songs[songIndex];
    //     });
    //   }
    // });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                child: Hero(
                  tag: 'music-image',
                  child: FutureBuilder<Uint8List?>(
                    future: artworkFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data != null) {
                        return Image.memory(
                          snapshot.data!,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Container(
                          height: 50,
                          width: 50,
                          color: Colors.white60,
                          child: const Icon(
                            PhosphorIconsDuotone.musicNote,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                ),
                // QueryArtworkWidget(
                //   controller: audioQuery,
                //   id: selectedSong.id,
                //   type: ArtworkType.AUDIO,
                //   artworkBorder: BorderRadius.circular(10),
                //   nullArtworkWidget: Container(
                //     color: Colors.black,
                //     height: 50,
                //     width: 50,
                //     child: const Icon(PhosphorIconsDuotone.musicNote),
                //   ),
                // ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          song.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          song.artist.toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const BottomPlayerbuttonState(),
              // IconButton(
              //   icon: const Icon(Icons.close),
              //   onPressed: () {
              //     context.read(selectedVideoProvider).state =
              //         null;
              //   },
              // ),
            ],
          ),
        ),
        const BottomLinearProgress(),
      ],
    );
  }
}
