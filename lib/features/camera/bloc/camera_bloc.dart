// import 'dart:async';
//
// import 'package:bloc/bloc.dart';
// import 'package:camera/camera.dart';
// import 'package:meta/meta.dart';
//
// import '../repo/upload_res_repo.dart';
//
// part 'camera_event.dart';
// part 'camera_state.dart';
//
// class CameraBloc extends Bloc<CameraEvent, CameraState> {
//   CameraBloc() : super(CameraInitial()) {
//     on<TakePhotoEvent>(_onTakePhoto);
//     on<UploadMediaEvent>(_onUploadMedia);
//   }
//
//   _onTakePhoto(TakePhotoEvent event, Emitter<CameraState> emit) {
//     print('event bloc');
//     print(event.xFile!.path);
//      emit(ImageCaputredState(xFile: event.xFile));
//   }
//
//
//   void _onUploadMedia(
//       UploadMediaEvent event, Emitter<CameraState> emit) async {
//     emit(CameraLoadingState());
//     try {
//       await UploadResRepo.uploadMediaFiles(file: event.xFile,rootId: event.rootId).then((value) {
//         emit(MediaUploadedSucessfully());
//       });
//     } catch (e) {
//       print(e);
//       emit(CameraError());
//     }
//   }
// }
