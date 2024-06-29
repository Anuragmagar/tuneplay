import 'dart:io';
import 'dart:typed_data';

import 'package:audio_app/pages/home_favourite_card.dart';
import 'package:audio_app/pages/home_last_played.dart';
import 'package:audio_app/pages/home_page_card.dart';
import 'package:audio_app/providers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  // late final ConcatenatingAudioSource playlist;
  List<FavoritesEntity> favourites = [];
  List<LastPlayedEntity> lastPlayed = [];
  final permissionBox = Hive.box('permissionIsGranted');
  bool permission = true;

  // Future<String?> _getArtworkUri(SongModel song) async {
  //   final artwork = await audioQuery.queryArtwork(song.id, ArtworkType.AUDIO);

  //   if (artwork != null) {
  //     final directory = await getTemporaryDirectory();
  //     final artworkFile = File('${directory.path}/${song.id}.png');
  //     await artworkFile.writeAsBytes(artwork);
  //     return artworkFile.path;
  //   }
  //   return null;
  // }

  // Future<void> _createPlaylist(List<SongModel> songs) async {
  //   playlist = ConcatenatingAudioSource(
  //     useLazyPreparation: true,
  //     children: await Future.wait(songs.map((song) async {
  //       final artworkUri = await _getArtworkUri(song);
  //       return AudioSource.uri(
  //         Uri.parse(song.uri!),
  //         tag: MediaItem(
  //           id: song.id.toString(),
  //           title: song.title,
  //           album: song.album,
  //           artist: song.artist,
  //           duration: Duration(microseconds: song.duration ?? 0),
  //           artUri: artworkUri != null ? Uri.file(artworkUri) : null,
  //           displayTitle: song.title,
  //           displaySubtitle: song.artist,
  //           displayDescription: song.album,
  //         ),
  //       );
  //     }).toList()),
  //   );
  //   // return playlist;
  //   setState(() {});
  // }

  void getFavourites() async {
    // await OnAudioRoom().clearAll();
    List<FavoritesEntity> queryResult =
        await OnAudioRoom().queryFavorites(sortType: RoomSortType.DATE_ADDED);
    setState(() {
      favourites = queryResult;
    });
  }

  void getRecentlyPlayed() async {
    List<LastPlayedEntity> query = await OnAudioRoom().queryLastPlayed();
    setState(() {
      lastPlayed = query;
    });
  }

  @override
  void initState() {
    super.initState();

    if (permissionBox.get('permissionIsGranted') == null) {
      setState(() {
        permission = false;
      });
    }

    if (permissionBox.get('permissionIsGranted') == true) {
      getFavourites();
      getRecentlyPlayed();
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // if ((ref.read(recentSongListProvider)) != null) {
    // _createPlaylist(ref.read(recentSongListProvider)!);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(recentSongListProvider);
    final miniplayer = ref.watch(isMiniplayerOpenProvider);
    final playlist = ref.watch(recentsongsPlaylist);
    // final permission = ref.watch(permissionProvider);
    // final permission = true;

    if (!permission) {
      return const Center(
        child: Text("Please allow the permission before continuing."),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: miniplayer ? 100 : 0),
        child: (song == null || song.isEmpty)
            ? const SizedBox.shrink()
            : (playlist == null)
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recently Added songs',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              PhosphorIconsBold.arrowRight,
                              color: Colors.purpleAccent[100],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: song.length,
                          // itemCount: 10,
                          itemBuilder: (context, index) {
                            return HomePageCard(playlist!, index, song[index]);
                          },
                        ),
                      ),

                      //Favourites block
                      favourites.isNotEmpty
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Text(
                                            'Favourites',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          getFavourites();
                                        },
                                        icon: const Icon(
                                          PhosphorIconsBold.arrowClockwise,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 250,
                                  // width: 180,
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: favourites.length,
                                    // itemCount: 10,
                                    itemBuilder: (context, index) {
                                      return HomeFavouriteCard(
                                          favourites[index]);
                                    },
                                  ),
                                ),
                              ],
                            )
                          // song == null
                          //     ? const Text("No song available")
                          //     :
                          : const SizedBox.shrink(),

                      lastPlayed.isNotEmpty
                          ?
                          //Recently played block
                          Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Text(
                                              'Recently Played Songs',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            getRecentlyPlayed();
                                          },
                                          icon: const Icon(
                                            PhosphorIconsBold.arrowClockwise,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 400,
                                  // width: double.infinity,
                                  child: Scrollbar(
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      // scrollDirection: Axis.horizontal,
                                      itemCount: lastPlayed.length,
                                      // itemCount: 10,
                                      itemBuilder: (context, index) {
                                        return HomeLastPlayed(
                                            lastPlayed[index]);
                                      },
                                    ),
                                  ),
                                )
                              ],
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
      ),
    );
  }
}
