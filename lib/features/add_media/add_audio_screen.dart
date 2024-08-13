import 'dart:core';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import '../../utilities/image_picker_helper.dart';
import '../flow_screen/start_flow_screen.dart';
import '../promt/promts_screen.dart';
import '../quick_add/quick_add_screen.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../resources/bloc/resources_bloc.dart';
import '../resources/resources_screen.dart';
import 'bloc/add_media_bloc.dart';
import 'dart:io';
import 'package:rxdart/rxdart.dart';
import 'package:external_path/external_path.dart';

class AddAudioScreen extends StatefulWidget {
  final int whichResources;
  final String rootId;
  final String? resourceId;
  const AddAudioScreen({Key? key, required this.rootId,this.resourceId,required this.whichResources}) : super(key: key);

  @override
  State<AddAudioScreen> createState() => _AddAudioScreenState();
}

final TextEditingController textEditingController = TextEditingController();

class _AddAudioScreenState extends State<AddAudioScreen> {
  AddMediaBloc  addMediaBloc = AddMediaBloc();
  AudioPlayer audioPlayer = AudioPlayer();
  bool _isPlaying = false;


  bool _isRecording = false;
  String _recordFilePath = '';

   final recorder = Record();




  Future<void> startRecording() async {
    print('start');
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.audio.request();
    await Permission.accessMediaLocation.request();
    await Permission.manageExternalStorage.request();
    String downloadPath;
    if (Platform.isIOS) {
      var directory = await getApplicationDocumentsDirectory();
      downloadPath = directory.path + '/';
    } else {
      downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    }
    print(downloadPath);



    setState(() {
      _isRecording = true;
    });
    await recorder.start(
      path: '$downloadPath/myFile.m4a',
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
    addMediaBloc.add(AudioPickEvent(audio: path));

    _togglePlayPause(path!);
    final audioFile = File(path);
    print ('Recorded audio: $audioFile');
  }



  Future<void> _togglePlayPause(String audioPath) async {
    if (_isPlaying) {
      await audioPlayer.pause();
    } else {
      if (audioPlayer.playerState.processingState == ProcessingState.completed) {
        await audioPlayer.seek(Duration.zero);
      }

      await audioPlayer.setFilePath(audioPath);
      await audioPlayer.pause();
    }
  }



  void _playerStateChanged() {
    audioPlayer.playerStateStream.listen((playerState) {
      setState(() {
        _isPlaying = playerState.playing;
      });
    });
  }

  Future initRecorder () async {
    final status = await Permission. microphone. request ();
    if (status != PermissionStatus. granted) {
      throw 'Microphone permission not granted';
    }

  }



  @override
  void initState() {
    initRecorder();

    textEditingController.text='';
    super.initState();
    _playerStateChanged();
  }

  @override
  void dispose() {
    super.dispose();

    audioPlayer.dispose();
    addMediaBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => addMediaBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        appBar: AppBar(title: const Text('Upload Audio')),
        body: BlocConsumer<AddMediaBloc, AddMediaInitial>(
          listener: (context, state) {
            if (state.apiState==ApiState.submitted ) {
              EasyLoading.dismiss();
              EasyLoading.showSuccess("Resource is uploaded successfully", duration: Duration(seconds: 2));
              Navigator.pop(context,true);
            }
            else if  (state.apiState==ApiState.submitting) {
              EasyLoading.show();
              context.showSnackBar(const SnackBar(duration: Duration(seconds: 1),content: Text('Adding resources...')));
            } else if  (state.apiState==ApiState.submitError) {
              EasyLoading.dismiss();
              EasyLoading.showError("Server Error");
              context.showSnackBar(const SnackBar(duration: Duration(seconds: 1),content: Text('Something went wrong.')));
            }

            if(state.selectedFilepath != ''){

            }
          },
          builder: (context, state) {
            return Column(
              children: [

                const Spacer(),
                Container(
                  padding: EdgeInsets.all(10),
                  height: context.screenHeight * 0.15,
                  width: context.screenWidth,
                  child: TextField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(80),
                    ],
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.red),
                    controller: textEditingController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                      hintText: 'Enter Title here...',
                      hintStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0))
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Spacer(flex: 3,),
                      Column(
                        children: [
                          _isRecording==true
                              ?FloatingActionButton(onPressed: () {stopRecording();},child: Icon(Icons.stop))
                              :FloatingActionButton(onPressed: () {startRecording();},child: Icon(Icons.mic)),
                          SizedBox(height: 8.0,),

                          _isRecording==true
                              ? Text('Stop Recording')
                              : Text('Start Recording'),
                        ],
                      ),
                      const Spacer(flex: 1,),
                      Text('OR'),
                      const Spacer(flex: 1,),
                      ElevatedButton(
                          onPressed: () {
                            print("audio file is here bro");
                            ImagePickerHelper.pickFile().then((value) {
                              if (value != null) {
                                addMediaBloc.add(AudioPickEvent(audio: value));
                                _togglePlayPause(value);
                              }
                            });
                          },
                        child: const Text('Choose File'),
                      ),
                      const Spacer(flex: 3,),

                    ],
                  ),
                ),



                const SizedBox(
                  height: 30,
                ),

                if(state.selectedFilepath!.isNotEmpty) Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display play/pause button and volume/speed sliders.
                    ControlButtons(audioPlayer),
                    StreamBuilder<PositionData>(
                      stream: _positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 24.0),
                          child: ProgressBar(
                            total: positionData?.duration ?? Duration.zero,
                            progress: positionData?.position ?? Duration.zero,
                            buffered: positionData?.bufferedPosition ?? Duration.zero,
                            onSeek: (newPosition) {audioPlayer?.seek(newPosition);},
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),

                ElevatedButton(
                  onPressed: () {
                    if(state.selectedFilepath!.isEmpty){
                      context.showSnackBar(const SnackBar(content: Text('Please attach file'),duration: Duration(seconds: 1),));

                    }else {
                      addMediaBloc.add(
                        SubmitButtonEvent(
                          MediaType: 2,
                          //resourcesId: widget.resourceId,
                          rootId: widget.rootId,
                          whichResources: widget.whichResources,
                          title: textEditingController.text.isEmpty
                              ? 'Untitled'
                              : textEditingController.text,
                        ),
                      );
                    }
                  },
                    child: const Text('Upload Resource')),
                Spacer(flex: 3,),
              ],
            );
          },
        ),
      ),
    );
  }


  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          audioPlayer!.positionStream,
          audioPlayer!.bufferedPositionStream,
          audioPlayer!.durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

}
// audio file