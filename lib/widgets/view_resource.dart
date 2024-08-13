import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:just_audio/just_audio.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

class ViewResource extends StatefulWidget {
  final String content;
  final String title;

  const ViewResource({super.key, required this.content, required this.title});

  @override
  State<ViewResource> createState() => _ViewResourceState();
}

class _ViewResourceState extends State<ViewResource> {
  FlickManager? _flickManager;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    print("what is the content ${widget.content}");
    print("get content type = ${getFileType(widget.content)}");

    if (getFileType(widget.content) == 'Video') {
      _flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network('https://backend.savant.app/public/video/${widget.content}'),
      );
    } else if (getFileType(widget.content) == 'Audio') {
      print("inside the audio part");
      _initializeAudioPlayer();
    }
  }

  @override
  void dispose() {
    _flickManager?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeAudioPlayer() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _audioPlayer.setUrl("https://backend.savant.app/public/audio/${widget.content}");
      _audioDuration = _audioPlayer.duration ?? Duration.zero;
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _audioPosition = position;
        });
      });
      _audioPlayer.playbackEventStream.listen((event) {
        setState(() {
          _isPlaying = _audioPlayer.playing;
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  String getFileType(String format) {
    List<String> photoFormats = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];
    List<String> videoFormats = ['.mp4', '.mov', '.avi', '.mkv'];
    List<String> audioFormats = ['.mp3', '.wav', '.ogg', '.m4a'];

    String lowerFormat = format.toLowerCase();

    for (String photoFormat in photoFormats) {
      if (lowerFormat.contains(photoFormat)) {
        return 'Photo';
      }
    }

    for (String videoFormat in videoFormats) {
      if (lowerFormat.contains(videoFormat)) {
        return 'Video';
      }
    }

    for (String audioFormat in audioFormats) {
      if (lowerFormat.contains(audioFormat)) {
        return 'Audio';
      }
    }

    return 'Unknown'; // Return 'Unknown' if no matching format is found.





  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: getFileType(widget.content) == 'Photo'
            ? CachedNetworkImage(
          imageUrl: "https://backend.savant.app/public/image/${widget.content}",
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
          imageBuilder: (context, imageProvider) => PhotoView(
            imageProvider: imageProvider,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        )
            : getFileType(widget.content) == 'Video'
            ? FlickVideoPlayer(
          flickVideoWithControls: FlickVideoWithControls(
            videoFit: BoxFit.contain,
            controls: FlickPortraitControls(),
          ),
          flickManager: _flickManager!,
        )
            : getFileType(widget.content) == "Audio"
            ? Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                CircularProgressIndicator()
              else
                BlurryContainer(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  color: Colors.white,
                  elevation: 5,
                  borderRadius: BorderRadius.circular(90),
                  child: IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () async {
                      if (_isPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.play();
                      }
                    },
                  ),
                ),
              StreamBuilder<Duration>(
                stream: _audioPlayer.durationStream.map((duration) => duration ?? Duration.zero),
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: _audioPlayer.positionStream.map((position) => position ?? Duration.zero),
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      return Slider(
                        value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
                        min: 0.0,
                        max: duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          final newPosition = Duration(milliseconds: value.toInt());
                          _audioPlayer.seek(newPosition);
                        },
                      );
                    },
                  );
                },
              ),
              Text("${formatDuration(_audioDuration)}"),
            ],
          ),
        )
            : Center(
          child: Container(
            color: Colors.white,
            width: double.maxFinite,
            height: double.maxFinite,
            child: Center(
              child: Text(
                widget.content,
                style: TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
