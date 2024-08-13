import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerPage extends StatefulWidget {
  final String audioUrl;
  AudioPlayerPage({required this.audioUrl});

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late AudioPlayer audioPlayer;

 // String audioUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  PlayerState playerState = PlayerState.STOPPED;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        setState(() {
          playerState = PlayerState.PLAYING;
        });
      } else if (state.processingState == ProcessingState.ready &&
          !state.playing) {
        setState(() {
          playerState = PlayerState.PAUSED;
        });
      } else if (state.processingState == ProcessingState.completed) {
        setState(() {
          playerState = PlayerState.STOPPED;
        });
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void playAudio() async {
    print(widget.audioUrl);
    await audioPlayer.setUrl(widget.audioUrl);
    await audioPlayer.play();
  }

  void pauseAudio() {
    audioPlayer.pause();
  }

  void stopAudio() {
    audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (playerState == PlayerState.STOPPED) ...[
            ElevatedButton(
              onPressed: playAudio,
              child: Text('Play'),
            ),
          ] else if (playerState == PlayerState.PLAYING) ...[
            ElevatedButton(
              onPressed: pauseAudio,
              child: Text('Pause'),
            ),
          ] else if (playerState == PlayerState.PAUSED) ...[
            ElevatedButton(
              onPressed: playAudio,
              child: Text('Resume'),
            ),
          ],
          ElevatedButton(
            onPressed: stopAudio,
            child: Text('Stop'),
          ),
        ],
      ),
    );
  }
}

enum PlayerState {
  STOPPED,
  PLAYING,
  PAUSED,
}
