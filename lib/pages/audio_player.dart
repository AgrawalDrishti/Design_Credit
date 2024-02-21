import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;
import 'package:design_credit/pages/create_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';

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

// writing into logs.csv
Future<void> writeToLogFile(String? folderName, String csvRow) async {
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
  final file = File('${dir.path}/logs.csv');

  // Check if the file is empty to write the header
  if (await file.lengthSync() == 0) {
    await file.writeAsString('action,time,position\n'); // Write the header
  }

  // Write the CSV row
  await file.writeAsString('\n' + csvRow, mode: FileMode.append);
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
  final file = File('${dir.path}/logs.csv');
  await file.delete();
  file.create();
  print("logs cleared");
}

Future<void> shareCsv(String? folderName) async {
  final dir = Directory((Platform.isAndroid
              ? await getExternalStorageDirectory()
              : await getApplicationSupportDirectory())!
          .path +
      '/$folderName/logs.csv');
  await Share.shareFiles([dir.path], text: 'Check out the logs file!');
}

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('audio/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
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
  late String? selectedFolder;
  String? selectedUser;

  _AudioPlayerPageState(this.selectedFolder) {
    _saveSelectedFolder();
  }

  Future<void> _saveSelectedFolder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedFolder', selectedFolder!);
  }

  final _playlist = ConcatenatingAudioSource(children: [
    AudioSource.uri(Uri.parse('asset:audio/song.mp3'),
        tag: MediaItem(
          id: '0',
          title: 'Meditation Track',
          artist: 'AIIMS Rishikesh',
          artUri: Uri.parse('asset:images/aiims-art.png'),
        ))
  ]);

  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

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

  late Future<List<String>> _folderNamesFuture;

  Future<List<String>> _fetchFolderNames() async {
    final directoryPath = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    Directory _directory = Directory(directoryPath!.path);
    print(_directory);
    List<String> _folderNames = _directory
        .listSync()
        .map((entity) => path.basename(entity.path))
        .toList();
    // _folderNamesStreamController.add(_folderNames);
    print(_folderNames);
    return _folderNames;
  }

  final selectedUserNotifier = ValueNotifier<String?>(null);
  @override
  void initState() {
    super.initState();

    _loadSelectedFolder();
    _folderNamesFuture = _fetchFolderNames();

    selectedUserNotifier.addListener(() {
      setState(() {});
    });

    // _audioPlayer = AudioPlayer()..setAsset('audio/song.mp3');
    _audioPlayer = AudioPlayer();
    _init();

    _audioPlayer.playingStream.listen((playing) {
      setState(() {
        _isPlaying = playing;
      });
    });

    _audioPlayer.positionStream;
    _audioPlayer.bufferedPositionStream;
    _audioPlayer.durationStream;
  }

  Future<void> _loadSelectedFolder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFolder = prefs.getString('selectedFolder');
    });
  }

  Future<void> _init() async {
    await _audioPlayer.setLoopMode(LoopMode.all);
    await _audioPlayer.setAudioSource(_playlist);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    selectedUserNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String user = selectedFolder ?? "Username";
    final TextEditingController shareJSONController = TextEditingController();
    final _shareFormKey = GlobalKey<FormState>();
    bool _shareErrorMessage = false;

    final TextEditingController _clearJSONController = TextEditingController();
    final _clearFormKey = GlobalKey<FormState>();
    bool _clearErrorMessage = false;

    final TextEditingController createProfileController =
        TextEditingController();
    final _createFormKey = GlobalKey<FormState>();
    bool _createErrorMessage = false;

    final TextEditingController changeProfileController =
        TextEditingController();
    final _changeFormKey = GlobalKey<FormState>();
    bool _changeProfileErrorMessage = false;

    Future<void> logSeekAction(Duration newPosition) async {
      final currentTime = DateTime.now();
      final audioDuration = _audioPlayer.duration ?? Duration.zero;

      // Create a CSV row with the log data
      List<dynamic> row = [
        'seek',
        currentTime.toString(),
        newPosition.toString(),
        audioDuration.toString()
      ];

      // Convert the row to a CSV string
      String csvRow = const ListToCsvConverter().convert([row]);

      // Write the CSV string to the log file
      await writeToLogFile(selectedFolder, csvRow);
    }

    return Scaffold(
        backgroundColor: Colors.grey[850],
        // extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        drawer: Drawer(
          backgroundColor: Colors.grey[200],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/bg.jpeg'), fit: BoxFit.cover),
                    color: Color.fromARGB(255, 92, 92, 92),
                  ),
                  child: Column(
                    children: [
                      Image(
                        image: AssetImage('images/logoaims.png'),
                        height: 100,
                        width: 100,
                      ),
                      Container(
                          color: Color.fromARGB(31, 89, 85, 85),
                          child: MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(textScaleFactor: 1.0),
                            child: Text(
                              "Meditation App for AIIMS Rishikesh",
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 241, 241, 241),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  fontSize: 14),
                            ),
                          )),
                    ],
                  )),
              ListTile(
                leading: Icon(Icons.change_circle_sharp),
                title: Text(
                  'Change Profile',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Enter Password"),
                        content: Form(
                          key: _changeFormKey,
                          child: TextFormField(
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter password";
                              } else if (value != '1234') {
                                return "Incorrect Password";
                              }
                              return null;
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_changeFormKey.currentState!.validate()) {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ValueListenableBuilder<String?>(
                                        valueListenable: selectedUserNotifier,
                                        builder:
                                            (context, selectedUser, child) {
                                          return FutureBuilder<List<String>>(
                                            future: _folderNamesFuture,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                if (snapshot.hasError) {
                                                  return Text(
                                                      'Error: ${snapshot.error}');
                                                }
                                                return AlertDialog(
                                                  title: Text('Select User'),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: ListBody(
                                                      children: snapshot.data!
                                                          .map<Widget>(
                                                              (String value) {
                                                        return RadioListTile<
                                                            String>(
                                                          title: Text(value),
                                                          value: value,
                                                          groupValue:
                                                              selectedUserNotifier
                                                                  .value,
                                                          onChanged: (String?
                                                              newValue) {
                                                            setState(() {
                                                              selectedUserNotifier
                                                                      .value =
                                                                  newValue;
                                                            });
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("Cancel"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        print(selectedUser);
                                                        if (selectedUser !=
                                                            null) {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AudioPlayerPage(
                                                                selectedFolder:
                                                                    selectedUser!,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: Text("Submit"),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return CircularProgressIndicator();
                                              }
                                            },
                                          );
                                        });
                                  },
                                );
                              }
                            },
                            child: Text("Submit"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                    'Create Profile',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Enter Password"),
                            content: Form(
                              key: _createFormKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: createProfileController,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter password";
                                      } else if (value != '1234') {
                                        return "Incorrect Password";
                                      }
                                      return null;
                                    },
                                  ),
                                  Visibility(
                                    visible: _createErrorMessage,
                                    child: Text(
                                      "Incorrect Password !",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  createProfileController.clear();
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    if (_createFormKey.currentState!
                                        .validate()) {
                                      Navigator.pop(context);
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CreateProfile()));
                                      createProfileController.clear();
                                    } else {
                                      setState(() {
                                        _createErrorMessage = true;
                                      });

                                      createProfileController.clear();
                                    }
                                  },
                                  child: Text("Submit"))
                            ],
                          );
                        });
                  }),
              ListTile(
                  leading: Icon(Icons.share),
                  title: Text(
                    'Share Data',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Enter Password"),
                            content: Form(
                              key: _shareFormKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: shareJSONController,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter password";
                                      } else if (value != '1234') {
                                        return "Incorrect Password";
                                      }
                                      return null;
                                    },
                                  ),
                                  Visibility(
                                    visible: _shareErrorMessage,
                                    child: Text(
                                      "Incorrect Password !",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  shareJSONController.clear();
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    if (_shareFormKey.currentState!
                                        .validate()) {
                                      // shareJson(selectedFolder);
                                      shareCsv(selectedFolder);
                                      Navigator.pop(context);
                                      // _showChangeUser();
                                      shareJSONController.clear();
                                    } else {
                                      setState(() {
                                        _shareErrorMessage = true;
                                      });

                                      shareJSONController.clear();
                                    }
                                  },
                                  child: Text("Submit"))
                            ],
                          );
                        });
                  }),
              ListTile(
                  leading: Icon(Icons.delete),
                  title: Text(
                    'Clear Data',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Enter Password"),
                            content: Form(
                              key: _clearFormKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _clearJSONController,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter password";
                                      } else if (value != '1234') {
                                        return "Incorrect Password";
                                      }
                                      return null;
                                    },
                                  ),
                                  Visibility(
                                    visible: _clearErrorMessage,
                                    child: Text(
                                      "Incorrect Password !",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _clearJSONController.clear();
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    if (_clearFormKey.currentState!
                                        .validate()) {
                                      clearLogFile(selectedFolder);
                                      Navigator.pop(context);
                                      _clearJSONController.clear();
                                    } else {
                                      setState(() {
                                        _clearErrorMessage = true;
                                      });

                                      _clearJSONController.clear();
                                    }
                                  },
                                  child: Text("Submit"))
                            ],
                          );
                        });
                  }),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: MediaQuery(
                        data:
                            MediaQuery.of(context).copyWith(textScaleFactor: 1),
                        child: Text(
                          "Hello,",
                          // textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 50,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: MediaQuery(
                        data:
                            MediaQuery.of(context).copyWith(textScaleFactor: 1),
                        child: Text(
                          user,
                          // textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 60,
                              color: Color(0xff58c977)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Lottie.asset(
                'jsons/animation.json',
                animate: _isPlaying,
                height: 300,
                repeat: true,
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
                            timeLabelTextStyle:
                                TextStyle(color: Colors.white, fontSize: 14),
                            baseBarColor: Color.fromARGB(134, 88, 201, 118),
                            thumbColor: Colors.white,
                            progressBarColor: Color(0xff58c977),
                            progress: positionData?.position ?? Duration.zero,
                            buffered:
                                positionData?.bufferedPosition ?? Duration.zero,
                            total: positionData?.duration ?? Duration.zero,
                            onSeek: (duration) {
                              _audioPlayer.seek(duration);
                              logSeekAction(duration);
                            });
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
          ),
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

    // Create a CSV row with the log data
    List<dynamic> row = [
      action,
      currentTime.toString(),
      currentPosition.toString()
    ];

    // Convert the row to a CSV string
    String csvRow = const ListToCsvConverter().convert([row]);

    // Write the CSV string to the log file
    await writeToLogFile(selectedFolder, csvRow);
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
                color: Color(0xFF58c9b0)),
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
                color: Color(0xFF58c9b0)),
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
