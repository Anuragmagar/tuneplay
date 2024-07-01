import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeLastPlayed extends StatefulWidget {
  const HomeLastPlayed(this.song, {super.key});
  final LastPlayedEntity song;

  @override
  State<HomeLastPlayed> createState() => _HomeLastPlayedState();
}

class _HomeLastPlayedState extends State<HomeLastPlayed> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  late Future<Uint8List?> artworkFuture;

  @override
  void initState() {
    artworkFuture =
        audioQuery.queryArtwork(widget.song.id, ArtworkType.AUDIO, size: 500);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        // left: 20,
        // right: 20,
        bottom: 20,
      ),
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
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              } else {
                return Container(
                  height: 160,
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
            maxLines: 1,
            style: const TextStyle(
              height: 1,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      // Container(
      //   // width: 180,
      //   margin: const EdgeInsets.symmetric(horizontal: 20),
      //   child: Stack(
      //     children: [
      //       FutureBuilder<Uint8List?>(
      //         future: artworkFuture,
      //         builder: (context, snapshot) {
      //           if (snapshot.connectionState == ConnectionState.done &&
      //               snapshot.data != null) {
      //             return ClipRRect(
      //               borderRadius: BorderRadius.circular(10),
      //               child: Image.memory(
      //                 snapshot.data!,
      //                 height: 180,
      //                 width: double.infinity,
      //                 fit: BoxFit.cover,
      //               ),
      //             );
      //           } else {
      //             return Container(
      //               height: 180,
      //               width: double.infinity,
      //               decoration: BoxDecoration(
      //                 color: Colors.white60,
      //                 borderRadius: BorderRadius.circular(10),
      //               ),
      //               child: const Icon(
      //                 PhosphorIconsDuotone.musicNote,
      //                 color: Colors.white,
      //                 size: 40,
      //               ),
      //             );
      //           }
      //         },
      //       ),
      //       Container(
      //         decoration: BoxDecoration(
      //           gradient: const LinearGradient(
      //             colors: [
      //               Colors.black,
      //               Colors.transparent,
      //             ],
      //             stops: [0, 0.8],
      //             begin: Alignment.bottomCenter,
      //             end: Alignment.topCenter,
      //           ),
      //           borderRadius: BorderRadius.circular(10),
      //         ),
      //         height: 180,
      //         child: Padding(
      //           padding: const EdgeInsets.all(8.0),
      //           child: Row(
      //             crossAxisAlignment: CrossAxisAlignment.end,
      //             children: [
      //               Expanded(
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   mainAxisAlignment: MainAxisAlignment.end,
      //                   mainAxisSize: MainAxisSize.min,
      //                   children: [
      //                     Text(
      //                       widget.song.title,
      //                       textAlign: TextAlign.left,
      //                       maxLines: 1,
      //                       style: const TextStyle(
      //                         color: Colors.white,
      //                         fontSize: 15,
      //                         fontWeight: FontWeight.w900,
      //                         height: 1,
      //                       ),
      //                       overflow: TextOverflow.ellipsis,
      //                     ),
      //                     Text(
      //                       widget.song.artist ?? "Unknown Artist",
      //                       textAlign: TextAlign.left,
      //                       maxLines: 1,
      //                       style: const TextStyle(
      //                         height: 1,
      //                         color: Colors.white,
      //                       ),
      //                       overflow: TextOverflow.ellipsis,
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}
