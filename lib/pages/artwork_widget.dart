import 'dart:async';
import 'dart:typed_data';

import 'package:audio_app/pages/lyrics/lyrics_page.dart';
import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ArtworkWidget extends ConsumerStatefulWidget {
  const ArtworkWidget({super.key});

  @override
  _ArtworkWidgetState createState() => _ArtworkWidgetState();
}

class _ArtworkWidgetState extends ConsumerState<ArtworkWidget> {
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

    artworkFuture =
        audioQuery.queryArtwork(song.id, ArtworkType.AUDIO, size: 1000);

    indexStream = player.currentIndexStream.listen((p) {
      if (p != null && p != songIndex) {
        setState(() {
          songIndex = p;
          song = songs![songIndex];
          artworkFuture =
              audioQuery.queryArtwork(song.id, ArtworkType.AUDIO, size: 1000);
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
    return Stack(
      children: [
        Hero(
          tag: "music-image",
          child: FutureBuilder<Uint8List?>(
            future: artworkFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                return Image.memory(
                  snapshot.data!,
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              } else {
                return Container(
                  height: 350,
                  width: double.infinity,
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
        Positioned(
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return LyricsPage(song);
                    },
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(166, 170, 167, .75),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    PhosphorIconsBold.waveform,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
