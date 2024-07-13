import 'dart:io';

import 'package:audio_app/pages/SongsPage/song_tile.dart';
import 'package:audio_app/pages/Sorting.dart';
import 'package:audio_app/providers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class SongsPage extends ConsumerStatefulWidget {
  const SongsPage({super.key});

  @override
  _SongsPageState createState() => _SongsPageState();
}

class _SongsPageState extends ConsumerState<SongsPage> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  final ScrollController _semicircleController = ScrollController();
  bool loading = true;
  late ConcatenatingAudioSource playlist;
  late ConcatenatingAudioSource recentplaylist;

  final permissionBox = Hive.box('permissionIsGranted');

  @override
  void initState() {
    super.initState();

    if (permissionBox.get('permissionIsGranted') == null) {
      _checkPermissions();
    } else {
      getSongs();
    }
  }

  Future<void> _checkPermissions() async {
    final DeviceInfoPlugin info = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await info.androidInfo;
    final int androidVersion = int.parse(androidInfo.version.release);

    PermissionStatus status;
    // PermissionStatus noti;

    if (androidVersion < 13) {
      print("android 13");
      status = await Permission.storage.status;
      // noti = PermissionStatus.granted;

      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    } else {
      print('android 14');
      status = await Permission.audio.status;
      var noti = await Permission.notification.status;

      if (!status.isGranted) {
        status = await Permission.audio.request();
      }

      if (!noti.isGranted) {
        print("Asking permission for notification");
        noti = await Permission.notification.request();
      }
    }

    if (status.isGranted) {
      await getSongs();
      permissionBox.put("permissionIsGranted", true);
      ref.read(permissionProvider.notifier).update((state) => true);
    } else {
      // Handle case when permissions are not granted
      print("Permissions not granted");
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> getSongs() async {
    List<SongModel> audios = await audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    List<SongModel> recentAudios = await audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    List<SongModel> filteredAudios = audios
        .where((audio) => audio.duration != null && audio.duration! > 60000)
        .toList();
    List<SongModel> filteredRecentAudios = recentAudios
        .where((audio) => audio.duration != null && audio.duration! > 60000)
        .toList();

    ref.read(songListProvider.notifier).update((state) => filteredAudios);
    ref
        .read(recentSongListProvider.notifier)
        .update((state) => filteredRecentAudios);
    ref
        .read(songsCountProvider.notifier)
        .update((state) => filteredAudios.length);

    playlist = await _createPlaylist(filteredAudios);
    recentplaylist = await _createPlaylist(filteredRecentAudios);

    ref.read(songsPlaylist.notifier).update((state) => playlist);

    ref.read(recentsongsPlaylist.notifier).update((state) => recentplaylist);

    ref.read(permissionProvider.notifier).update((state) => true);

    setState(() {
      // songs = a;
      loading = false;
    });

    List<LastPlayedEntity> query =
        await OnAudioRoom().queryLastPlayed(sortType: RoomSortType.DATE_ADDED);
    ref.read(lastPlayedProvider.notifier).update((state) => query);

    List<FavoritesEntity> favouritesQuery =
        await OnAudioRoom().queryFavorites(sortType: RoomSortType.DATE_ADDED);
    ref.read(favoritesProvider.notifier).update((state) => favouritesQuery);
  }

  Future<String?> _getArtworkUri(SongModel song) async {
    final artwork =
        await audioQuery.queryArtwork(song.id, ArtworkType.AUDIO, size: 1000);

    if (artwork != null) {
      final directory = await getTemporaryDirectory();
      final artworkFile = File('${directory.path}/${song.id}.png');
      await artworkFile.writeAsBytes(artwork);
      return artworkFile.path;
    }
    return null;
  }

  Future<ConcatenatingAudioSource> _createPlaylist(
      List<SongModel> songs) async {
    return ConcatenatingAudioSource(
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
    // return playlist;
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(songListProvider);
    final miniplayer = ref.watch(isMiniplayerOpenProvider);
    final player = ref.watch(playerProvider);
    final lastPlayedSongs = ref.watch(lastPlayedProvider);

    print("rebuilding songs page");

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (songs == null || songs.isEmpty) {
      return const Center(child: Text('No songs available on your device'));
    }

    return Padding(
      padding: EdgeInsets.only(bottom: miniplayer ? 80 : 0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Sorting(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: DraggableScrollbar.semicircle(
              labelTextBuilder: (double offset) {
                int index = (offset ~/ songs.length).clamp(0, songs.length - 1);
                String firstLetter =
                    songs[index].title.substring(0, 1).toUpperCase();
                return Text(
                  firstLetter,
                  style: const TextStyle(color: Colors.black),
                );
              },
              labelConstraints:
                  const BoxConstraints.tightFor(width: 50.0, height: 50.0),
              controller: _semicircleController,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: songs.length,
                controller: _semicircleController,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      ref
                          .read(isMiniplayerOpenProvider.notifier)
                          .update((state) => true);
                      ref
                          .read(playingFromProvider.notifier)
                          .update((state) => 0);

                      player.setAudioSource(playlist,
                          initialIndex: index, initialPosition: Duration.zero);
                      player.play();

                      await OnAudioRoom().addTo(
                        RoomType.LAST_PLAYED,
                        songs[index].getMap.toLastPlayedEntity(0),
                      );

                      // setState(() {
                      //   lastPlayedSongs
                      //       .add(songs[index].getMap.toLastPlayedEntity(0));
                      //   print(lastPlayedSongs);
                      // });

                      ref.read(lastPlayedProvider.notifier).update((state) => [
                            songs[index].getMap.toLastPlayedEntity(0),
                            ...state
                          ]);
                    },
                    child: SongTile(
                      // index: index, playlist: playlist, song: songs[index]);
                      index: index,
                      // playlist: playlist,
                      song: songs[index],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
