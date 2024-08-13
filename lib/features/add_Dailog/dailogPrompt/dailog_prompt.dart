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

import '../../resources/maincategory_resources_screen.dart';


class SlideShowScreen2 extends StatefulWidget {
  String side1type;
  String side2type;
  String promptTitle;
  String side1contentTitle;
  String side2contentTitle;
  String flowName;




   SlideShowScreen2({Key? key, required this.side1type, required this.side2type,

   required this.promptTitle, required this.side1contentTitle, required this.side2contentTitle, required this.flowName}) : super(key: key);

  @override
  State<SlideShowScreen2> createState() => _SlideShowScreen2State();
}

class _SlideShowScreen2State extends State<SlideShowScreen2> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _promtModelLength = 0;
  bool _showResource = false;


  FlipperController controller = FlipperController(
    dragAxis: DragAxis.both,
  );

  @override
  void dispose() {
    _pageController.dispose();
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
    return _currentPage ==1;
  }
  bool isFirstPage() {
    return _currentPage == 0;
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title:  Text("${widget.flowName}")),
      body: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DragFlipper(
              /// Card 1 front
              front: FrontPageWidget(
                side1type: widget.side1type,
                side1Content: widget.side1contentTitle,
                promptName: widget.promptTitle,
                key: GlobalKey(),
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
                    //controller.flipRight();
                    // controller.flipRight();
                    // await Future.delayed(Duration(milliseconds: 500));
                    //
                    // controller.flipRight();
                    // await Future.delayed(Duration(milliseconds: 500));

                    setState(() {
                      _currentPage -= 1;
                    });
/*
                    _currentPage += 1;
*/


                  }
                },
                onViewResourcePressed: () {
                  //BlocProvider.of<PromtBloc>(context).add(ViewResourceEvent(showResource: true));
                  controller.flipRight();
                  setState(() {
                    _showResource = true;
                  });
                },
              ), //required
              ///card 2 back
              back: !_showResource? BackPageWidget(
                key: GlobalKey(),
                promptName: widget.promptTitle,
                side2Content: widget.side2contentTitle,
                index: _currentPage,
                onView1sidePressed: () {
                  controller.flipRight();
                },
                h: h,
                w: h,
              ) : BackPage2Widget(
                content: "widget.flowList[_currentPage].resourceContent",
                title: "widget.flowList[_currentPage].resourceTitle",
                mediaType: "",
                onView1sidePressed: () {
                  controller.flipLeft();
                  setState(() {
                    _showResource = false;
                  }); },
                h: h,
                w: w,
              ), //required
              controller: controller, //required
              height: context.screenHeight / 2,
              width: context.screenWidth,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              backgroundColor: Colors.transparent,
            ),
            Flexible(child: Text("dddd",)),
          ],
        ),
      ),
    );
  }

}

class PromtMediaPlayScreen extends StatefulWidget {
  const PromtMediaPlayScreen({Key? key}) : super(key: key);

  @override
  State<PromtMediaPlayScreen> createState() => _PromtMediaPlayScreenState();
}

class _PromtMediaPlayScreenState extends State<PromtMediaPlayScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


class FrontPageWidget extends StatefulWidget {
  String side1type;
  String side1Content;
  String promptName;
  final int index;
  final Function() onView2sidePressed;
  final double h;
  final double w;
  final Function() onNextButtonPressed;
  final Function() onPrevButtonPressed;
  final Function() onViewResourcePressed;
  FrontPageWidget({super.key, required this.side1type, required this.index,
    required this.h, required this.w, required this.onView2sidePressed,
    required this.onNextButtonPressed, required this.onViewResourcePressed,
    required this.onPrevButtonPressed,
    required this.side1Content, required this.promptName
  });

  @override
  State<FrontPageWidget> createState() => _FrontPageWidgetState();
}

class _FrontPageWidgetState extends State<FrontPageWidget> {
  //ChewieController? _chewieController;
  FlickManager? flickManager;

