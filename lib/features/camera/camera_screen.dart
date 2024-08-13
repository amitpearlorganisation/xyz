// import 'dart:io';
//
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:self_learning_app/features/camera/bloc/camera_bloc.dart';
// import 'package:self_learning_app/utilities/extenstion.dart';
//
// import '../../utilities/colors.dart';
//
// late List<CameraDescription> _cameras;
//
// /// CameraApp is the Main Application.
// class CameraApp extends StatefulWidget {
//   final String rootId;
//   /// Default Constructor
//   const CameraApp({super.key, required this.rootId});
//
//   @override
//   State<CameraApp> createState() => _CameraAppState();
// }
//
// class _CameraAppState extends State<CameraApp> {
//   late CameraController controller;
//   XFile? capturedImage;
//
//   Future<void> initilizeCamera() async {
//     setState(() {});
//     _cameras = await availableCameras();
//   }
//
//   @override
//   void initState() {
//     initilizeCamera();
//     super.initState();
//     controller = CameraController(_cameras[0], ResolutionPreset.max);
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     }).catchError((Object e) {
//       if (e is CameraException) {
//         switch (e.code) {
//           case 'CameraAccessDenied':
//             // Handle access errors here.
//             break;
//           default:
//             // Handle other errors here.
//             break;
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print('build camera screen');
//     if (!controller.value.isInitialized) {
//       return Container();
//     }
//     return Scaffold(
//         body: capturedImage == null
//             ? Stack(
//                 children: [
//                   CameraPreview(controller),
//                   Positioned(
//                       bottom: context.screenHeight * 0.001,
//                       left: context.screenWidth / 3,
//                       child: GestureDetector(
//                         onTap: () async {
//                           var file = await controller.takePicture();
//                           capturedImage = file;
//                           setState(() {});
//                         },
//                         child: Icon(
//                           Icons.fiber_manual_record,
//                           color: primaryColor,
//                           size: context.screenWidth / 3.2,
//                         ),
//                       ))
//                 ],
//               )
//             : Stack(
//                 children: [
//                   Image.file(
//                     File(capturedImage!.path),
//                     height: context.screenHeight,
//                     width: context.screenWidth,
//                   ),
//                   Positioned(
//                       left: context.screenWidth / 2.8,
//                       bottom: 50,
//                       child: Row(
//                         children: [
//                           IconButton(
//                               onPressed: () {
//                                 capturedImage = null;
//                                 setState(() {});
//                               },
//                               icon: Icon(
//                                 Icons.cancel,
//                                 size: context.screenWidth * 0.15,
//                               )),
//                           SizedBox(width: context.screenWidth * 0.09),
//                           BlocBuilder<CameraBloc, CameraState>(
//                             builder: (context, state) {
//                               if (state is CameraInitial) {
//                                 return IconButton(
//                                     onPressed: () {
//                                       CameraBloc().add(UploadMediaEvent(xFile: capturedImage,rootId: widget.rootId));
//                                     },
//                                     icon: Icon(
//                                       Icons.check,
//                                       size: context.screenWidth * 0.15,
//                                     ));
//                               } else if (state is MediaUploadState) {
//                                 return CircularProgressIndicator();
//                               } else if (state is MediaUploadedSucessfully) {
//                                 context.showSnackBar(const SnackBar(
//                                     content:
//                                         Text('Image Uploaded Successfully')));
//                               }
//                               return SizedBox();
//                             },
//                           )
//                         ],
//                       ))
//                 ],
//               ));
//   }
// }
