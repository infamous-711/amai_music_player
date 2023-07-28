import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MusicHome(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}

IconData getVolumeIcon(double volume) {
  if (volume >= 0.5) {
    return Icons.volume_up_rounded;
  } else if (volume < 0.5 && volume != 0.0) {
    return Icons.volume_down_rounded;
  } else {
    return Icons.volume_off_rounded;
  }
}

class MusicHome extends StatefulWidget {
  const MusicHome({super.key});

  @override
  MusicHomeState createState() => MusicHomeState();
}

class MusicHomeState extends State<MusicHome> {
  // Initialize the audio player
  AudioPlayer audioPlayer = AudioPlayer();

  List<String> musicFiles = []; // List to store the paths of music files
  double volume = 0.5; // Volume of the music (0.0 to 1.0)
  int currentPlayingIndex =
      -1; // Initialize to -1 to indicate no music is playing
  String musicName = "";
  Duration audioDuration = const Duration();
  Duration currentPosition = const Duration();

  @override
  void initState() {
    super.initState();
    audioPlayer.setVolume(volume);
    loadMusicFiles();
  }

  void playMusic(List<String> musicFiles, int index) {
    setState(() => currentPlayingIndex = index);

    String musicPath = musicFiles[index];
    audioPlayer.play(DeviceFileSource(musicPath));
    musicName = musicFiles[index].split('/').last;

    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        audioDuration = duration;
      });
    });

    audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        currentPosition = position;
      });
    });
  }

  void playPrevious(List<String> musicFiles) {
    int index = currentPlayingIndex;
    if (index != 0) {
      index -= 1;
    }
    playMusic(musicFiles, index);
  }

  void playNext(List<String> musicFiles) {
    int index = currentPlayingIndex;
    if ((musicFiles.length - 1) != index) {
      index += 1;
    }
    playMusic(musicFiles, index);
  }

  void toggleMusic() {
    if (audioPlayer.state == PlayerState.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.resume();
    }
  }

  IconData getPlaybuttonIcon() {
    if (audioPlayer.state == PlayerState.playing) {
      return Icons.pause_outlined;
    } else {
      return Icons.play_arrow;
    }
  }

  String getMusicDirectory() {
    if (Platform.isLinux) {
      String homeDir = path.join('/home', Platform.environment['USER']);
      String musicDir = path.join(homeDir, 'Music');
      return musicDir;
    } else {
      // TODO: Handle other platforms (Windows, macOS)
      return '';
    }
  }

  void loadMusicFiles() async {
    String musicDir = getMusicDirectory(); // Get the external storage directory

    setState(() {
      musicFiles = Directory(musicDir)
          .listSync()
          .where((file) =>
              file.path.endsWith('.mp3') || file.path.endsWith('.ogg'))
          .map((file) => file.path)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final musicList = Expanded(
      child: ListView.builder(
        itemCount: musicFiles.length,
        itemBuilder: (context, index) {
          String titleName = musicFiles[index].split('/').last;
          return ListTile(
            title: Text(titleName),
            onTap: () {
              playMusic(musicFiles, index);
            },
            selected: currentPlayingIndex == index,
            selectedColor: Theme.of(context).colorScheme.onPrimary,
            selectedTileColor: Theme.of(context).colorScheme.primary,
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amai Music Player'),
      ),
      body: Column(
        children: [
          musicList,
          Column(
            children: [
              Text(musicName, overflow: TextOverflow.fade),
              Row(children: [
                IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () => playPrevious(musicFiles)),
                IconButton(
                    icon: Icon(getPlaybuttonIcon()),
                    onPressed: () => toggleMusic()),
                IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: () => playNext(musicFiles)),
                const SizedBox(width: 10),
                Text(
                    '${currentPosition.inMinutes}:${currentPosition.inSeconds - (currentPosition.inMinutes * 60)}/${audioDuration.inMinutes}:${audioDuration.inSeconds - (audioDuration.inMinutes * 60)}'),
                Expanded(
                    child: Slider(
                  min: 0.0,
                  max: audioDuration.inMilliseconds.toDouble(),
                  value: currentPosition.inMilliseconds.toDouble(),
                  onChanged: (newPosition) {
                    setState(() {
                      audioPlayer
                          .seek(Duration(milliseconds: newPosition.toInt()));
                    });
                  },
                )),
                Icon(getVolumeIcon(volume)),
                Slider(
                    value: volume,
                    onChanged: (newVolume) {
                      setState(() {
                        volume = newVolume;
                        audioPlayer.setVolume(volume);
                      });
                    },
                    max: 1.0,
                    min: 0.0),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
