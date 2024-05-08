import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:android_path_provider/android_path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'No Frills Media Player',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.dark()),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => MusicAppState();
}

class MusicAppState extends State<HomePage> {
  Future<Directory>? appMusicDir;
  List<String> musicFiles = [];
  List<ElevatedButton> musicButtons = [];
  final player = AudioPlayer();

  void _loadFiles() async {
    if (appMusicDir != null) {
      appMusicDir!.then((dir) {
        dir.list().forEach((element) {
          if (element is File) {
            musicFiles.add(element.path);
          }
        });
      });
    }
  }

  void _watchFiles() {
    if (appMusicDir != null) {
      appMusicDir!.then((dir) {
        dir.watch().listen((event) {
          if (event is FileSystemCreateEvent) {
            musicFiles.add(event.path);
          } else if (event is FileSystemDeleteEvent) {
            musicFiles.remove(event.path);
          }
        });
      });
    }
  }

  Widget _buildDirectory(
      BuildContext context, AsyncSnapshot<Directory?> snapshot) {
    Text text = const Text('');
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        text = Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        text = Text('path: ${snapshot.data!.path}');
      } else {
        text = const Text('path unavailable');
      }
    }
    return text;
  }

  void getMusicDir() {
    if (Platform.isAndroid) {
      AndroidPathProvider.musicPath.then((value) => {
            setState(() {
              appMusicDir = Future.value(Directory("$value/NFMP"));
              _loadFiles();
              _watchFiles();
            })
          });
    } else if (Platform.isIOS) {
      print('Running on iOS');
    } else if (Platform.isWindows) {
      getApplicationDocumentsDirectory().then((value) => {
            setState(() {
              value = Directory(
                  "${value.path.replaceFirst("Documents", "")}Music\\NFMP");
              //player.play(DeviceFileSource(
              //    "${value.path}/One Punch Man Opening Theme.mp3"));
              appMusicDir = Future.value(value);
              _loadFiles();
              _watchFiles();
            })
          });
    } else if (Platform.isMacOS) {
      print('Running on macOS');
    } else if (Platform.isLinux) {
      print('Running on Linux');
    } else {
      print('Unknown operating system');
    }

    setState(() {
      appMusicDir = Future.value(Directory("loading..."));
    });
  }

  @override
  void initState() {
    super.initState();
    getMusicDir();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title:
                  Text('NFMP', style: Theme.of(context).textTheme.displaySmall),
              leading:
                  IconButton(onPressed: () => {}, icon: Icon(Icons.search)),
              bottom: TabBar(tabs: <Widget>[
                Tab(child: Text('Albums')),
                Tab(child: Text('Playlists'))
              ]),
            ),
            body: TabBarView(children: [
              Scaffold(
                  body: ListView.builder(
                      itemCount: musicFiles.length,
                      itemBuilder: (context, index) {
                        return ElevatedButton(
                            onPressed: () {
                              player.play(DeviceFileSource(musicFiles[index]));
                            },
                            child: Text(musicFiles[index]));
                      })),
              Text('Playlists')
            ])));
  }
}
