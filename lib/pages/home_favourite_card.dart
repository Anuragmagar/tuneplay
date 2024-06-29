import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeFavouriteCard extends StatefulWidget {
  const HomeFavouriteCard(this.song, {super.key});
  final FavoritesEntity song;

  @override
  State<HomeFavouriteCard> createState() => _HomeFavouriteCardState();
}

class _HomeFavouriteCardState extends State<HomeFavouriteCard> {
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
    return Container(
      width: 180,
      margin: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              } else {
                return Container(
                  height: 190,
                  width: double.infinity,
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

          //texts
          const SizedBox(
            height: 10,
          ),
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
          Text(
            widget.song.artist ?? "Unknown Artist",
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
    );
  }
}
