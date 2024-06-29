import 'dart:async';

import 'package:audio_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:text_scroll/text_scroll.dart';

class SongTitlePage extends ConsumerStatefulWidget {
  const SongTitlePage({super.key});

  @override
  _SongTitlePageState createState() => _SongTitlePageState();
}

class _SongTitlePageState extends ConsumerState<SongTitlePage> {
  // late StreamSubscription<int?> indexStream;
  final OnAudioRoom _audioRoom = OnAudioRoom();
  bool isFavourite = false;

  late StreamSubscription<int?> indexStream;
  List<SongModel>? songs;
  late SongModel song;

  isFav(SongModel song) async {
    bool fav = await _audioRoom.checkIn(
      RoomType.FAVORITES,
      song.id,
      // song.getMap.toFavoritesEntity()
    );
    print('from favourite $fav');
    setState(() {
      isFavourite = fav;
    });
  }

  addToRecent(song) async {
    await OnAudioRoom().addTo(
      RoomType.LAST_PLAYED,
      song.getMap.toLastPlayedEntity(0),
    );
  }

  @override
  void didChangeDependencies() async {
    // final player = ref.read(playerProvider);
    // final songs = ref.read(songListProvider);

    // int songIndex = player.currentIndex!;
    // SongModel song = songs![songIndex];

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
    isFav(song);

    indexStream = player.currentIndexStream.listen((p) {
      if (p != null && p != songIndex) {
        print('is fav invoked');
        songIndex = p;
        song = songs![songIndex];
        isFav(song);
        addToRecent(song);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    indexStream.cancel();
    // _audioRoom.closeRoom();

    super.dispose();
  }

  // check() async {
  //   List<FavoritesEntity> queryResult = await OnAudioRoom().queryFavorites(
  //       // 100, //Default: 50
  //       // true, //Default: false
  //       // RoomSortType.TITLE //Default: null
  //       );
  //   print(queryResult);
  // }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (song.title.length < 35)
                Flexible(
                  child: Text(
                    song.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'CircularStd',
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (song.title.length >= 35)
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: TextScroll(
                    song.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'CircularStd',
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                    velocity: const Velocity(pixelsPerSecond: Offset(50, 0)),
                    delayBefore: const Duration(milliseconds: 800),
                    pauseBetween: const Duration(milliseconds: 1000),
                    fadedBorder: true,
                    fadedBorderWidth: 0.05,
                  ),
                ),
              Flexible(
                child: Text(
                  song.artist.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'CircularStd',
                    // fontWeight: FontWeight.w900,
                    // letterSpacing: -1,
                    color: Color.fromRGBO(179, 179, 178, 1),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () async {
            print('adding');
            final add = await _audioRoom.addTo(
              RoomType.FAVORITES, // Specify the room type
              song.getMap.toFavoritesEntity(),
              ignoreDuplicate: false, // Avoid the same song
            );

            // print(addToResult);
            // bool isAdded = await _audioRoom.checkIn(
            //   RoomType.FAVORITES,
            //   song.id,
            // );
            // print('$isAdded');
            // final ool = await isFav(song);
            // print(ool);
            // await isFav(song);
            // await check();
            if (add != 0) {
              setState(() {
                isFavourite = true;
              });
            } else {
              final fav = await _audioRoom.queryFromFavorites(song.id);
              if (fav != null) {
                await _audioRoom.deleteFrom(
                  RoomType.FAVORITES, // Specify the room type
                  fav.key,
                );

                setState(() {
                  isFavourite = false;
                });
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              isFavourite
                  ? PhosphorIconsFill.heart
                  : PhosphorIconsRegular.heart,
            ),
          ),
        )
      ],
    );
  }
}
