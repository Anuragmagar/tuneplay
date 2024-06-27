import 'package:audio_app/pages/Sorting.dart';
import 'package:audio_app/pages/sorting_album.dart';
import 'package:audio_app/providers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:overflow_text_animated/overflow_text_animated.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AlbumsPage extends ConsumerStatefulWidget {
  const AlbumsPage({super.key});

  @override
  ConsumerState<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends ConsumerState<AlbumsPage> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  final permissionBox = Hive.box('permissionIsGranted');
  bool permission = true;

  @override
  void initState() {
    super.initState();

    if (permissionBox.get('permissionIsGranted') == null) {
      setState(() {
        permission = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final permission = ref.watch(permissionProvider);
    // SongModel song = songs![songIndex];

    if (!permission) {
      return const Center(
          child: Text('Please allow the permission before continuing.'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Sorting(songsCount),
          const SortingAlbum(),
          const SizedBox(height: 10),
          Expanded(
            child:
                // Text("child of albmum page"),
                FutureBuilder<List<AlbumModel>>(
              // Default values:
              future: audioQuery.queryAlbums(
                sortType: null,
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true,
              ),
              builder: (context, snapshot) {
                // Display error, if any.
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }

                // Waiting content.
                if (snapshot.data == null) {
                  return const CircularProgressIndicator();
                }

                // 'Library' is empty.
                if (snapshot.data!.isEmpty) return const Text("Nothing found!");

                // print(snapshot.data!.length);

                // You can use [snapshot.data!] direct or you can create a:
                // List<SongModel> songs = snapshot.data!;

                return GridView.builder(
                  itemCount: snapshot.data!.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    // mainAxisSpacing: 4,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: ((context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(children: [
                          Container(
                            height: 165,
                            width: double.infinity,
                            child: QueryArtworkWidget(
                              // artworkHeight: 150,
                              // artworkWidth: 150,
                              artworkFit: BoxFit.cover,
                              controller: audioQuery,
                              id: snapshot.data![index].id,
                              type: ArtworkType.ALBUM,
                              artworkBorder: BorderRadius.circular(10),
                              size: 800,
                              nullArtworkWidget: Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  PhosphorIconsFill.disc,
                                  color: Colors.grey,
                                  size: 64,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(0, 0, 0, 0.459),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.all(5),
                              child: const Icon(
                                PhosphorIconsFill.play,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              margin: EdgeInsets.all(5),
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                PhosphorIconsFill.dotsThreeOutlineVertical,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          )
                        ]),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          snapshot.data![index].album,
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          snapshot.data![index].artist.toString(),
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
