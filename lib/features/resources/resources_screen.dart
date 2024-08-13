import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:self_learning_app/features/add_media/bloc/add_media_bloc.dart';
import 'package:self_learning_app/features/add_promts/add_promts_screen.dart';
import 'package:self_learning_app/features/dashboard/dashboard_screen.dart';
import 'package:self_learning_app/features/flow_screen/start_flow_screen.dart';
import 'package:self_learning_app/features/resources/bloc/resources_bloc.dart';
import 'package:self_learning_app/features/subcategory/model/resources_model.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:mime/mime.dart';
import '../../utilities/base_client.dart';
import '../../utilities/shared_pref.dart';
import '../../widgets/add_resources_screen.dart';
import '../../widgets/play_music.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../../widgets/view_resource.dart';
import '../promt/promts_screen.dart';
import '../quick_import/repo/quick_add_repo.dart';

class AllResourcesList extends StatefulWidget {
  final String rootId;
  final String mediaType;

  const AllResourcesList(
      {Key? key, required this.rootId, required this.mediaType})
      : super(key: key);

  @override
  State<AllResourcesList> createState() => _AllResourcesListState();
}

class _AllResourcesListState extends State<AllResourcesList> {
  final ResourcesBloc resourcesBloc = ResourcesBloc();
  TextEditingController textEditingController = TextEditingController();
  bool _shouldRefreshBloc = false;

