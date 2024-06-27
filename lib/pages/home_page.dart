import 'dart:typed_data';

import 'package:audio_app/pages/home_page_card.dart';
import 'package:audio_app/providers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomePage extends ConsumerWidget {
  HomePage({super.key});
  final OnAudioQuery audioQuery = OnAudioQuery();
  late final ConcatenatingAudioSource playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(recentSongListProvider);
    // final permission = ref.watch(permissionProvider);
    // final permission = true;
    if (song != null) {
      // return const Text('No song');
      playlist = ConcatenatingAudioSource(
        // Start loading next item just before reaching it
        useLazyPreparation: true,
        children: song
            .map(
              (song) => AudioSource.uri(
                Uri.parse(song.uri!),
                tag: MediaItem(
                  id: song.id.toString(),
                  title: song.title,
                  album: song.album,
                  artist: song.artist,
                  duration: Duration(microseconds: song.duration ?? 0),
                  // artUri: artworkUri != null ? Uri.file(artworkUri) : null,
                  displayTitle: song.title,
                  displaySubtitle: song.artist,
                  displayDescription: song.album,
                ),
              ),
            )
            .toList(),
      );
    }

    // if (!permission) {
    //   return const Center(
    //     child: Text("Please allow the permission before continuing."),
    //   );
    // }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(43, 71, 132, 238),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Icon(
                          PhosphorIconsBold.clockCounterClockwise,
                          color: Color(0xFF4785EE),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'History',
                      style:
                          TextStyle(color: Color.fromARGB(216, 255, 255, 255)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(43, 233, 31, 98),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Icon(
                          PhosphorIconsBold.heart,
                          color: Color(0xFFE91F63),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Favourites',
                      style:
                          TextStyle(color: Color.fromARGB(216, 255, 255, 255)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(43, 51, 168, 82),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Icon(
                          PhosphorIconsBold.trendUp,
                          color: Color(0xFF33A853),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Most played',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color.fromARGB(216, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(43, 251, 189, 3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Icon(
                              PhosphorIconsBold.shuffle,
                              color: Color(0xFFFBBB03),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Shuffle',
                      style:
                          TextStyle(color: Color.fromARGB(216, 255, 255, 255)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: GestureDetector(
            onTap: () {
              PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                final appVersion = packageInfo.version;
                print(appVersion);
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recently Added songs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(
                  PhosphorIconsBold.arrowRight,
                  color: Colors.purpleAccent[100],
                )
              ],
            ),
          ),
        ),
        // song == null
        //     ? const Text("No song available")
        //     :
        SizedBox(
          height: 160,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: song!.length,
            // itemCount: 10,
            itemBuilder: (context, index) {
              return HomePageCard(playlist, index, song[index]);
            },
          ),
        )
      ],
    );
  }
}
