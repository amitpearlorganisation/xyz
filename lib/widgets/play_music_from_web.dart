// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/cupertino.dart';
//
//
// class MusicPlayerScreen extends StatefulWidget {
//   final String url;
//   MusicPlayerScreen({required this.url});
//   @override
//   _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
// }
//
// class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
//   final player = AudioPlayer();
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//
//   Future<void> loadmusic() async {
//     await player.play(UrlSource(widget.url));
//   }
//
// //
// // Future<void> playPauseMusic() async {
// //   if (player. == player.) {
// //     await audioPlayer.pause();
// //   } else {
// //     await audioPlayer.play(audioUrl, isLocal: false);
// //   }
// // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Music Player'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Now Playing:',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Example Music',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             IconButton(
//               icon: audioPlayerState == PlayerState.PLAYING
//                   ? Icon(Icons.pause)
//                   : Icon(Icons.play_arrow),
//               iconSize: 64,
//               onPressed: playPauseMusic,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     audioPlayer.dispose();
//     super.dispose();
//   }
// }