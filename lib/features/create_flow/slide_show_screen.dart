import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flippy/flipper/dragFlipper.dart';
import 'package:flippy/flippy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio/just_audio.dart' as JA;
import 'package:audio_session/audio_session.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:self_learning_app/features/create_flow/data/model/flow_model.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/widgets/play_music.dart';
import 'package:video_player/video_player.dart';
import 'package:rxdart/rxdart.dart';

import '../../utilities/notificationmangae.dart';
import '../promt/bloc/promt_bloc.dart';
import '../promt/data/model/promt_model.dart';
import '../resources/resources_screen.dart';

class SlideShowScreen extends StatefulWidget {
  final List<FlowDataModel> flowList;
  final String flowName;


  const SlideShowScreen({Key? key, required this.flowList, required this.flowName}) : super(key: key);

  @override
  State<SlideShowScreen> createState() => _SlideShowScreenState();
}

class _SlideShowScreenState extends State<SlideShowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _promtModelLength = 0;
  ChewieController? _chewieController;
  bool _showResource = false;


  FlipperController controller = FlipperController(
    dragAxis: DragAxis.both,
  );
  NotificationManage notificationManage = NotificationManage();

  @override
 void initState() {
   notificationManage.setnotiValue = true;

   // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    _pageController.dispose();
    _chewieController?.dispose(); // Dispose the ChewieController
    super.dispose();
  }

  Widget buildSliderIndicator(int index) {
    return Container(
      width: 10,
      height: 10,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == _currentPage ? Colors.blue : Colors.grey,
      ),
    );
  }

  bool isLastPage() {
    return _currentPage == widget.flowList.length - 1;
  }
  bool isFirstPage() {
    return _currentPage == 0;
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async{
        print("system back button this one");
        Navigator.pop(context, true); // Navigate back with true
        return false; // Prevent the default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(onPressed: (){
              Navigator.pop(context, true);
            }, icon: Icon(Icons.arrow_back)),
            title:  Text("${widget.flowName.toString()}")),
        body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          DragFlipper(
            /// Card 1 front
            front: FrontPageWidget(
              key: GlobalKey(),
              promtModel: widget.flowList,
              index: _currentPage,
              h: h,
              w: w,
              onView2sidePressed : (){
                controller.flipLeft();
              },
              onNextButtonPressed: () async {
                if (isLastPage()) {
                  // Handle Finish button press
                  Navigator.pop(context);
                } else {
                  //controller.flipRight();

                  setState(() {
                    _currentPage += 1;
                  });
/*
                      _currentPage += 1;
*/


                }
              },
              onPrevButtonPressed: () async {
                if (isFirstPage()) {
                  // Handle Finish button press
                  Navigator.pop(context);
                } else {

                  setState(() {
                    _currentPage -= 1;
                  });
/*
                      _currentPage += 1;
*/


                }
              },

            ), //required
            ///card 2 back
            back:BackPageWidget(
              key: GlobalKey(),
              promtModel: widget.flowList,
              index: _currentPage,
              onView1sidePressed: () {
                controller.flipRight();
              },
              h: h,
              w: h,
            ),
            controller: controller, //required
            height: context.screenHeight / 2,
            width: context.screenWidth,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            backgroundColor: Colors.transparent,
          ),
          Flexible(child: Text(widget.flowName,)),
        ],
      ),
      ),
    );
  }

}

class FrontPageWidget extends StatefulWidget {

  final List<FlowDataModel> promtModel;
  final int index;
  final Function() onView2sidePressed;
  final double h;
  final double w;
  final Function() onNextButtonPressed;
  final Function() onPrevButtonPressed;
  FrontPageWidget({super.key, required this.promtModel, required this.index, required this.h, required this.w, required this.onView2sidePressed, required this.onNextButtonPressed, required this.onPrevButtonPressed,});

  @override
  State<FrontPageWidget> createState() => _FrontPageWidgetState();
}

class _FrontPageWidgetState extends State<FrontPageWidget> {
  //ChewieController? _chewieController;
  FlickManager? flickManager;

  AudioPlayer? _audioPlayer;
  bool _isLoading = true;

