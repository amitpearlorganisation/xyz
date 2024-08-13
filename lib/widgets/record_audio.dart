import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'dart:io';


class AudioRecordingScreen extends StatefulWidget {
  @override
  _AudioRecordingScreenState createState() => _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  StreamController<int> streamController= StreamController();
  bool _isRecording = false;
  bool _isPlaying = false;

  final recorder = Record();



  Future<void> startRecording() async {
    await Permission.microphone.request();
    setState(() {
      _isRecording = true;
    });
    await recorder.start(
      path: 'aFullPath/myFile.m4a',
      encoder: AudioEncoder.aacLc, // by default
      bitRate: 128000, // by default
      samplingRate: 44100, // by default
    );
  }


  Future<void> stopRecording() async {
    setState(() {
      _isRecording = false;
    });
    final path = await recorder.stop();
    final audioFile = File(path!);
    print ('Recorded audio: $audioFile');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recording'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRecordButton(),
            // StreamBuilder<RecordingDisposition>(
            //     stream: recorder.onProgress,
            //     builder: (context, snapshot) {
            //       final duration = snapshot.hasData
            //           ? snapshot.data!.duration
            //           : Duration.zero;
            //       String twoDigits(int n) => n.toString().padLeft(2, '0');
            //
            //       final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
            //       final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
            //
            //       return Text(
            //         '$twoDigitMinutes:$twoDigitSeconds',
            //         style: const TextStyle(
            //           fontSize: 80,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       );
            //
            //     }),
            _buildPlayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return ElevatedButton(
      onPressed: _isRecording ? stopRecording : startRecording,
      child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
    );
  }


  Widget _buildPlayButton() {
    return ElevatedButton(
      onPressed: _isPlaying ? stopRecording : startRecording,
      child: Text(_isPlaying ? 'Stop Playing' : 'Start Playing'),
    );
  }
}

