import 'dart:convert';
import 'dart:io';
import 'package:audio_app/providers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class DrawerPage extends ConsumerStatefulWidget {
  const DrawerPage(this.mainkey, {super.key});
  final GlobalKey<ScaffoldState> mainkey;

  @override
  ConsumerState<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends ConsumerState<DrawerPage> {
  String vers = '';
  double totalBytes = 0.0;
  double downloadedBytes = 0.0;
  bool downloaded = false;
  String path = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      final appVersion = packageInfo.version;
      ref.read(versionProvider.notifier).update((state) => appVersion);
      vers = appVersion;
    });

    getVersionFromBackend();
  }

  Future<void> getVersionFromBackend() async {
    if (!ref.read(isVersionCheckedProvider)) {
      final response =
          await http.get(Uri.parse("https://tuneplay.anuragmagar.com.np/"));
      final body = json.decode(response.body)[0];
      if (body['version'] != vers) {
        _showVersionMismatchDialog(
            body['version'], body['file_size'], body['file_name']);
      } else {
        ref.read(isVersionCheckedProvider.notifier).update((state) => true);
      }
    }
  }

  void _showVersionMismatchDialog(
      String version, String size, String fileName) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              icon: const Icon(Icons.info),
              title: const Text('Update Available'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Newest version of this app is available. Tap Download Now button to download the newest version of this app in your device.',
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(value: downloadedBytes),
                      ),
                      const SizedBox(
                          width:
                              10), // Add some space between the progress indicator and the text
                      Text('$size MB'),
                    ],
                  ),
                  downloaded
                      ? const SizedBox(
                          height: 15,
                        )
                      : const SizedBox.shrink(),
                  downloaded
                      ? const Text(
                          'File downloaded in /storage/emulated/0/Download/TunePlay. Please locate and install it manually & make sure to uninstall this before installing new one.')
                      : const SizedBox.shrink(),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    ref
                        .read(isVersionCheckedProvider.notifier)
                        .update((state) => true);
                    Navigator.of(context).pop();
                  },
                ),
                FilledButton(
                  child: Text('Download v.$version'),
                  onPressed: () async {
                    String filePath = await _localPath;
                    // setState(() {
                    //   downloading = true;
                    // });
                    FileDownloader.downloadFile(
                      url:
                          "https://github.com/Anuragmagar/tuneload/releases/download/v1.2.0/app-arm64-v8a-release.apk",
                      name: fileName,
                      subPath: '/TunePlay',
                      onProgress: (String? fileName, double progress) {
                        setState(() {
                          downloadedBytes = progress / 100;
                        });
                      },
                      onDownloadCompleted: (String fpath) {
                        MediaScanner.loadMedia(path: fpath);

                        setState(() {
                          downloaded = true;
                          path = fpath;
                        });

                        ref
                            .read(isVersionCheckedProvider.notifier)
                            .update((state) => true);
                      },
                      onDownloadError: (String error) {},
                      downloadDestination: DownloadDestinations.publicDownloads,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  //for getting the path and for permssion
  static Future<String> getExternalDocumentPath() async {
    final DeviceInfoPlugin info = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await info.androidInfo;
    final int androidVersion = int.parse(androidInfo.version.release);

    if (androidVersion < 13) {
      var status = await Permission.storage.status;

      if (!status.isGranted) {
        await Permission.storage.request();
      }
    } else {
      var notistatus = await Permission.notification.status;
      if (!notistatus.isGranted) {
        await Permission.notification.request();
      }
    }

    Directory directory = Directory("dir");
    if (Platform.isAndroid) {
      directory = Directory("/storage/emulated/0/Download/TunePlay");
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final exPath = directory.path;
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath async {
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  @override
  Widget build(BuildContext context) {
    final String version = ref.watch(versionProvider);
    return Drawer(
      shape: const Border(
        right: BorderSide.none,
      ),
      backgroundColor: const Color.fromRGBO(32, 33, 37, 1),
      child: CustomScrollView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
            stretch: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.2,
            flexibleSpace: FlexibleSpaceBar(
              title: RichText(
                text: TextSpan(
                  text: "TunePlay",
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w900,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: version,
                      style: const TextStyle(
                        fontSize: 7.0,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.end,
              ),
              titlePadding: const EdgeInsets.only(bottom: 40.0),
              centerTitle: true,
              background: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.1),
                    ],
                  ).createShader(
                    Rect.fromLTRB(0, 0, rect.width, rect.height),
                  );
                },
                blendMode: BlendMode.dstIn,
                child: const Image(
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  image: AssetImage('assets/images/header-dark.jpg'),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  title: const Text(
                    "Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(
                    PhosphorIconsFill.house,
                    // Icons.home,
                    color: Colors.white,
                    // size: ,
                  ),
                  selected: true,
                  onTap: () {
                    ref.read(currentPageProvider.notifier).update((state) => 0);
                    widget.mainkey.currentState!.closeDrawer();
                  },
                ),
                ListTile(
                  title: const Text(
                    "Albums",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(
                    Icons.album,
                    color: Colors.white,
                  ),
                  // selected: true,
                  onTap: () {
                    ref.read(currentPageProvider.notifier).update((state) => 1);
                    widget.mainkey.currentState!.closeDrawer();
                  },
                ),
                ListTile(
                  title: const Text(
                    "Songs",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(
                    Icons.music_note,
                    color: Colors.white,
                  ),
                  // selected: true,
                  onTap: () {
                    ref.read(currentPageProvider.notifier).update((state) => 2);
                    widget.mainkey.currentState!.closeDrawer();
                  },
                ),
                ListTile(
                  title: const Text(
                    "Playlists",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(
                    Icons.library_music,
                    color: Colors.white,
                  ),
                  // selected: true,
                  onTap: () {
                    ref.read(currentPageProvider.notifier).update((state) => 3);
                    widget.mainkey.currentState!.closeDrawer();
                  },
                ),
                ListTile(
                  title: const Text(
                    "Artists",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(
                    PhosphorIconsDuotone.users,
                    color: Colors.white,
                  ),
                  // selected: true,
                  onTap: () {
                    ref.read(currentPageProvider.notifier).update((state) => 4);
                    widget.mainkey.currentState!.closeDrawer();
                  },
                ),
                ListTile(
                  title: const Text(
                    "About",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(
                    PhosphorIconsFill.info,
                    color: Colors.white,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: <Widget>[
                const Spacer(),
                const Divider(
                  color: Colors.white30,
                  height: 5,
                ),
                ListTile(
                  title: const Text(
                    "Visit website",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: const Text(
                    "https://anuragmagar.com.np",
                    style: TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(
                    PhosphorIconsFill.globe,
                    color: Colors.white,
                  ),
                  onTap: () async {
                    await launchUrl(Uri.parse('https://anuragmagar.com.np'));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