  void _disposeFlickManager() {
    flickManager?.flickVideoManager?.videoPlayerController?.dispose();
    flickManager?.dispose();
    flickManager = null;
  }
  @override
  void initState() {

    // TODO: implement initState
    print('try');
    super.initState();
    _initializeMedia();
  }
  Future<void> _initializeMedia() async {
    final mediaType = getMediaType(widget.promtModel[widget.index].side1Content);

    if (mediaType == 'video') {
      _disposeFlickManager();
      await _initVideo();
    } else if (mediaType == 'audio') {
      await initAudio();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _initVideo() async {
    try {
       flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(
          'https://backend.savant.app/public/video/${widget.promtModel[widget.index].side1Content}',
        ),
      );
      await flickManager?.flickVideoManager?.videoPlayerController?.initialize();
    } catch (e) {
      print("Error initializing video: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> initAudio() async {
    _audioPlayer = AudioPlayer();
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _audioPlayer?.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });
    // Try to load audio from a source and catch any errors.
    try {
      // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
      await _audioPlayer?.setAudioSource(AudioSource.uri(Uri.parse("https://backend.savant.app/public/audio/${widget.promtModel![widget.index].side1Content}")));
    } catch (e) {
      print("Error loading audio source: $e");
    }
    setState(() { _isLoading = false;});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Colors.grey.shade200,
      margin: EdgeInsets.all(10),
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        child: SizedBox(
          //height: context.screenHeight / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  widget.promtModel[widget.index].promptName.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19), overflow: TextOverflow.ellipsis,),
              Expanded(
                 // https://backend.savant.app/public/image/${widget.content}
                child:
                    _isLoading
                        ? Center(child: CircularProgressIndicator(),)
                        : widget.promtModel![widget.index].side1Content.contains("jpg") ||
                        widget.promtModel![widget.index].side1Content.contains("png") ||
                        widget.promtModel![widget.index].side1Content.contains("jpeg")
                        ? Center(child: CachedNetworkImage(
                      imageUrl: "https://backend.savant.app/public/image/${widget.promtModel![widget.index].side1Content}",
                      fit: BoxFit.fitHeight,
                      height: widget.h * 0.2,
                      width: widget.w / 1.5,
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          Center(
                            child: CircularProgressIndicator(
                              value: downloadProgress
                                  .progress,
                            ),
                          ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),),)
                        : getMediaType(widget.promtModel![widget.index].side1Content) == 'video'
                        ? Column(

                      children: [
                        Spacer(),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4.0)
                          ),
                          height: widget.h * 0.2,
                          width: widget.w*0.6,
                          child: FlickVideoPlayer(
                            flickVideoWithControls: FlickVideoWithControls(
                              videoFit: BoxFit.fitHeight,
                              controls: const FlickPortraitControls(),

                            ),
                            flickManager: flickManager!,

                          ),// Return an empty widget if _chewieController is null
                        ),
                        Spacer(),
                      ],
                    )
                        : getMediaType(widget.promtModel![widget.index].side1Content) == 'audio'
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Display play/pause button and volume/speed sliders.
                        ControlButtons(_audioPlayer!),
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
                                onSeek: (newPosition) {_audioPlayer?.seek(newPosition);},
                              ),
                            );
                          },
                        ),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: Text(widget.promtModel![widget.index].side1Content, style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),)),
                      ],
                    ),


              ),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: context.screenWidth * 0.2,
                      child: widget.index == 0?
                      null:
                      TextButton(
                          onPressed:(){
                            flickManager?.flickVideoManager?.videoPlayerController?.dispose();

                            widget.onPrevButtonPressed();},
                          style: const ButtonStyle(
                              backgroundColor:
                              MaterialStatePropertyAll(
                                  Colors
                                      .green)),
                          child: const Text(
                              "Previous\n prompt",
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                  Colors.white)))),
                  SizedBox(
                      width: context.screenWidth * 0.2,
                      child: widget.index == widget.promtModel.length-1?
                      null:
                      TextButton(
                          onPressed: (){
                            flickManager?.flickVideoManager?.videoPlayerController?.dispose();

                            widget.onNextButtonPressed();},
                          style: const ButtonStyle(
                              backgroundColor:
                              MaterialStatePropertyAll(
                                  Colors
                                      .green)),
                          child: const Text(
                              "Next prompt",
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                  Colors.white)))),


                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  SizedBox(
                    width: context.screenWidth * 0.2,
                    child: TextButton(
                      onPressed: (){
                        flickManager?.flickVideoManager?.videoPlayerController?.dispose();

                        widget.onView2sidePressed();},
                      child: Text('Show Answer',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white)),
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStatePropertyAll(
                            Colors.blueAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _audioPlayer!.positionStream,
          _audioPlayer!.bufferedPositionStream,
          _audioPlayer!.durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  void dispose() {
    flickManager?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }


}


class BackPageWidget extends StatefulWidget {

  final List<FlowDataModel> promtModel;
  final int index;
  final Function() onView1sidePressed;
  final double h;
  final double w;
  const BackPageWidget({super.key, required this.promtModel, required this.index, required this.onView1sidePressed, required this.h, required this.w});

  @override
  State<BackPageWidget> createState() => _BackPageWidgetState();
}

class _BackPageWidgetState extends State<BackPageWidget> {

  //ChewieController? _chewieController;
  FlickManager? flickManager;

  AudioPlayer? _audioPlayer;
  bool _isLoading = true;
  void _disposeFlickManager() {
    flickManager?.flickVideoManager?.videoPlayerController?.dispose();
    flickManager?.dispose();
    flickManager = null;
  }

  @override
  void initState() {
    // TODO: implement initState
    if(getMediaType(widget.promtModel![widget.index].side2Content) == 'video'){
      print("in flow we check video side 2 ");
      _disposeFlickManager();
      print('This: '+ 'https://backend.savant.app/public/video/${widget.promtModel![widget.index].side2Content}');
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network('https://backend.savant.app/public/video/${widget.promtModel![widget.index].side2Content}'),
      );
      setState(() {
        _isLoading = false;
      });
    }else if(getMediaType(widget.promtModel![widget.index].side2Content) == 'audio'){

      _audioPlayer = AudioPlayer();
      initAudio();
    }else{
      setState(() {
        _isLoading = false;
      });
    }
    super.initState();
  }
  Future<void> initAudio() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _audioPlayer?.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });
    // Try to load audio from a source and catch any errors.
    try {
      // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
      await _audioPlayer?.setAudioSource(AudioSource.uri(Uri.parse("https://backend.savant.app/public/audio/${widget.promtModel![widget.index].side2Content}")));
    } catch (e) {
      print("Error loading audio source: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Colors.grey.shade200,
      margin: EdgeInsets.all(10),
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
                widget.promtModel![widget.index].promptName.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(),)
                  : widget.promtModel![widget.index].side2Content.contains("jpg") ||
                  widget.promtModel![widget.index].side2Content.contains("png") ||
                  widget.promtModel![widget.index].side2Content.contains("jpeg")
                  ? Center(child: CachedNetworkImage(
                imageUrl:
                "https://backend.savant.app/public/image/${widget.promtModel![widget.index].side2Content}",
                fit: BoxFit.fitHeight,
                height: widget.h * 0.2,
                width: widget.w / 1.5,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(
                      child: CircularProgressIndicator(
                        value: downloadProgress
                            .progress,
                      ),
                    ),
                errorWidget: (context, url, error) => const Icon(Icons.error),),)
                  : getMediaType(widget.promtModel![widget.index].side2Content) == 'video'
                  ? Column(
                children: [
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4.0)
                    ),
                    height: widget.h * 0.2,
                    child: FlickVideoPlayer(
                      flickVideoWithControls: FlickVideoWithControls(
                        videoFit: BoxFit.fitHeight,
                        controls: FlickPortraitControls(),
                      ),
                      flickManager: flickManager!,
                    ),// Return an empty widget if _chewieController is null
                  ),
                  Spacer(),
                ],
              )
                  : getMediaType(widget.promtModel![widget.index].side2Content) == 'audio'
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display play/pause button and volume/speed sliders.
                  ControlButtons(_audioPlayer!),
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
                          onSeek: (newPosition) {_audioPlayer?.seek(newPosition);},
                        ),
                      );
                    },
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Text(widget.promtModel![widget.index].side2Content, style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () {
                      flickManager?.flickVideoManager?.videoPlayerController?.dispose();
                      widget.onView1sidePressed();
                    },
                    child: Text('Show Question'),
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStatePropertyAll(
                            Colors.blueAccent))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _audioPlayer!.positionStream,
          _audioPlayer!.bufferedPositionStream,
          _audioPlayer!.durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));


  @override
  void dispose() {
    //_chewieController?.dispose();
    //flickManager?.dispose();
    //_audioPlayer?.dispose();
    super.dispose();
  }

}



class PositionData {
  Duration _position;
  Duration _bufferedPosition;
  Duration _duration;

  PositionData(this._position, this._bufferedPosition, this._duration);

  Duration get duration => _duration;

  Duration get bufferedPosition => _bufferedPosition;

  Duration get position => _position;
}


/// Displays the play/pause button and volume/speed sliders.

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40.0)),
          ),
          child: StreamBuilder<JA.PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;

              if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    width: 48.0,
                    height: 48.0,
                    child: const CircularProgressIndicator(),
                  ),
                );
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(Icons.play_arrow),
                  iconSize: 40.0,
                  onPressed: player.play,
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(Icons.pause),
                  iconSize: 40.0,
                  onPressed: player.pause,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.replay),
                  iconSize: 40.0,
                  onPressed: () => player.seek(Duration.zero,
                      index: player.effectiveIndices!.first),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}