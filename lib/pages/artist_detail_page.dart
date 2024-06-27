import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:http/http.dart' as http;

class ArtistDetailPage extends StatefulWidget {
  final int noOfAlbums;
  final int id;
  final int noOfTracks;
  final String artist;
  const ArtistDetailPage(
      {this.noOfAlbums = 0,
      this.artist = '',
      this.id = 0,
      this.noOfTracks = 0,
      super.key});

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
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

class _ArtistDetailPageState extends State<ArtistDetailPage>
    with SingleTickerProviderStateMixin {
  final OnAudioQuery audioQuery = OnAudioQuery();
  late Future<Uint8List?> artworkFuture;
  Map<int, Uint8List?> artworkCache = {};

  late ScrollController _scrollController;
  bool _isExpanded = false;
  String bio = '';
  bool isGettingArtistBio = true;
  int totalTime = 0;

  @override
  void initState() {
    artworkFuture =
        audioQuery.queryArtwork(widget.id, ArtworkType.ARTIST, size: 1000);

    super.initState();

    getArtistBio();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {});
      });

    getArtistSongs();

    // WidgetsBinding.instance.addPostFrameCallback((_) => getArtistBio());
  }

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset > (400 - kToolbarHeight);
  }

  getArtistBio() async {
    var url = Uri.parse(
        'https://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=${widget.artist}&api_key=2dbaf6156c82a38328d4590f297043bf&format=json');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        bio = jsonResponse['artist']['bio']['content'];
        isGettingArtistBio = false;
      });
    }
    return response.statusCode.toString();
  }

  Future<List<SongModel>> getArtistSongs() async {
    List<SongModel> audios =
        await audioQuery.queryAudiosFrom(AudiosFromType.ARTIST, widget.artist);

    List<SongModel> filteredAudios = [];
    int totalDuration = 0;
    for (var audio in audios) {
      if (audio.duration != null && audio.duration! > 60000) {
        filteredAudios.add(audio);
        totalDuration += audio.duration!;
        if (!artworkCache.containsKey(audio.id)) {
          Uint8List? artwork =
              await audioQuery.queryArtwork(audio.id, ArtworkType.AUDIO);
          artworkCache[audio.id] = artwork;
        }
      }
    }
    setState(() {
      totalTime = totalDuration;
    });
    return filteredAudios;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 27, 32, 1),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            // automaticallyImplyLeading: false,
            backgroundColor: const Color.fromRGBO(28, 27, 32, 1),
            pinned: true,
            // centerTitle: true,
            expandedHeight: 400,
            title: _isSliverAppBarExpanded
                ? Text(
                    widget.artist,
                    style: const TextStyle(overflow: TextOverflow.ellipsis),
                  )
                : null,
            flexibleSpace: _isSliverAppBarExpanded
                ? null
                : FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: const EdgeInsets.only(left: 0),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        FutureBuilder<Uint8List?>(
                          future: artworkFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
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
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                stops: [0, 1],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xFF1B1C20)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        widget.artist,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ),
          SliverToBoxAdapter(
            child: Text(
              '${widget.noOfTracks} Songs・${formatDuration(totalTime)}',
              textAlign: TextAlign.center,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 25,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Songs',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 25),
                  FutureBuilder<List<SongModel>>(
                    future: getArtistSongs(),
                    builder: (context, snapshot) {
                      final data = snapshot.data;
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            for (int index = 0; index < data!.length; index++)
                              ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                title: Text(
                                  data[index].title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${data[index].artist}・${formatDuration(data[index].duration)}',
                                  style: const TextStyle(
                                      color: Color.fromRGBO(218, 218, 218, 1)),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                leading: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0)),
                                  child: artworkCache[data[index].id] != null
                                      ? Image.memory(
                                          artworkCache[data[index].id]!,
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 50,
                                          width: 50,
                                          color: Colors.white60,
                                          child: const Icon(
                                            PhosphorIconsDuotone.musicNote,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                                trailing: const Icon(
                                  PhosphorIconsFill.dotsThreeOutlineVertical,
                                  color: Color.fromRGBO(218, 218, 218, 1),
                                ),
                              )
                          ],
                        );
                      }
                      return const Text('No songs');
                    },
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Biography',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: isGettingArtistBio
                          ? const Center(child: CircularProgressIndicator())
                          : Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Text(
                                    bio,
                                    maxLines: _isExpanded ? null : 3,
                                  ),
                                  _isExpanded
                                      ? const SizedBox.shrink()
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              'More',
                                              style: TextStyle(
                                                  color: Colors.purple),
                                              textAlign: TextAlign.right,
                                            ),
                                            Icon(
                                              PhosphorIconsRegular.caretDown,
                                              color: Colors.purple,
                                              size: 16,
                                            )
                                          ],
                                        )
                                ],
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
