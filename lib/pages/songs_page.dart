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
    if (androidVersion < 13) {
      status = await Permission.storage.request();
    } else {
      status = await Permission.audio.request();
    }

    if (status.isGranted) {
      await getSongs();
      permissionBox.put("permissionIsGranted", true);
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

    setState(() {
      loading = false;
    });
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
    // return playlist;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(songListProvider);
    final miniplayer = ref.watch(isMiniplayerOpenProvider);

    print("rebuilding songs page");
    // if (songs != null) {
    //   // return const Text('No song');
    //   // playlist = ConcatenatingAudioSource(
    //   //   // Start loading next item just before reaching it
    //   //   useLazyPreparation: true,
    //   // children: await Future.wait(songs.map((song) async {
    //   //   final artworkUri = await _getArtworkUri(song);
    //   //   return AudioSource.uri(
    //   //     Uri.parse(song.uri!),
    //   //     tag: MediaItem(
    //   //       id: song.id.toString(),
    //   //       title: song.title,
    //   //       album: song.album,
    //   //       artist: song.artist,
    //   //       duration: Duration(microseconds: song.duration ?? 0),
    //   //       artUri: artworkUri != null ? Uri.file(artworkUri) : null,
    //   //       displayTitle: song.title,
    //   //       displaySubtitle: song.artist,
    //   //       displayDescription: song.album,
    //   //     ),
    //   //   );
    //   // }).toList()),
    //   // );
    //   print("creating playlist");
    //   _createPlaylist(songs);
    // }
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
                    onTap: () {
                      _createPlaylist(songs);
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
