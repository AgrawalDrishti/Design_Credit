import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

import 'package:design_credit/pages/create_profile.dart';

class PositionData {
  const PositionData(
    this.position,
    this.bufferedPosition,
    this.duration,
  );

  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}

// Future<String> writeLog(String folderName) async {
//   print("function called");
//   final dir = Directory((Platform.isAndroid
//               ? await getExternalStorageDirectory()
//               : await getApplicationSupportDirectory())!
//           .path +
//       '/$folderName');
//   print(dir.path);
//   var status = await Permission.storage.status;
//   print(status);
//   if (!status.isGranted) {
//     await Permission.storage.request();
//   }
//   print(await dir.exists() ? "yes" : "no");
//   if (!(await dir.exists())) {
//     dir.create();
//     print("directly created");
//   }
//   // creating logs file
//   final file = File('${dir.path}/logs.json');
//   file.create();
//   return "function called";
// }

// writing into logs.json
Future<void> writeToLogFile(
    String? folderName, Map<String, dynamic> jsonMap) async {
  print("writing logs");
  final dir = Directory((Platform.isAndroid
              ? await getExternalStorageDirectory()
              : await getApplicationSupportDirectory())!
          .path +
      '/$folderName');
  print(dir.path);
  if (!(await dir.exists())) {
    dir.create();
  }
  final file = File('${dir.path}/logs.json');
  await file.writeAsString('\n' + json.encode(jsonMap), mode: FileMode.append);
  print("log written");
}

Future<void> clearLogFile(String? folderName) async {
  print("clearing logs");

  final dir = Directory((Platform.isAndroid
              ? await getExternalStorageDirectory()
              : await getApplicationSupportDirectory())!
          .path +
      '/$folderName');
  print(dir.path);
  if (!(await dir.exists())) {
    dir.create();
  }
  final file = File('${dir.path}/logs.json');
  await file.delete();
  file.create();
  print("logs cleared");
}

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('audio/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

Future<void> shareJson(String? folderName) async {
  final dir = Directory((Platform.isAndroid
              ? await getExternalStorageDirectory()
              : await getApplicationSupportDirectory())!
          .path +
      '/$folderName/logs.json');
  await Share.shareFiles([dir.path], text: 'Check out the logs file!');
}

Future<void> shareAsset(String path) async {
  final imageFile = await getImageFileFromAssets(path);
  String localPath = imageFile.path;
  await Share.shareFiles([localPath], text: 'Check out this image!');
}

class AudioPlayerPage extends StatefulWidget {
  final String? selectedFolder;

  AudioPlayerPage({Key? key, required this.selectedFolder}) : super(key: key);

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState(selectedFolder);
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final String? selectedFolder;

  _AudioPlayerPageState(this.selectedFolder);

  late AudioPlayer _audioPlayer;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer()..setAsset('audio/song.mp3');

    _audioPlayer.positionStream;
    _audioPlayer.bufferedPositionStream;
    _audioPlayer.durationStream;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text("Meditation App for AIIMS Rishikesh"),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile Options'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateProfile()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Share Data'),
                onTap: () {
                  Navigator.pop(context);

                  shareJson(selectedFolder);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Data'),
                onTap: () {
                  Navigator.pop(context);

                  clearLogFile(selectedFolder);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Logs Cleared 💀")));
                },
              ),
              ListTile(
                leading: Icon(Icons.code),
                title: Text('Test Button'),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Enter Password"),
                          content: TextField(
                            onChanged: (value) {},
                            decoration: InputDecoration(
                                hintText: "Enter Nurse Password"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Submit"),
                            )
                          ],
                        );
                      });
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
            ),
            SizedBox(
              height: 500,
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              height: 200,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return ProgressBar(
                        progress: positionData?.position ?? Duration.zero,
                        buffered:
                            positionData?.bufferedPosition ?? Duration.zero,
                        total: positionData?.duration ?? Duration.zero,
                        onSeek: _audioPlayer.seek,
                      );
                    },
                  ),
                  Controls(
                    audioPlayer: _audioPlayer,
                    selectedFolder: selectedFolder,
                  )
                ],
              ),
            ),
          ],
        ));
  }
}

class Controls extends StatelessWidget {
  const Controls({
    super.key,
    required this.audioPlayer,
    required this.selectedFolder,
  });

  final AudioPlayer audioPlayer;
  final String? selectedFolder;

  Future<void> logAction(String action) async {
    final currentTime = DateTime.now();
    final currentPosition = audioPlayer.position;
    Map<String, dynamic> jsonMap = {
      'action': action,
      'time': currentTime.toString(),
      'position': currentPosition.toString()
    };
    await writeToLogFile(selectedFolder, jsonMap);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        if (!(playing ?? false)) {
          return Container(
            height: 85,
            width: 85,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Color(0xFF2196f3)),
            child: IconButton(
              onPressed: () {
                audioPlayer.play();
                logAction('Play');
              },
              iconSize: 65.0,
              color: Colors.white,
              icon: const Icon(Icons.play_arrow_rounded),
            ),
          );
        } else if (processingState != ProcessingState.completed) {
          return Container(
            height: 85,
            width: 85,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Color(0xFF2196f3)),
            child: IconButton(
              onPressed: () {
                audioPlayer.pause();
                logAction('Pause');
              },
              iconSize: 65.0,
              color: Colors.white,
              icon: const Icon(Icons.pause_rounded),
            ),
          );
        }

        return IconButton(
          // onPressed: () => audioPlayer.seek(Duration.zero, index: audioPlayer.effectiveIndices!.first),
          onPressed: () {},
          iconSize: 80.0,
          color: Colors.white,
          icon: const Icon(Icons.play_arrow_rounded),
        );
      },
    );
  }
}
