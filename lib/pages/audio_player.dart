import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class PositionData{
  const PositionData(
    this.position,
    this.bufferedPosition,
    this.duration,
  );

  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}
class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {

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
    _audioPlayer = AudioPlayer()..setAsset('audio/128-Chura Liya Hai Tumne Jo Dil Ko - Yaadon Ki Baaraat 128 Kbps.mp3');

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
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
         ),
         actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          )
         ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        height: double.infinity,
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF144771),
              Color(0xFF071A2C),
            ],
          ),
        ),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<PositionData>(
              stream: _positionDataStream, 
              builder: (context, snapshot){
                final positionData = snapshot.data;
                return ProgressBar(
                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  onSeek: _audioPlayer.seek,
                  );
              },
            ),
            Controls(audioPlayer: _audioPlayer)
          ],
        ),
      ),
    );
  }
}

  class Controls extends StatelessWidget {
    const Controls({
      super.key,
      required this.audioPlayer,
    });

    final AudioPlayer audioPlayer;
  
    @override
    Widget build(BuildContext context){
      return StreamBuilder<PlayerState>(
        stream: audioPlayer.playerStateStream,
        builder: (context, snapshot){

          final playerState = snapshot.data;
          final processingState = playerState?.processingState;
          final playing = playerState?.playing;

          if(!(playing??false)){
            return IconButton(
              onPressed: audioPlayer.play,
              iconSize: 80.0,
              color: Colors.white,
              icon: const Icon(Icons.play_arrow_rounded),
            );
          } 
          else if(processingState != ProcessingState.completed){
            return IconButton(
              onPressed: audioPlayer.pause,
              iconSize: 80.0,
              color: Colors.white,
              icon: const Icon(Icons.pause_rounded),
            );
          }

          return IconButton(
            // onPressed: () => audioPlayer.seek(Duration.zero, index: audioPlayer.effectiveIndices!.first),
            onPressed: () {  },
            iconSize: 80.0,
            color: Colors.white,
            icon: const Icon(Icons.play_arrow_rounded), 

          );

        },
      );
    }
  }