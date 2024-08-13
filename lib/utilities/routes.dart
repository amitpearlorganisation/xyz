// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:self_learning_app/features/dashboard/dashboard_screen.dart';
// import 'package:self_learning_app/promt/bloc/promt_bloc.dart';
// import 'package:self_learning_app/widgets/play_music.dart';
// import 'package:video_player/video_player.dart';
//
// import '../widgets/video_from_url.dart';
//
// class PromtsScreen extends StatefulWidget {
//   final String? mediaType;
//   final String promtId;
//   final String? content;
//
//   const PromtsScreen({Key? key, required this.promtId, this.mediaType, this.content})
//       : super(key: key);
//
//   @override
//   State<PromtsScreen> createState() => _PromtsScreenState();
// }
//
// class _PromtsScreenState extends State<PromtsScreen> {
//   final PromtBloc promtBloc = PromtBloc();
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   int _promtModelLength = 0;
//   ChewieController? _chewieController;
//
//   @override
//   void initState() {
//     promtBloc.add(LoadPromtEvent(promtId: widget.promtId));
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _chewieController?.dispose(); // Dispose the ChewieController
//     super.dispose();
//   }
//
//   Widget buildSliderIndicator(int index) {
//     return Container(
//       width: 10,
//       height: 10,
//       margin: EdgeInsets.symmetric(horizontal: 4),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: index == _currentPage ? Colors.blue : Colors.grey,
//       ),
//     );
//   }
//
//   bool isLastPage() {
//     return _currentPage == _promtModelLength - 1;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var h = MediaQuery.of(context).size.height;
//     var w = MediaQuery.of(context).size.width;
//     return BlocProvider(
//       create: (context) => promtBloc,
//       child: Scaffold(
//         appBar: AppBar(title: const Text('Prompts')),
//         body: Scaffold(
//           bottomSheet: Container(
//             height: 60,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _promtModelLength!=0?   ElevatedButton(
//                   onPressed: () {
//                     if (isLastPage()) {
//                       // Handle Finish button press
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(builder: (context) {
//                           return const DashBoardScreen();
//                         }),
//                             (route) => false,
//                       );
//                     } else {
//                       _pageController.nextPage(
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.ease,
//                       );
//                     }
//                   },
//                   child: Text(isLastPage() ? 'Finish' : 'Next'),
//                 ):const SizedBox()
//               ],
//             ),
//           ),
//           body: BlocConsumer<PromtBloc, PromtState>(
//             listener: (context, state) {
//               if(state is  PromtLoaded){
//                 setState(() {
//                   _promtModelLength= state.promtModel.length;
//                 });
//               }
//             },
//             builder: (context, state) {
//               print(state);
//               if (state is PromtLoading) {
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               } else if (state is PromtError) {
//                 return Center(
//                   child: Text(state.error!),
//                 );
//               } else if (state is PromtLoaded) {
//                 if (state.promtModel.isEmpty) {
//                   return const Center(
//                     child: Text('No prompts found'),
//                   );
//                 } else {
//                   _promtModelLength = state.promtModel.length;
//                   return Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//
//                       Expanded(
//                         child: PageView.builder(
//                           controller: _pageController,
//                           itemCount: _promtModelLength,
//                           onPageChanged: (index) {
//                             setState(() {
//                               _currentPage = index;
//                             });
//                           },
//                           itemBuilder: (context, index) {
//                             return Center(
//                                 child: Text(state.promtModel[index].name.toString()));
//                           },
//                         ),
//                       ),
//                       SizedBox(
//                         width: w,
//                         height: h * 0.3,
//                         child: widget.mediaType == 'image'
//                             ? Center(
//                           child: CachedNetworkImage(
//                             imageUrl:
//                             fit: BoxFit.fill,
//                             height: h * 0.2,
//                             width: w / 1.5,
//                             progressIndicatorBuilder:
//                                 (context, url, downloadProgress) =>
//                                 CircularProgressIndicator(
//                                   value: downloadProgress.progress,
//                                 ),
//                             errorWidget: (context, url, error) =>
//                             const Icon(Icons.error),
//                           ),
//                         )
//                             : widget.mediaType == 'audio'
//                             ? AudioPlayerPage(
//                           audioUrl:
//                         )
//                             : widget.mediaType == 'video'
//                             ? Chewie(
//                           controller: _createChewieController(
//                           ),
//                         )
//                             : Text(widget.content.toString()),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: List.generate(_promtModelLength, (index) {
//                             return buildSliderIndicator(index);
//                           }),
//                         ),
//                       ),
//                     ],
//                   );
//                 }
//               }
//               return const SizedBox();
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   ChewieController _createChewieController(String videoUrl) {
//     final videoPlayerController = VideoPlayerController.network(videoUrl);
//     _chewieController = ChewieController(
//       videoPlayerController: videoPlayerController,
//       autoInitialize: true,
//       autoPlay: true,
//       looping: false,
//       errorBuilder: (context, errorMessage) {
//         return Center(
//           child: Text(
//             errorMessage,
//             style: const TextStyle(color: Colors.white),
//           ),
//         );
//       },
//     );
//     return _chewieController!;
//   }
// }
//
// class PromtMediaPlayScreen extends StatefulWidget {
//   const PromtMediaPlayScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PromtMediaPlayScreen> createState() => _PromtMediaPlayScreenState();
// }
//
// class _PromtMediaPlayScreenState extends State<PromtMediaPlayScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
