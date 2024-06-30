import 'dart:typed_data';
import 'dart:io';
import 'package:audio_app/providers.dart';
import 'package:byte_converter/byte_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ModalSheetBottom extends ConsumerStatefulWidget {
  const ModalSheetBottom(this.song, {super.key});
  final SongModel song;

  @override
  ConsumerState<ModalSheetBottom> createState() => _ModalSheetBottomState();
}

class _ModalSheetBottomState extends ConsumerState<ModalSheetBottom> {
  late OnAudioQuery audioQuery;
  late Future<Uint8List?> artworkFuture;
  final OnAudioRoom _audioRoom = OnAudioRoom();
  bool isFavourite = false;

  List choices = const [
    {
      'title': 'Size',
      'description': 'Sizes',
    },
    {
      'title': 'Format',
      'description': 'Sizes',
    },
    {
      'title': 'Bitrate',
      'description': 'Sizes',
    },
    {
      'title': 'Sampling rate',
      'description': 'Sizes',
    },
  ];

  isFav(SongModel song) async {
    bool fav = await _audioRoom.checkIn(
      RoomType.FAVORITES,
      song.id,
    );
    setState(() {
      isFavourite = fav;
    });
  }

  @override
  void initState() {
    audioQuery = OnAudioQuery();
    artworkFuture = audioQuery.queryArtwork(widget.song.id, ArtworkType.AUDIO);
    isFav(widget.song);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.read(songListProvider);
    return Column(
      children: [
        ListTile(
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
            widget.song.artist ?? "Unknown Artist",
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
          trailing: GestureDetector(
            onTap: () {},
            child: Icon(
              isFavourite
                  ? PhosphorIconsFill.heart
                  : PhosphorIconsRegular.heart,
              color: const Color.fromRGBO(218, 218, 218, 1),
            ),
          ),
        ),
        const Divider(
          color: Colors.white24,
        ),
        const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            "Play next",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: Icon(
            PhosphorIconsFill.arrowUUpRight,
            color: Colors.white,
            size: 20,
          ),
        ),
        const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            "Go to album",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: Icon(
            PhosphorIconsFill.vinylRecord,
            color: Colors.white,
            size: 20,
          ),
        ),
        const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            "Go to artist",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: Icon(
            PhosphorIconsRegular.user,
            color: Colors.white,
            size: 20,
          ),
        ),
        ListTile(
          onTap: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  Duration duration =
                      Duration(milliseconds: widget.song.duration!);
                  String minutes = '${duration.inMinutes}'.padLeft(2, '0');
                  String seconds = '${duration.inSeconds % 60}'.padLeft(2, '0');

                  return AlertDialog(
                    backgroundColor: const Color.fromARGB(255, 37, 37, 37),
                    title: const Text('Details'),
                    titleTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'File path',
                            style: TextStyle(color: Colors.white60),
                          ),
                          Text(widget.song.data),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            'File Name',
                            style: TextStyle(color: Colors.white60),
                          ),
                          Text(widget.song.displayName),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            'File Size',
                            style: TextStyle(color: Colors.white60),
                          ),
                          Text(
                              '${ByteConverter(double.parse(widget.song.size.toString())).megaBytes.toStringAsFixed(2)} MB'),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            'File Duration',
                            style: TextStyle(color: Colors.white60),
                          ),
                          Text('$minutes:$seconds$minutes:$seconds'),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                });
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: const Text(
            "Details",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const Icon(
            PhosphorIconsFill.info,
            color: Colors.white,
            size: 20,
          ),
        ),
        ListTile(
          onTap: () async {
            final result = await Share.shareXFiles(
                [XFile(File(widget.song.data).path)],
                text: 'Great picture');
            if (result.status == ShareResultStatus.success) {}
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: const Text(
            "Share",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const Icon(
            PhosphorIconsFill.shareNetwork,
            color: Colors.white,
            size: 20,
          ),
        ),
        ListTile(
          onTap: () async {
            File file = File(widget.song.data);
            file.delete();
            // MediaScanner.loadMedia(path: widget.song.data);
            songs!.removeWhere((item) => item.id == widget.song.id);
            ref.read(songListProvider.notifier).update((state) => songs);

            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                action: SnackBarAction(
                  label: 'Close',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
                content: const Text('Song Deleted!'),
                duration: const Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            );
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: const Text(
            "Delete from device",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const Icon(
            PhosphorIconsFill.trash,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }
}
