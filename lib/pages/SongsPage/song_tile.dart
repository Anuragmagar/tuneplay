import 'dart:typed_data';
import 'package:audio_app/pages/BottomModalSheet/modal_sheet_bottom.dart';
import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SongTile extends ConsumerStatefulWidget {
  final int index;
  // final ConcatenatingAudioSource playlist;
  final SongModel song;
  // final SongEntity song;
  const SongTile(
      {required this.index,
      // required this.playlist,
      required this.song,
      super.key});

  @override
  _SongTileState createState() => _SongTileState();
}

String formatDuration(int? milliseconds) {
  if (milliseconds == null) {
    return 'Unknown duration';
  }

  Duration duration = Duration(milliseconds: milliseconds);
  String minutes = '${duration.inMinutes}'.padLeft(2, '0');
  String seconds = '${duration.inSeconds % 60}'.padLeft(2, '0');
  return '$minutes:$seconds';
}

class _SongTileState extends ConsumerState<SongTile> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  late Future<Uint8List?> artworkFuture;
  ConcatenatingAudioSource? playlist;

  @override
  void initState() {
    super.initState();
    // final songs = ref.read(songListProvider);
    // if (songs != null && songs.isNotEmpty) {
    //   artworkFuture =
    //       audioQuery.queryArtwork(songs[widget.index].id, ArtworkType.AUDIO);
    //   _createPlaylist(songs);
    // }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    artworkFuture =
        audioQuery.queryArtwork(widget.song.id, ArtworkType.AUDIO, size: 500);
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(songListProvider);

    if (songs == null) {
      return const Center(child: Text('No songs available on your device'));
    }

    return ListTile(
      // onTap: () async {
      //   ref.read(isMiniplayerOpenProvider.notifier).update((state) => true);
      //   ref.read(playingFromProvider.notifier).update((state) => 0);

      //   player.setAudioSource(widget.playlist,
      //       initialIndex: widget.index, initialPosition: Duration.zero);
      //   player.play();
      // },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(
        widget.song.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${widget.song.artist}・${formatDuration(widget.song.duration)}',
        style: const TextStyle(color: Color.fromRGBO(218, 218, 218, 1)),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      leading: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
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
      trailing: IconButton(
        icon: const Icon(
          PhosphorIconsFill.dotsThreeOutlineVertical,
          color: Color.fromRGBO(218, 218, 218, 1),
        ),
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: const Color.fromRGBO(42, 41, 49, 1),
            context: context,
            builder: (BuildContext context) {
              // return CircularProgressIndicator();
              return ModalSheetBottom(
                // widget.song.id,
                // widget.song.title,
                // widget.song.artist ?? "Unknown Artist",
                widget.song,
                // widget.index,
              );
            },
          );
        },
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
      ),
    );
  }
}
