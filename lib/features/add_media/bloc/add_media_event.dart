part of 'add_media_bloc.dart';

@immutable
abstract class AddMediaEvent {}

class ImagePickEvent extends AddMediaEvent{

  final String? image;
  ImagePickEvent({this.image});
}

class AudioPickEvent extends AddMediaEvent{
  final String ? audio;
  AudioPickEvent({this.audio});

}

class VideoPickEvent extends AddMediaEvent{
  final String? video;
  VideoPickEvent({this.video});
}

class TextPickEvent extends AddMediaEvent{
  final String? title;
  TextPickEvent({this.title});
}
class RemoveMedia extends AddMediaEvent{}

class GetUploadPercentage extends AddMediaEvent{}

class SubmitButtonEvent extends AddMediaEvent{
  final int  whichResources;
  final String? resourcesId;
  final String? rootId;
  final String? title;
  final int MediaType;

  SubmitButtonEvent( {this.rootId,this.title,required this.whichResources,this.resourcesId,required this.MediaType});
}