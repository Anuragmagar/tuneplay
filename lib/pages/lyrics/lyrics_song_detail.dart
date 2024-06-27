import 'dart:async';
import 'dart:typed_data';

import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LyricsSongDetail extends ConsumerStatefulWidget {
  const LyricsSongDetail({super.key});

  @override
  _LyricsSongDetailState createState() => _LyricsSongDetailState();
}

String formatDuration(int? milliseconds) {
  if (milliseconds == null) {
    return 'Unknown duration';
  }

  Duration duration = Duration(milliseconds: milliseconds);
  String minutes = '${duration.inMinutes}'.padLeft(2);
  String seconds = '${duration.inSeconds % 60}'.padLeft(2, '0');
  return '$minutes:$seconds';
}

class _LyricsSongDetailState extends ConsumerState<LyricsSongDetail> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  late StreamSubscription<int?> indexStream;
  late Future<Uint8List?> artworkFuture;
  List<SongModel>? songs;
  late SongModel song;

  @override
  void initState() {
    super.initState();

    // final songs = ref.read(songListProvider);
    // final player = ref.read(playerProvider);
    // int songIndex = player.currentIndex!;
    // SongModel song = songs![songIndex];

    // indexStream = player.currentIndexStream.listen((p) {
    //   if (p != songIndex) {
    //     setState(() {
    //       songIndex = p!;
    //       song = songs[songIndex];
    //       // _generateGradientFromImage();
    //     });
    //   }
    // });
  }

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
    // final songs = ref.watch(songListProvider);
    // int songIndex = player.currentIndex!;
    // SongModel song = songs![songIndex];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            child: FutureBuilder<Uint8List?>(
              future: artworkFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!,
                    height: 90,
                    width: 90,
                    fit: BoxFit.cover,
                  );
                } else {
                  return Container(
                    height: 90,
                    width: 90,
                    color: Colors.white60,
                    child: const Icon(
                      PhosphorIconsDuotone.musicNote,
                      color: Colors.white,
                    ),
                  );
                }
              },
            ),
            // QueryArtworkWidget(
            //   controller: audioQuery,
            //   artworkHeight: 90,
            //   artworkWidth: 90,
            //   id: song.id,
            //   type: ArtworkType.AUDIO,
            //   artworkBorder: BorderRadius.circular(15),
            //   nullArtworkWidget: Container(
            //     color: Colors.black,
            //     height: 90,
            //     width: 90,
            //     child: const Icon(PhosphorIconsDuotone.musicNote),
            //   ),
            // ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      song.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.25,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      song.artist.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/clef.png',
                        height: 16,
                        // width: 24,
                        color: Colors.white54,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Text(
                          '${formatDuration(song.duration)} | mp3',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white54,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
