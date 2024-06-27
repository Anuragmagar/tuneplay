import 'dart:typed_data';
import 'package:audio_app/pages/BottomModalSheet/modal_sheet_bottom.dart';
import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SongTile extends ConsumerStatefulWidget {
  final int index;
  // final ConcatenatingAudioSource playlist;
  final SongModel song;
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
    final songs = ref.read(songListProvider);
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

  Future<String?> _getArtworkUri(SongModel song) async {
    final artwork = await audioQuery.queryArtwork(song.id, ArtworkType.AUDIO);

    if (artwork != null) {
      final directory = await getTemporaryDirectory();
      final artworkFile = File('${directory.path}/${song.id}.png');
      await artworkFile.writeAsBytes(artwork);
      return artworkFile.path;
    }
    return null;
  }

  Future<void> _createPlaylist(List<SongModel> songs) async {
    playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: await Future.wait(songs.map((song) async {
        final artworkUri = await _getArtworkUri(song);
        return AudioSource.uri(
          Uri.parse(song.uri!),
          tag: MediaItem(
            id: song.id.toString(),
            title: song.title,
            album: song.album,
            artist: song.artist,
            duration: Duration(microseconds: song.duration ?? 0),
            artUri: artworkUri != null ? Uri.file(artworkUri) : null,
            displayTitle: song.title,
            displaySubtitle: song.artist,
            displayDescription: song.album,
          ),
        );
      }).toList()),
    );
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
        songs[widget.index].title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${songs[widget.index].artist}・${formatDuration(songs[widget.index].duration)}',
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
              print(playlist);
              // return CircularProgressIndicator();
              return ModalSheetBottom(
                songs[widget.index].id,
                songs[widget.index].title,
                songs[widget.index].artist ?? "Unknown Artist",
                songs[widget.index],
                widget.index,
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
