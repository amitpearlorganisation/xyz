import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:photo_view/photo_view.dart';
import 'package:self_learning_app/features/add_media/bloc/add_media_bloc.dart';
import 'package:self_learning_app/features/add_promts/add_promts_screen.dart';
import 'package:self_learning_app/features/dashboard/dashboard_screen.dart';
import 'package:self_learning_app/features/flow_screen/start_flow_screen.dart';
import 'package:self_learning_app/features/resources/bloc/resources_bloc.dart';
import 'package:self_learning_app/features/resources/subcategory_resources_screen.dart';
import 'package:self_learning_app/features/subcategory/model/resources_model.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:mime/mime.dart';
import 'package:video_player/video_player.dart';
import '../../utilities/base_client.dart';
import '../../utilities/colors.dart';
import '../../utilities/shared_pref.dart';
import '../../widgets/add_resources_screen.dart';
import '../../widgets/play_music.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../../widgets/popup_menu_widget.dart';
import '../../widgets/view_resource.dart';
import '../promt/promts_screen.dart';
import '../quick_import/repo/quick_add_repo.dart';
import '../subcate1.1/sub_category_1.1_screen.dart';
import '../subcategory/bloc/sub_cate_bloc.dart';
import '../subcategory/bloc/sub_cate_state.dart';
import 'package:http/http.dart' as http;


class MaincategoryResourcesList extends StatefulWidget {
  final String rootId;
  final String mediaType;
  final String title;
  final String level;

  const MaincategoryResourcesList(
      {Key? key, required this.rootId, required this.mediaType, required this.title, required this.level})
      : super(key: key);

  @override
  State<MaincategoryResourcesList> createState() => _MaincategoryResourcesListState();
}

class _MaincategoryResourcesListState extends State<MaincategoryResourcesList> {
  TextEditingController textEditingController = TextEditingController();
  bool _resourcesVisible = true;
  ChewieController? _chewieController;

  bool _isLoading = true;
  String? videoContent;