  AudioPlayer? _audioPlayer;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    print('try');
    if(getMediaType(widget.side1Content) == 'video'){
      print('try1');
      initVideo();
    }else if(getMediaType(widget.side1Content) == 'audio'){
      print('try2');
      initAudio();
    }else{
      print('try3');
      setState(() {
        _isLoading = false;
      });
    }
    super.initState();
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
      await _audioPlayer?.setAudioSource(AudioSource.uri(Uri.parse("https://backend.savant.app/public/audio/${widget.side1Content}")));
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
                widget.promptName.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19), overflow: TextOverflow.ellipsis,),
              Expanded(
                child:
                _isLoading
                    ? Center(child: CircularProgressIndicator(),)
                    : widget.side1Content.contains("jpg") ||
                    widget.side1Content.contains("png") ||
                    widget.side1Content.contains("jpeg")
                    ? Center(child: CachedNetworkImage(
                  imageUrl: "https://backend.savant.app/public/image/${widget.side1Content}",
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
                    : getMediaType(widget.side1Content) == 'video'
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
                    : getMediaType(widget.side1Content) == 'audio'
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
                    Flexible(child: Text(widget.side1Content, style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),)),
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
                          onPressed: widget.onPrevButtonPressed,
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
                      child: widget.index == 0?
                      null:
                      TextButton(
                          onPressed: widget.onNextButtonPressed,
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
                MainAxisAlignment.center,
                children: [



                  SizedBox(
                    width: context.screenWidth * 0.2,
                    child: TextButton(
                      onPressed: widget.onView2sidePressed,
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

  ChewieController _createChewieController(String videoUrl) {
    final videoPlayerController = VideoPlayerController.network(videoUrl);
    ChewieController chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoInitialize: true,
      autoPlay: true,
      looping: false,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    return chewieController!;
  }

  @override
  void dispose() {
    //_chewieController?.dispose();
    //flickManager?.dispose();
    //_audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> initVideo() async{
    print('https://backend.savant.app/public/video/${widget.side1Content}');
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network('https://backend.savant.app/public/video/${widget.side1Content}'),
    );
    setState(() { _isLoading = false;});
  }

}


class BackPageWidget extends StatefulWidget {
  String side2Content;
  String promptName;
  final int index;
  final Function() onView1sidePressed;
  final double h;
  final double w;
   BackPageWidget({super.key,
    required this.index, required this.onView1sidePressed,
    required this.h, required this.w,
    required this.side2Content,
    required this.promptName,
  });

  @override
  State<BackPageWidget> createState() => _BackPageWidgetState();
}

class _BackPageWidgetState extends State<BackPageWidget> {

  //ChewieController? _chewieController;
  FlickManager? flickManager;

  AudioPlayer? _audioPlayer;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    if(getMediaType(widget.side2Content) == 'video'){
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network('https://backend.savant.app/public/video/${widget.side2Content}'),
      );
      setState(() {
        _isLoading = false;
      });
    }else if(getMediaType(widget.side2Content) == 'audio'){
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
      await _audioPlayer?.setAudioSource(AudioSource.uri(Uri.parse("https://backend.savant.app/public/audio/${widget.side2Content}")));
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
                widget.promptName.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(),)
                  : widget.side2Content.contains("jpg") ||
                  widget.side2Content.contains("png") ||
                  widget.side2Content.contains("jpeg")
                  ? Center(child: CachedNetworkImage(
                imageUrl:
                "https://backend.savant.app/public/image/${widget.side2Content}",
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
                  : getMediaType(widget.side2Content) == 'video'
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
                  : getMediaType(widget.side2Content) == 'audio'
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
                  Flexible(child: Text(widget.side2Content, style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: widget.onView1sidePressed,
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




class BackPage2Widget extends StatefulWidget {

  final String content;
  final Function() onView1sidePressed;
  final double h;
  final double w;
  final String mediaType;
  final String title;

  const BackPage2Widget({super.key, required this.content, required this.onView1sidePressed, required this.mediaType, required this.h, required this.w, required this.title});

  @override
  State<BackPage2Widget> createState() => _BackPage2WidgetState();
}

class _BackPage2WidgetState extends State<BackPage2Widget> {

  // ChewieController? _chewieController;
  AudioPlayer? _audioPlayer;
  FlickManager? flickManager;

  Future<void> _initializeVideoPlayer() async {

    //final videoPlayerController = VideoPlayerController.file(File(videoPath));
    //await videoPlayerController.initialize();

    flickManager = FlickManager(
      videoPlayerController:
      VideoPlayerController.network("https://backend.savant.app/public/video/${widget.content}"),
    );
    /*_chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
      // Other ChewieController configurations...
    );*/

    /*setState(() {
      _isPlaying = true;
    });*/
  }




  @override
  void initState() {
    // TODO: implement initState
    if(getMediaType(widget.content) == 'video'){
      _initializeVideoPlayer();
    }else if(getMediaType(widget.content) == 'audio'){
      _audioPlayer = AudioPlayer();
      initAudio();
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
      await _audioPlayer?.setAudioSource(AudioSource.uri(Uri.parse("https://backend.savant.app/public/audio/${widget.content}")));
    } catch (e) {
      print("Error loading audio source: $e");
    }
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
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Text("FlickVideoPlayer"),
              Expanded(
                child: Column(
                  children: [
                    if(flickManager == null) Spacer(),
                    widget.content.contains('.jpeg') ||
                        widget.content.contains('.jpg') ||
                        widget.content.contains('.png') ||
                        widget.content.contains('.gif')
                        ? Expanded(child: CachedNetworkImage(
                      imageUrl:
                      'https://backend.savant.app/public/image/${widget.content}',
                      fit: BoxFit.fitHeight,
                      //height: h * 0.,
                      //width: 50,
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                      errorWidget: (context, url, error) => Icon(Icons.error),),)
                        : getMediaType(widget.content) == 'video'
                        ? Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4.0)
                        ),
                        height: widget.h * 0.3,
                        child: flickManager != null
                            ? FlickVideoPlayer(
                            flickVideoWithControls: FlickVideoWithControls(
                              videoFit: BoxFit.fitHeight,
                              controls: FlickPortraitControls(),
                            ),
                            flickManager: flickManager!):const SizedBox.shrink(), // Return an empty widget if _chewieController is null
                      ),
                    )
                        : getMediaType(widget.content) == 'audio'
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
                        : Flexible(child: Text(widget.title, style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),)),
                    if(flickManager == null) Spacer(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                      onPressed: widget.onView1sidePressed,
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

  ChewieController _createChewieController(String videoUrl) {
    final videoPlayerController = VideoPlayerController.network(videoUrl);
    ChewieController chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoInitialize: true,
      autoPlay: true,
      looping: false,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    return chewieController!;
  }

  @override
  void dispose() {
    //_chewieController?.dispose();
    //_audioPlayer?.dispose();
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _audioPlayer?.stop();
    }
  }
/*Future<void> _initializeVideoPlayer(String videoPath) async {
    if (_chewieController != null) {
      await  Future.delayed(Duration(milliseconds: 100));
      _chewieController!.dispose();
    }

    await videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
      // Other ChewieController configurations...
    );

  }*/
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
        /*IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),*/
        /*Spacer(flex: 2,),
        StreamBuilder<LoopMode>(
          stream: player.loopModeStream,
          builder: (context, snapshot) {
            final loopMode = snapshot.data ?? LoopMode.off;
            const icons = [
              Icon(Icons.repeat, color: Colors.grey),
              Icon(Icons.repeat, color: Colors.orange),
              Icon(Icons.repeat_one, color: Colors.orange),
            ];
            const cycleModes = [
              LoopMode.off,
              LoopMode.all,
              LoopMode.one,
            ];
            final index = cycleModes.indexOf(loopMode);
            return IconButton(
              icon: icons[index],
              onPressed: () {
                player.setLoopMode(cycleModes[
                (cycleModes.indexOf(loopMode) + 1) %
                    cycleModes.length]);
              },
            );
          },
        ),
        Spacer(flex: 1,),

        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: player.hasPrevious ? player.seekToPrevious : null,
          ),
        ),
        ///
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: player.hasNext ? player.seekToNext : null,
          ),
        ),
        Spacer(flex: 1,),
        StreamBuilder<bool>(
          stream: player.shuffleModeEnabledStream,
          builder: (context, snapshot) {
            final shuffleModeEnabled = snapshot.data ?? false;
            return IconButton(
              icon: shuffleModeEnabled
                  ? const Icon(Icons.shuffle, color: Colors.orange)
                  : const Icon(Icons.shuffle, color: Colors.grey),
              onPressed: () async {
                final enable = !shuffleModeEnabled;
                if (enable) {
                  await player.shuffle();
                }
                await player.setShuffleModeEnabled(enable);
              },
            );
          },
        ),
        Spacer(flex: 2,),*/
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