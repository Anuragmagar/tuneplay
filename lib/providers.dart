import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';

final player = AudioPlayer();
int currentIndex = player.currentIndex ?? 0;

final currentPageProvider = StateProvider<int>((ref) => 2);

final selectedSongProvider = StateProvider<SongModel?>((ref) {
  return null;
});

final songListProvider = StateProvider<List<SongModel>?>((ref) {
  return null;
});

final recentSongListProvider = StateProvider<List<SongModel>?>((ref) {
  return null;
});

final songsCountProvider = StateProvider((ref) => 0);

final playerProvider = StateProvider((ref) => player);

final isMiniplayerOpenProvider = StateProvider<bool>((ref) => false);

final currentIndexProvider = StateProvider((ref) {
  return currentIndex;
});

final currentPlayingMusicProvider = StateProvider<SongModel>((ref) {
  final songs = ref.read(songListProvider);
  SongModel selectedSong = songs![currentIndex];

  return selectedSong;
});

final loopModeProvider = StateProvider<String>((ref) {
  return "off";
});

final isShuffleModeProvider = StateProvider<bool>((ref) {
  return false;
});

// playing from recent or songs
// songs -> 0
// recent -> 1
final playingFromProvider = StateProvider<int>((ref) => 0);

final permissionProvider = StateProvider<bool>((ref) => false);

final versionProvider = StateProvider<String>((ref) => '1.0.0');

final isVersionCheckedProvider = StateProvider<bool>((ref) => false);

final songsPlaylist = StateProvider<ConcatenatingAudioSource?>((ref) => null);
final recentsongsPlaylist =
    StateProvider<ConcatenatingAudioSource?>((ref) => null);

final lastPlayedProvider = StateProvider<List<LastPlayedEntity>>((ref) {
  return [];
});

final favoritesProvider = StateProvider<List<FavoritesEntity>>((ref) {
  return [];
});
