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
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/widgets/play_music.dart';
import 'package:video_player/video_player.dart';
import 'package:rxdart/rxdart.dart';

import '../promt/bloc/promt_bloc.dart';
import '../promt/data/model/promt_model.dart';
import '../resources/resources_screen.dart';

class StartFlowScreen extends StatefulWidget {
  final String? mediaType;
  final String promtId;
  final String? content;
  String? Restitle;

   StartFlowScreen({Key? key, required this.mediaType, required this.promtId, required this.content, required this.Restitle}) : super(key: key);

  @override
  State<StartFlowScreen> createState() => _StartFlowScreenState();
}

class _StartFlowScreenState extends State<StartFlowScreen> {
  //final PromtBloc promtBloc = PromtBloc();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _promtModelLength = 0;
  ChewieController? _chewieController;
  bool _showResource = false;

  @override
  void initState() {
    //promtBloc.add(LoadPromtEvent(promtId: widget.promtId));
    super.initState();
  }

  FlipperController controller = FlipperController(
    dragAxis: DragAxis.both,
  );

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
    return _currentPage == _promtModelLength - 1;
  }
  FlickManager? flickManager;

  void _disposeFlickManager() {
    flickManager?.flickVideoManager?.videoPlayerController?.dispose();
    flickManager?.dispose();
    flickManager = null;
  }
  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Prompts'),
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _disposeFlickManager();
              Navigator.pop(context, true);
            },
          )
      ),
      body: Scaffold(
        body: BlocConsumer<PromtBloc, PromtState>(
          listener: (context, state) {
            if (state is PromtLoaded) {
              setState(() {
                _promtModelLength = state.promtModel!.length;
              });
            }
          },
          builder: (context, state) {
            print(state);
            if (state is PromtLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is PromtError) {
              return Center(
                child: Text(state.error!),
              );
            } else if (state is PromtLoaded) {
              if (state.promtModel!.isEmpty) {
                return const Center(
                  child: Text('No prompts found'),
                );
              } else {
                _promtModelLength = state.promtModel!.length;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DragFlipper(
                      /// Card 1 front
                      front: FrontPageWidget(
                        key: GlobalKey(),
                        promtModel: state.promtModel!,
                        index: _currentPage,
                        h: h,
                        w: w,
                        onView2sidePressed : (){
                          controller.flipLeft();
                        },
                        onNextButtonPressed: () {
                          if (isLastPage()) {
                            // Handle Finish button press
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              _currentPage += 1;
                            });
                          }
                        },
                        onViewResourcePressed: () {
                          BlocProvider.of<PromtBloc>(context).add(ViewResourceEvent(showResource: true));
                          controller.flipRight();
                          setState(() {
                            _showResource = true;
                          });
                        },
                      ), //required
                      ///card 2 back
                      back: !_showResource? BackPageWidget(
                        key: GlobalKey(),
                        promtModel: state.promtModel!,
                        index: _currentPage,
                        onView1sidePressed: () {
                          controller.flipLeft();
                        },
                        h: h,
                        w: h,
                      ) : BackPage2Widget(
                        resTitle: widget.Restitle.toString(),
                        content: widget.content!,
                        onView1sidePressed: () {
                          controller.flipLeft();
                          setState(() {
                            _showResource = false;
                          }); },
                        mediaType: widget.mediaType!,
                        h: h,
                        w: w,
                      ), //required
                      controller: controller, //required
                      height: context.screenHeight / 2,
                      width: context.screenWidth,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      backgroundColor: Colors.white,
                    ),
                  ],
                );
              }
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

}


class FrontPageWidget extends StatefulWidget {

