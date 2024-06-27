import 'package:audio_app/pages/artist_detail_page.dart';
import 'package:audio_app/pages/sorting_album.dart';
import 'package:audio_app/providers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ArtistsPage extends ConsumerStatefulWidget {
  const ArtistsPage({super.key});

  @override
  ConsumerState<ArtistsPage> createState() => _ArtistsPageState();
  // _ArtistsPageState createState() => _ArtistsPageState();
}

class _ArtistsPageState extends ConsumerState<ArtistsPage> {
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
                // Text("child of artist page"),
                FutureBuilder<List<ArtistModel>>(
              // Default values:
              future: audioQuery.queryArtists(
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

                return GridView.builder(
                  itemCount: snapshot.data!.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    // mainAxisSpacing: 4,
                    childAspectRatio: 0.80,
                  ),
                  itemBuilder: ((context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 165,
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () {
                                  final artist = snapshot.data![index];

                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return ArtistDetailPage(
                                      noOfAlbums: artist.numberOfAlbums!,
                                      artist: artist.artist,
                                      id: artist.id,
                                      noOfTracks: artist.numberOfTracks!,
                                    );
                                  }));
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: QueryArtworkWidget(
                                        // artworkHeight: 150,
                                        // artworkWidth: 150,
                                        artworkFit: BoxFit.cover,
                                        controller: audioQuery,
                                        // id: snapshot.data![index].id,
                                        id: snapshot.data![index].id,
                                        type: ArtworkType.ARTIST,
                                        artworkBorder:
                                            BorderRadius.circular(10),
                                        size: 800,
                                        nullArtworkWidget: Container(
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            PhosphorIconsFill.userList,
                                            color: Colors.grey,
                                            size: 64,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      bottom: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              PhosphorIconsFill.musicNoteSimple,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            // const SizedBox(width: 5),
                                            Text(
                                              snapshot
                                                  .data![index].numberOfTracks
                                                  .toString(),
                                              style: const TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          snapshot.data![index].artist,
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold),
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