  @override
  void initState() {
    context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: widget.mediaType));


    super.initState();
  }


  static Future<String?> addPrompt(
      {required String resourcesId,
      required String name,
      context,
      promtId,
      required String mediatype,
      required String content}) async {
    print(name);
    print('name');
    print('addpromt');
    try {
      final token = await SharedPref().getToken();
      final res = await http.post(
          Uri.parse('https://backend.savant.app/web/prompt/'),
          body: {"name": name, "resourceId": promtId},
          headers: {'Authorization': "Bearer $token"});

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (context) {
        //     return PromtsScreen(
        //         content: content, mediaType: mediatype, promtId: promtId, fromType: Prompt.fromResource,);
        //   },
        // ));
      }
      final data = jsonDecode(res.body);
      return data[''];
    } catch (e) {}
  }
  void deleteResource({
    required String rootId,
  }) async {
    print('delete');
    http.Response res = await Api().delete(
      endPoint: 'resource/$rootId',
    );
   if (res.statusCode==200){
     context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: widget.mediaType));
     setState(() {

     });
     context.showSnackBar(const SnackBar(
         duration: Duration(seconds: 2),
         content: Text('Ressource deleted successfully')));
   }
  }
  AwesomeDialog showDeleteResource({
    required String resourceName,
    required String resourceId,
  }) {
    return AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      dialogType: DialogType.QUESTION,
      body: Center(
        child: Text(
          'Are you sure\nYou want to delete\n$resourceName',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {
        deleteResource(rootId: resourceId);
      },
      btnOkColor: Colors.red,
      closeIcon: Icon(Icons.close),
      btnCancelOnPress: () {},
      btnOkText: "Delete",
      btnOkIcon: Icons.delete,
    )..show();
  }
  AwesomeDialog updateResource({
    required String resourceId,
    required String mediaType,
    required String resourceContent,
    required String resourceTitle

}) {
    TextEditingController updateResourceController = TextEditingController(text: resourceTitle);

    return AwesomeDialog(
        context: context,
        animType: AnimType.BOTTOMSLIDE,
        dialogType: DialogType.INFO_REVERSED,
        body: Column(
          children:[
            Text("Update Resource", style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.w500),),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.grey, width: 1.5)
              ),
              child: TextFormField(
                controller: updateResourceController,
                decoration: InputDecoration(
                    border: InputBorder.none
                ),
              ),
            ),
          ]

        ),
        title: 'This is Ignored',
        desc: 'This is also Ignored',
        btnOkOnPress: () async{
       await  QuickImportRepo.updateResources(rootId: widget.rootId!,resourceId: resourceId ,
              mediaType: mediaType, resourceTitle: updateResourceController.text,
              resourceContent: resourceContent );
         setState(() {
           context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: widget.mediaType));

         });
        },
        btnOkColor: Colors.green.shade300,
        closeIcon: Icon(Icons.close),
        btnCancelOnPress: () {},
        btnOkText: "Update",
        btnOkIcon: Icons.update)
      ..show();
  }
  @override
  Widget build(BuildContext context) {
    print("checking category id ${widget.rootId}");

    return Scaffold(
      floatingActionButton: ElevatedButton(onPressed: (){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(rootId: widget.rootId, categoryName: widget.title,whichResources: 1,);
            // AddResourceScreen(rootId: widget.categoryId!, whichResources: 1, categoryName: widget.categoryName!,); // Showing custom dialog
          },
        ).then((value) {
          if(value){
            setState(() {
              ResourcesBloc().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: widget.mediaType));

            });
          }
        });
      }, child: Text("Add Resource")),

      body: SingleChildScrollView(
        child: Column(
          children: [
                 BlocConsumer<ResourcesBloc, ResourcesState>(
              listener: (context, state) {
                print("bloc consumer state");
                if(state is ResourcesLoaded){
                  print("resource loaded success from consumer");

                }
                if (state is ResourcesDelete) {
                  print("resource deleted success from consumer");

                  ResourcesBloc().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: widget.mediaType));
                  //context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: ''));
                }
              },
              builder: (context, state) {
                if (state is ResourcesLoading) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.9,

                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (state is ResourcesLoaded) {


                  if (state.allResourcesModel.data!.record!.records!.isEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: const Center(
                        child: Text('No Resources found.'),
                      ),
                    );
                  } else {

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: state.allResourcesModel.data!.record!.records!.length,
                      itemBuilder: (context, index) {
                        final content = state.allResourcesModel.data!.record!.records![index].content.toString();
                        final title = state.allResourcesModel.data!.record!.records![index].title;
                        final sortedRecords = List.from(state.allResourcesModel.data!.record!.records!);
                        sortedRecords.sort((a, b) => DateTime.parse(a.createdAt).compareTo(DateTime.parse(a.createdAt)));
                        final rNumber = sortedRecords.indexOf(state.allResourcesModel.data!.record!.records![index]) + 1; // Get index of current record in sorted list and add 1 to make it R1, R2, ...

                        return GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewResource(
                              title: state.allResourcesModel.data!.record!.records![index].title.toString(),
                              content: state.allResourcesModel.data!.record!.records![index].content.toString(),
                            )));
                          },
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(width: 8.0),
                                          GestureDetector(
                                            onTap: () {
                                              print("popupmenuIcon dailogbox");
                                              _showImageDialog(context, content, title.toString());
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12.0),
                                                color: const Color(0xFFF5F5F5),
                                              ),
                                              // content
                                              child: getFileType(content) == 'Photo'
                                                  ? CachedNetworkImage(
                                                imageUrl: 'https://backend.savant.app/public/image/$content',
                                                fit: BoxFit.fitHeight,
                                                height: 35,
                                                width: 35,
                                                progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                  child: CircularProgressIndicator(value: downloadProgress.progress),
                                                ),
                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                              )
                                                  : getMediaType(content) == 'video'
                                                  ? const Icon(Icons.video_camera_back_outlined, size: 35,)
                                                  : getMediaType(content) == 'audio'
                                                  ? const Icon(Icons.audiotrack, size: 35)
                                                  : const Icon(Icons.text_format_sharp, size: 35),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                            child: Text("R$rNumber", // Use rNumber here
                                                style: TextStyle(fontSize: 18.0, letterSpacing: 1, fontWeight: FontWeight.w500)
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                            child: SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.5, // Adjust width according to your layout
                                              child: Text(
                                                (title != null ? '${title.substring(0, 1).toUpperCase()}${title.substring(1)}' : 'Untitled'),
                                                style: TextStyle(fontSize: 18.0, letterSpacing: 1, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton(
                                    icon: Icon(Icons.more_vert,color: Colors.red,),
                                    itemBuilder: (context) {
                                      return [
                                        const PopupMenuItem(
                                            value: 'updateResource',
                                            child: InkWell(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Icon(Icons.update, color: primaryColor,),
                                                    SizedBox(width: 8.0,),
                                                    Text("Update resource"),
                                                  ],
                                                ))
                                        ),
                                        const PopupMenuItem(
                                            value: 'play',
                                            child: InkWell(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Icon(Icons.play_arrow, color: primaryColor,),
                                                    SizedBox(width: 8.0,),
                                                    Text("Play prompts"),
                                                  ],
                                                ))
                                        ),

                                        const PopupMenuItem(
                                            value: 'add',
                                            child: InkWell(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Icon(Icons.update, color: primaryColor,),
                                                    SizedBox(width: 8.0,),
                                                    Text("Add prompts"),
                                                  ],
                                                ))
                                        ),
                                        const PopupMenuItem(
                                            value: 'remove',
                                            child: InkWell(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Icon(Icons.delete, color: primaryColor,),
                                                    SizedBox(width: 8.0,),
                                                    Text("Remove resource"),
                                                  ],
                                                ))
                                        ),
                                      ];
                                    },
                                    onSelected: (String value) {
                                      switch(value){
                                        case 'updateResource':
                                          updateResource(
                                            resourceId: state.allResourcesModel.data!.record!.records![index].sId.toString(),
                                            mediaType: state.allResourcesModel.data!.record!.records![index].type!,
                                            resourceContent: state.allResourcesModel.data!.record!.records![index].content.toString(),
                                            resourceTitle: state.allResourcesModel.data!.record!.records![index].title!
                                          );
/*
                                           QuickImportRepo.updateResources(rootId: widget.rootId!,resourceId: state.allResourcesModel.data!.record!.records![index].sId.toString() ,
                                               mediaType: state.allResourcesModel.data!.record!.records![index].type!, resourceTitle: "xyz",
                                               resourceContent: state.allResourcesModel.data!.record!.records![index].content.toString() );
*/

                                          break;
                                        case 'play':
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return PromtsScreen(
                                                    ResTitle:state.allResourcesModel.data!.record!.records![index].title ,
                                                    content: state.allResourcesModel.data!.record!.records![index].content ?? state.allResourcesModel.data!.record!.records![index].title,
                                                    mediaType: state.allResourcesModel.data!.record!.records![index].type!,
                                                    promtId: state.allResourcesModel.data!.record!.records![index].sId!,
                                                    fromType: Prompt.fromResource,
                                                  );
                                                },
                                              ));
                                          break;
                                        case 'add':
                                          context.push(AddPromptsScreen(
                                            resourceId: state.allResourcesModel.data!.record!.records![index].sId.toString(),
                                            categoryId: widget.rootId,
                                          ));
                                          break;
                                        case 'remove':
                                          showDeleteResource(resourceId:state.allResourcesModel.data!.record!.records![index].sId.toString(),
                                          resourceName: state.allResourcesModel.data!.record!.records![index].title.toString()
                                          );
                                          // deleteResource(rootId:state.allResourcesModel.data!.record!.records![index].sId.toString() );
                                          // ResourcesBloc().add(
                                          //     DeleteResourcesEvent(
                                          //         rootId:
                                          //     )
                                          // );
                                          break;
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
                return const Text('something went wrong');
              },
            ),
            SizedBox(height: 88,)
          ],
        ),
      )

      );
  }
  Future<void> _showImageDialog(BuildContext context, String content, String title) async {
    FlickManager? _flickManager;
    final audioPlayer = AudioPlayer();
    _flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network('https://backend.savant.app/public/video/$content'),
    );
    print("content - $content");
    print("getfilecontent==>${getFileType(content)}");
 print("content8888 $content");
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 0,vertical: 0),
          content: Container(
             padding: EdgeInsets.zero,
            width: double.maxFinite,
            height: 300,
            child: getFileType(content) == 'Photo'
                ? PhotoView(
                  imageProvider: NetworkImage(
              "https://backend.savant.app/public/image/$content",
            ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,

            )
                : getFileType(content) == 'Video'
                ? FlickVideoPlayer(
              flickVideoWithControls: FlickVideoWithControls(
                videoFit: BoxFit.contain,
                controls: FlickPortraitControls(),
              ),

              flickManager:
              _flickManager!,

            )
                : getFileType(content) == "Audio"
                ?
            Container(
              color: Colors.white,
                  child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  StreamBuilder<PlaybackEvent>(
                    stream: audioPlayer.playbackEventStream,
                    builder: (context, snapshot) {
                      final processingState = snapshot.data?.processingState ?? ProcessingState.idle;
                      final playing = processingState == ProcessingState.ready;
                      final buffering = processingState == ProcessingState.buffering;
                      final audioCompleted = processingState == ProcessingState.completed;
                      bool _isPlaying = false;

                      // Display different icons based on the processing state
                      return BlurryContainer(
                        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                        color: Colors.white,
                        elevation: 5,
                        borderRadius: BorderRadius.circular(90),

                        child:
                        IconButton(
                          icon: buffering
                              ? CircularProgressIndicator()
                              : playing
                              ? Icon(Icons.pause)
                              : Icon(Icons.play_arrow),
                          onPressed: () async {
                            if (playing) {

                              audioPlayer.pause();
                            } else {
                              audioPlayer.setUrl("https://backend.savant.app/public/audio/$content");
                              audioPlayer.play();
                              if(audioCompleted){
                                await audioPlayer.seek(const Duration(seconds: 0));
                                await audioPlayer.pause();                            }
                            }
                          },
                        ),
                      );
                    },
                  )  ,
                    StreamBuilder<Duration>(
                  stream: audioPlayer.durationStream.map((duration) => duration ?? Duration.zero),
                    builder: (context, snapshot) {
                      final duration = snapshot.data ?? Duration.zero;
                      return StreamBuilder<Duration>(
                        stream: audioPlayer.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          return
                            Slider(
                              value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
                              min: 0.0,
                              max: duration.inMilliseconds.toDouble(),
                              onChanged: (value) {
                                final newPosition = Duration(milliseconds: value.toInt());
                                audioPlayer.seek(newPosition);
                              },
                            );
                        },
                      );
                    },
                  ),
                  StreamBuilder<Duration>(
                    stream: audioPlayer.durationStream.map((duration) => duration ?? Duration.zero),
                    builder: (context, snapshot) {
                      final duration = snapshot.data ?? Duration.zero;
                      return Text(
                        "${formatDuration(duration)}",
                      );
                    },
                  ),
              ],
            ),
                )// Display the title for audio content
                : Center(child: Container(
              color: Colors.white,
              width: double.maxFinite,
                height: double.maxFinite,
                child: Center(child: Text(content, style: TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),)))), // Display the title for unsupported content
          ),          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _flickManager?.dispose();

              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

}
String formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
String getMediaType(String filePath) {
  final mimeType = lookupMimeType(filePath);

  if (mimeType != null) {
    if (mimeType.startsWith('image/')) {
      return 'image';
    } else if (mimeType.startsWith('audio/')) {
      return 'audio';
    } else if (mimeType.startsWith('video/')) {
      return 'video';
    }
  }

  return 'unknown';
}
class AddResourceDialog extends StatelessWidget {
  String? rootId;
  String? categoryName;
  AddResourceDialog({required this.rootId, required this.categoryName});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height*0.58,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 8,top: 8),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(45),
                    border: Border.all(width: 1.5,color: Colors.red.shade300)
                  ),
                  child: IconButton(
                    onPressed: (){
                      Navigator.pop(context,true);
                    },
                    icon: Icon(Icons.close),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Add Resource to ${categoryName}',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Expanded(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AddResourceScreen(rootId: rootId!, whichResources: 1, categoryName: categoryName!),
            ))
          ],
        ),
      ),
    );
  }
}