  final List<PromtModel> promtModel;
  final int index;
  final Function() onView2sidePressed;
  final double h;
  final double w;
  final Function() onNextButtonPressed;
  final Function() onViewResourcePressed;
  FrontPageWidget({super.key, required this.promtModel, required this.index, required this.h, required this.w, required this.onView2sidePressed, required this.onNextButtonPressed, required this.onViewResourcePressed,});

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
    if(getMediaType(widget.promtModel![widget.index].side1!.content!) == 'video'){
      print('try1');
      initVideo();
    }else if(getMediaType(widget.promtModel![widget.index].side1!.content!) == 'audio'){
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
      await _audioPlayer?.setAudioSource(AudioSource.uri(Uri.parse("https://backend.savant.app/public/audio/${widget.promtModel![widget.index].side1!.content!}")));
    } catch (e) {
      print("Error loading audio source: $e");
    }
    setState(() { _isLoading = false;});
  }

  @override
  Widget build(BuildContext context) {
    print("1print prompt model index =====${widget.index}");
    print("2print prompt model index =====${widget.promtModel.last}");
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
            children: [
              Text(
                  widget.promtModel![widget.index].name
                      .toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19)),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(),)
                    : widget.promtModel![widget.index].side1!.content!.contains("jpg") ||
                    widget.promtModel![widget.index].side1!.content!.contains("png") ||
                    widget.promtModel![widget.index].side1!.content!.contains("jpeg")
                    ? Center(child: CachedNetworkImage(
                  imageUrl: "https://backend.savant.app/public/image/${widget.promtModel![widget.index].side1!.content}",
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
                    : getMediaType(widget.promtModel![widget.index].side1!.content!) == 'video'
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
                          controls: const FlickPortraitControls(),
                        ),
                        flickManager: flickManager!,
                      ),// Return an empty widget if _chewieController is null
                    ),
                    Spacer(),
                  ],
                )
                    : getMediaType(widget.promtModel![widget.index].side1!.content!) == 'audio'
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
                    Flexible(child: Text(widget.promtModel![widget.index].side1!.content!, style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),)),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: context.screenWidth * 0.2,
                    child: TextButton(
                      onPressed: widget.onView2sidePressed,
                      child: Text('Answer',
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
                  SizedBox(
                      width: context.screenWidth * 0.2,
                      child: widget.index == widget.promtModel.length-1?
                      null:
                      ElevatedButton(
                          onPressed: widget.onNextButtonPressed,
                          style: const ButtonStyle(
                              backgroundColor:
                              MaterialStatePropertyAll(
                                  Colors
                                      .greenAccent)),
                          child: const Text(
                              "   Next\nPrompt",
                              style: TextStyle(
                                  fontSize: 11)))),
                  SizedBox(
                      width: context.screenWidth * 0.2,
                      child: TextButton(
                          onPressed: widget.onViewResourcePressed,
                          style: const ButtonStyle(
                              backgroundColor:
                              MaterialStatePropertyAll(
                                  Colors
                                      .blueAccent)),
                          child: const Text(
                              "View\n  resource",
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                  Colors.white)))),
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


  @override
  void dispose() {
    //_chewieController?.dispose();
    //flickManager?.dispose();
    //_audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> initVideo() async{
    _disposeFlickManager();
    print('https://backend.savant.app/public/video/${widget.promtModel![widget.index].side1!.content!}');
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network('https://backend.savant.app/public/video/${widget.promtModel![widget.index].side1!.content!}'),
    );
    setState(() { _isLoading = false;});
  }

}


class BackPageWidget extends StatefulWidget {

  final List<PromtModel> promtModel;
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

  void _disposeFlickManager() {
    flickManager?.flickVideoManager?.videoPlayerController?.dispose();
    flickManager?.dispose();
    flickManager = null;
  }


  AudioPlayer? _audioPlayer;
  bool _isLoading = true;

