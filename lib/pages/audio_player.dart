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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
          ),
          Container(
            child: Row(
              children: [
                Padding(padding: EdgeInsets.only(left: 20)),
                SizedBox(
                  height: 40,
                  width: 100,
                  child: ElevatedButton(onPressed: (){}, child: Text("Clear")) ,
                ),
               
                Padding(padding: EdgeInsets.only(left: 120)),
                SizedBox(
                  height: 40,
                  width: 100,
                  child: ElevatedButton(onPressed: (){}, child: Text("Share")) ,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 500,
          ),
          Container(
          padding: const EdgeInsets.all(20.0),
          height: 200,
          width: double.infinity,
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

        ],
      )
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
            return Container(
              height: 85,
              width: 85,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Color(0xFF2196f3)),
              child: IconButton(
              onPressed: audioPlayer.play,
              iconSize: 65.0,
              color: Colors.white,
              icon: const Icon(Icons.play_arrow_rounded),
            ),
            );
            
          } 
          else if(processingState != ProcessingState.completed){
            return Container(
              height: 85,
              width: 85,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Color(0xFF2196f3)),
              child: IconButton(
                onPressed: audioPlayer.pause,
                iconSize: 65.0,
                color: Colors.white,
                icon: const Icon(Icons.pause_rounded),
              ),
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