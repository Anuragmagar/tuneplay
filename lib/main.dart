import 'package:audio_app/pages/albums_page.dart';
import 'package:audio_app/pages/artists_page.dart';
import 'package:audio_app/pages/BottomMiniplayer/bottom_mini_player.dart';
import 'package:audio_app/pages/bottom_navbar.dart';
import 'package:audio_app/pages/drawer_page.dart';
import 'package:audio_app/pages/home_page.dart';
import 'package:audio_app/pages/playlists_page.dart';
import 'package:audio_app/pages/songs_page.dart';
import 'package:audio_app/providers.dart';
import 'package:audio_app/theme/color_schemes.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  await Hive.initFlutter();
  await Hive.openBox('permissionIsGranted');

  await OnAudioRoom().initRoom();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        fontFamily: 'CircularStd',
        textTheme: const TextTheme(
          titleMedium: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  final List<Widget> pages = [
    HomePage(),
    const AlbumsPage(),
    const SongsPage(),
    const PlaylistsPage(),
    const ArtistsPage(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromRGBO(42, 41, 49, 1),
      systemNavigationBarDividerColor: Color.fromRGBO(42, 41, 49, 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool isMiniplayerOpen = ref.watch(isMiniplayerOpenProvider);
    final int currentPage = ref.watch(currentPageProvider);

    return Scaffold(
      key: _key, // Assign the key to Scaffold.

      backgroundColor: const Color.fromRGBO(28, 27, 32, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(28, 27, 32, 1),
        scrolledUnderElevation: 0,
        title: TextField(
          readOnly: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.all(8),
            prefixIcon: GestureDetector(
              onTap: () {
                _key.currentState!.openDrawer();
              },
              child: Icon(
                PhosphorIcons.list(),
                color: const Color(0xfff2f2f2),
              ),
            ),
            hintText: 'Search your music',
            hintStyle: Theme.of(context).textTheme.titleMedium,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(84),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: currentPage,
              children: pages,
            ),
            if (isMiniplayerOpen)
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomMiniPlayer(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(),
      drawer: DrawerPage(_key),
    );
  }
}