  @override
  void initState() {
    print("checking side 1---1----1 content ${widget.promtModel![widget.index].side2!.content!}");
    print("back page ${widget.promtModel![widget.index].side2!.content!}");
    if(getMediaType(widget.promtModel![widget.index].side2!.content!) == 'video'){
      _disposeFlickManager();
      print('This: '+ 'https://backend.savant.app/public/video/${widget.promtModel![widget.index].side2!.content!}');
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network('https://backend.savant.app/public/video/${widget.promtModel![widget.index].side2!.content!}'),
      );
      setState(() {
        _isLoading = false;
      });
    }else if(getMediaType(widget.promtModel![widget.index].side2!.content!) == 'audio'){
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
      await _audioPlayer?.setAudioSource(AudioSource.uri(Uri.parse("https://backend.savant.app/public/audio/${widget.promtModel![widget.index].side2!.content!}")));
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
                widget.promtModel![widget.index].name.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(),)
                  : widget.promtModel![widget.index].side2!.content!.contains("jpg") ||
                  widget.promtModel![widget.index].side2!.content!.contains("png") ||
                  widget.promtModel![widget.index].side2!.content!.contains("jpeg")
                  ? Center(child: CachedNetworkImage(
                imageUrl:
                "https://backend.savant.app/public/image/${widget.promtModel![widget.index].side2!.content}",
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
                errorWidget: (context, url, error) => const Icon(Icons.error),)
                ,)
                  : getMediaType(widget.promtModel![widget.index].side2!.content!) == 'video'
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
                  : getMediaType(widget.promtModel![widget.index].side2!.content!) == 'audio'
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
                  Flexible(child: Text(widget.promtModel![widget.index].side2!.content!, style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: widget.onView1sidePressed,
                    child: Text('Question'),
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

}




class BackPage2Widget extends StatefulWidget {

  final String content;
  final Function() onView1sidePressed;
  final double h;
  final double w;
  final String mediaType;
  String resTitle;

   BackPage2Widget({super.key, required this.content, required this.onView1sidePressed, required this.mediaType, required this.h, required this.w,
    required this.resTitle
  });

  @override
  State<BackPage2Widget> createState() => _BackPage2WidgetState();
}

class _BackPage2WidgetState extends State<BackPage2Widget> {
  //ChewieController? _chewieController;

  FlickManager? flickManager;

  void _disposeFlickManager() {
    flickManager?.flickVideoManager?.videoPlayerController?.dispose();
    flickManager?.dispose();
    flickManager = null;
  }


  AudioPlayer? _audioPlayer;
  bool _isLoading = true;

  @override
  void initState() {
    print("we are checking in resource ${widget.content!}");
    if(getMediaType(widget.content!) == 'video'){
      _disposeFlickManager();
      print('This: '+ 'https://backend.savant.app/public/video/${widget.content!}');
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network('https://backend.savant.app/public/video/${widget.content!}'),
      );
      setState(() {
        _isLoading = false;
      });
    }else if(getMediaType(widget.content!) == 'audio'){
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
      await _audioPlayer?.setAudioSource(AudioSource.uri(Uri.parse("https://backend.savant.app/public/audio/${widget.content!}")));
    } catch (e) {
      print("Error loading audio source: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }
  @override
  @override
  void dispose() {
    //_chewieController?.dispose();
    _audioPlayer?.dispose();
    _disposeFlickManager();
    super.dispose();
  }
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
                widget.resTitle,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildMediaContent(),
            ),            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: widget.onView1sidePressed,
                    child: Text('View side 1'),
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
  Widget _buildMediaContent() {
    if (widget.content!.contains("jpg") ||
        widget.content!.contains("png") ||
        widget.content!.contains("jpeg")) {
      return Center(
        child: CachedNetworkImage(
          imageUrl: "https://backend.savant.app/public/image/${widget.content}",
          fit: BoxFit.fitHeight,
          height: widget.h * 0.2,
          width: widget.w / 1.5,
          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
            child: CircularProgressIndicator(
              value: downloadProgress.progress,
            ),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    } else if (getMediaType(widget.content!) == 'video') {
      return Column(
        children: [
          Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4.0),
            ),
            height: widget.h * 0.2,
            child: flickManager != null
                ? FlickVideoPlayer(
              flickVideoWithControls: FlickVideoWithControls(
                videoFit: BoxFit.fitHeight,
                controls: FlickPortraitControls(),
              ),
              flickManager: flickManager!,
            )
                : Container(),
          ),
          Spacer(),
        ],
      );
    } else if (getMediaType(widget.content!) == 'audio') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                  onSeek: (newPosition) {
                    _audioPlayer?.seek(newPosition);
                  },
                ),
              );
            },
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              widget.content!,
              style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }
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