  @override
  void initState() {
    resourcesBloc.add(LoadResourcesEvent(rootId: widget.rootId, mediaType: widget.mediaType));
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
/*
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return PromtsScreen(
                content: content, mediaType: mediatype, promtId: promtId, fromType: Prompt.fromResource,);
          },
        ));
*/
      }
      final data = jsonDecode(res.body);
      return data[''];
    } catch (e) {}
  }
  void deleteResource({
    required String rootId,
  }) async {
    print('delete');
    EasyLoading.show();
    http.Response res = await Api().delete(
      endPoint: 'resource/$rootId',
    );
    if (res.statusCode==200){
      EasyLoading.dismiss();
      setState(() {
        resourcesBloc.add(LoadResourcesEvent(rootId: widget.rootId, mediaType: widget.mediaType));

      });
      context.showSnackBar(const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Ressource deleted successfully')));
    }
    else{
      EasyLoading.dismiss();
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => resourcesBloc,
      child: WillPopScope(
        onWillPop: () async{
          if(_shouldRefreshBloc){
            BlocProvider.of<ResourcesBloc>(context).add(LoadResourcesEvent(rootId: widget.rootId, mediaType: ''));
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFEEEEEE),
          appBar: AppBar(
              title: const Text('Resources'),
            backgroundColor: Colors.green,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if(_shouldRefreshBloc){
                  BlocProvider.of<ResourcesBloc>(context).add(LoadResourcesEvent(rootId: widget.rootId, mediaType: ''));
                }
                Navigator.pop(context);
              },
            ),
          ),
          body: BlocConsumer<ResourcesBloc, ResourcesState>(
            listener: (context, state) {
              if (state is ResourcesDelete) {
                context.showSnackBar(const SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text('Ressource deleted successfully')));
                resourcesBloc.add(LoadResourcesEvent(rootId: widget.rootId, mediaType: widget.mediaType));
                //context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: ''));
                _shouldRefreshBloc = true;
              }
            },
            builder: (context, state) {
              if (state is ResourcesLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is ResourcesLoaded) {
                if (state.allResourcesModel.data!.record!.records!.isEmpty) {
                  return const Center(
                    child: Text('No Resources found.'),
                  );
                } else {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.allResourcesModel.data!.record!.records!.length,
                      itemBuilder: (context, index) {
                        final content = state.allResourcesModel.data!.record!
                            .records![index].content
                            .toString();
                        final title = state.allResourcesModel.data!.record!
                            .records![index].title;
                        print(content);
                        print('content');

                        return GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewResource(
                                title: state.allResourcesModel.data!.record!.records![index].title.toString(),
                                content: state.allResourcesModel.data!.record!.records![index].content.toString(),
                              )));
                            },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  color: const Color(0xFFF5F5F5),
                                ),
                                  child: getFileType(content)=='Photo'
                                      ? CachedNetworkImage(
                                    imageUrl: 'https://backend.savant.app/public/image/$content',
                                    fit: BoxFit.fitHeight,
                                    height: 35,
                                    width: 35,
                                    progressIndicatorBuilder: (context, url,
                                        downloadProgress) =>
                                        Center(
                                          child: CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  )
                                      :getMediaType(content) == 'video'
                                      ? const Icon(Icons.video_camera_back_outlined, size: 35,)
                                      : getMediaType(content) == 'audio'
                                      ? const Icon(Icons.audiotrack, size: 35)
                                      : const Icon(Icons.text_format_sharp, size: 35),
                              ),
                              title: Text(
                                title != null
                                    ?'${title.substring(0,1).toUpperCase()}${title.substring(1)}'
                                    : 'Untitled',
                                style: TextStyle(fontSize: 20.0, letterSpacing: 1, fontWeight: FontWeight.w600),),
                              subtitle: Row(
                                children: [
                                  ElevatedButton(
                                    child: const Text('Add\nPrompt'),
                                    onPressed: () {
                                      context.push(AddPromptsScreen(
                                        resourceId: state.allResourcesModel.data!.record!.records![index].sId.toString(),
                                        categoryId: widget.rootId,
                                      ));
                                    },
                                  ),
                                  SizedBox(width: 5.0,),
                                  ElevatedButton(
                                    child: const Text('Remove\nResource'),
                                    onPressed: () {
                                      showDeleteResource(
                                        resourceId: state
                                            .allResourcesModel
                                            .data!
                                            .record!
                                            .records![index]
                                            .sId
                                            .toString(),
                                        resourceName: state
                                            .allResourcesModel
                                            .data!
                                            .record!
                                            .records![index]
                                            .title
                                            .toString()
                                      );

                                    },
                                  ),
                                ],
                              ),
                              trailing: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                    onPressed: () {
                                      print(state.allResourcesModel.data!
                                          .record!.records![index].content);

                                      Navigator.push(context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return PromtsScreen(
                                                ResTitle: state.allResourcesModel.data!.record!.records![index].title,
                                                  content: state
                                                      .allResourcesModel
                                                      .data!
                                                      .record!
                                                      .records![index]
                                                      .content ??
                                                      state
                                                          .allResourcesModel
                                                          .data!
                                                          .record!
                                                          .records![index]
                                                          .title,
                                                  mediaType: state
                                                      .allResourcesModel
                                                      .data!
                                                      .record!
                                                      .records![index]
                                                      .type!,
                                                  promtId: state
                                                      .allResourcesModel
                                                      .data!
                                                      .record!
                                                      .records![index]
                                                      .sId!,
                                                fromType: Prompt.fromResource,);
                                            },
                                          ));
                                    },
                                    icon: const Icon(Icons.play_arrow_rounded,), color: Colors.white),
                              ),
                            ),
                          ),
                        );
                        /*return SizedBox(
                          width: context.screenWidth,
                          height: 60,
                          child: Row(
                            children: [

                              Spacer(),
                              content.contains('.jpeg') ||
                                  content.contains('.jpg') ||
                                  content.contains('.png') ||
                                  content.contains('.gif')
                                  ? CachedNetworkImage(
                                imageUrl:
                                fit: BoxFit.fill,
                                height: 40,
                                width: 50,
                                progressIndicatorBuilder: (context, url,
                                    downloadProgress) =>
                                    Center(
                                      child: CircularProgressIndicator(
                                          value: downloadProgress.progress),
                                    ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              )
                                  : SizedBox(width: 50,
                                  child: getMediaType(content) == 'video'
                                      ? const Icon(
                                    Icons.video_camera_back_outlined,
                                    size: 50,
                                  )
                                      : getMediaType(content) != 'audio'
                                      ? const Icon(
                                      Icons.text_format_sharp,
                                      size: 50)
                                      : Icon(Icons.audiotrack, size: 50)),
                              Spacer(),
                              ElevatedButton(
                                child: const Text('Add'),
                                onPressed: () {
                                  context.push(AddPromptsScreen(
                                    resourceId: state.allResourcesModel.data!
                                        .record!.records![index].sId
                                        .toString(),
                                  ));
                                },
                              ),
                              SizedBox(width: 5.0,),
                              ElevatedButton(
                                child: const Text('Start Flow'),
                                onPressed: () {
                                  print(state.allResourcesModel.data!
                                      .record!.records![index].content);

                                  Navigator.push(context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return PromtsScreen(
                                              content: state
                                                  .allResourcesModel
                                                  .data!
                                                  .record!
                                                  .records![index]
                                                  .content ??
                                                  state
                                                      .allResourcesModel
                                                      .data!
                                                      .record!
                                                      .records![index]
                                                      .title,
                                              mediaType: state
                                                  .allResourcesModel
                                                  .data!
                                                  .record!
                                                  .records![index]
                                                  .type!,
                                              promtId: state
                                                  .allResourcesModel
                                                  .data!
                                                  .record!
                                                  .records![index]
                                                  .sId!);
                                        },
                                      ));
                                },
                              ),
                              *//*SizedBox(width: 5.0,),
                              ElevatedButton(
                                child: const Text('Start'),
                                onPressed: () {
                                  print(state.allResourcesModel.data!
                                      .record!.records![index].content);

                                  Navigator.push(context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return StartFlowScreen(
                                              content: state
                                                  .allResourcesModel
                                                  .data!
                                                  .record!
                                                  .records![index]
                                                  .content ??
                                                  state
                                                      .allResourcesModel
                                                      .data!
                                                      .record!
                                                      .records![index]
                                                      .title,
                                              mediaType: state
                                                  .allResourcesModel
                                                  .data!
                                                  .record!
                                                  .records![index]
                                                  .type!,
                                              promtId: state
                                                  .allResourcesModel
                                                  .data!
                                                  .record!
                                                  .records![index]
                                                  .sId!);
                                        },
                                      ));
                                },
                              ),*//*
                              Spacer(),
                              IconButton(
                                  onPressed: () {
                                    resourcesBloc.add(
                                        DeleteResourcesEvent(
                                            rootId: state
                                                .allResourcesModel
                                                .data!
                                                .record!
                                                .records![index]
                                                .sId
                                                .toString()));
                                  },
                                  icon: const Icon(Icons.delete)),
                              Spacer(),
                            ],
                          ),
                        );*/
                      });
                }
              }
              return const Text('something went wrong');
            },
          ),
        ),
      ),
    );
  }
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
