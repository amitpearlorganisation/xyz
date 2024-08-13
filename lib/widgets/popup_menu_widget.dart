import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/widgets/resourceScreenWidget.dart';

import '../features/add_media/add_audio_screen.dart';
import '../features/add_media/add_image_screen.dart';
import '../features/add_media/add_text_screen.dart';
import '../features/add_media/add_video_screen.dart';
import '../features/create_flow/create_flow_screen.dart';
import '../features/create_flow/flow_screen.dart';
import '../features/resources/bloc/resources_bloc.dart';
import '../features/resources/maincategory_resources_screen.dart';
import '../features/resources/resources_screen.dart';
import 'SelectPrimaryFlowWidget.dart';
import 'add_resources_screen.dart';

class PopupMenuWidget extends StatefulWidget {
  String? categoryId;
  String? categoryName;
  String? level;
  PopupMenuWidget({required this.categoryId, required this.categoryName, required this.level});
  @override
  _PopupMenuWidgetState createState() => _PopupMenuWidgetState();
}

class _PopupMenuWidgetState extends State<PopupMenuWidget> {
  String _selectedOption = '';

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        setState(() {
          _selectedOption = result;
        });
        // Handle the selected option here
        switch(result) {
          case 'add_resource':
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialog(rootId: widget.categoryId, categoryName: widget.categoryName,whichResources: 1,);
                  // AddResourceScreen(rootId: widget.categoryId!, whichResources: 1, categoryName: widget.categoryName!,); // Showing custom dialog
              },
            );
            // Navigator.push(context, MaterialPageRoute(builder: (context) => AddResourceScreen(rootId: widget.categoryId!, whichResources: 1, categoryName: widget.categoryName!,)));
            break;
          case 'view_resource':
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                resourceScreenWidget(rootId: widget.categoryId!, categoryName: widget.categoryName! ,level: widget.level!,)));
            break;
          case 'create_flow':
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateFlowScreen(rootId: widget.categoryId!,categoryName: widget.categoryName!,)));
            break;
          case 'set_primary_flow':
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                SelectPrimaryFlow(categoryId: widget.categoryId!,CategoryName: widget.categoryId!,)));
            break;
          default:
          // Handle default case or do nothing
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'add_resource',
          child: Text('Add Resource'),
        ),
        PopupMenuItem<String>(
          value: 'view_resource',
          child: Text('View Resource'),
        ),
        PopupMenuItem<String>(
          value: 'create_flow',
          child: Text('Create Flow'),
        ),
        PopupMenuItem<String>(
          value: 'set_primary_flow',
          child: Text('Set Primary Flow'),
        ),
      ],
      child: Icon(Icons.more_vert),
    );
  }
}

class CustomDialog extends StatefulWidget {
  String? rootId;
  String? categoryName;
  int? whichResources;
  CustomDialog({required this.rootId, required this.categoryName, required this.whichResources});

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  List<String> mediaTitle = [
    'Image',
    'Video',
    'Audio',
    'Text'
  ];

  List<IconData> mediaIcons = [
    Icons.camera,
    Icons.video_call_outlined,
    Icons.audio_file_outlined,
    Icons.text_increase
  ];

  @override
  void initState() {


    context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId!, mediaType: ''));

    super.initState();

  }

  @override  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child:
      Container(
        height: MediaQuery.of(context).size.height*0.5,
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              width: double.infinity,
              child: Row(

                children: [
                  Expanded(child:

                  Container(
                      alignment: Alignment.center,
                      child: Text("Add resource ${widget.categoryName}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),))),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context,true);
                      },
                      iconSize: 20,
                      icon: Icon(Icons.close, color: Colors.black87,),
                    ),
                  ),
                ],
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              itemCount: mediaIcons.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue[50]),
                  child: ListTile(
                      leading: Icon(mediaIcons[index]),
                      trailing: SizedBox(
                        width: context.screenWidth / 2.7,
                        child: Row(
                          children: [
                            SizedBox(
                              width: context.screenWidth * 0.04,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                switch (index) {
                                  case 0:
                                    {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return AddImageScreen(
                                            rootId: widget.rootId!,
                                            whichResources: widget.whichResources!,
                                          );
                                        },
                                      )).then((value) {
                                        setState(() {
                                          context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId!, mediaType: ''));

                                        });
                                      });
                                    }
                                    break;
                                  case 1:
                                    {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return AddVideoScreen(
                                            rootId: widget.rootId!,
                                            whichResources: widget.whichResources!,
                                          );
                                        },
                                      )).then((value) {
                                        setState(() {
                                          context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId!, mediaType: ''));

                                        });
                                      });
                                    }
                                    break;
                                  case 2:
                                    {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return AddAudioScreen(
                                            rootId: widget.rootId!,
                                            whichResources: widget.whichResources!,
                                          );
                                        },
                                      )).then((value) {
                                        setState(() {
                                          context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId!, mediaType: ''));

                                        });
                                      });
                                    }
                                    break;
                                  case 3:
                                    {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return AddTextScreen(
                                              rootId: widget.rootId!,
                                              whichResources:
                                              widget.whichResources!);
                                        },
                                      )).then((value) {
                                        setState(() {
                                          context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId!, mediaType: ''));

                                        });
                                      });
                                    }
                                }
                              },
                            ),
                            SizedBox(
                              width: context.screenWidth * 0.04,
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_red_eye),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    switch (index) {
                                      case 0:
                                        {
                                          return AllResourcesList(
                                            rootId: widget.rootId!,
                                            mediaType: 'image',
                                          );
                                        }
                                      case 1:
                                        {
                                          return AllResourcesList(
                                            rootId: widget.rootId!,
                                            mediaType: 'video',
                                          );
                                        }
                                      case 2:
                                        {
                                          return AllResourcesList(
                                            rootId: widget.rootId!,
                                            mediaType: 'audio',
                                          );
                                        }
                                      case 3:
                                        {
                                          return AllResourcesList(
                                            rootId: widget.rootId!,
                                            mediaType: 'text',
                                          );
                                        }
                                    }

                                    return AllResourcesList(
                                      rootId: widget.rootId!,
                                      mediaType: 'text',
                                    );
                                  },
                                ));
                              },
                            ),
                            BlocConsumer<ResourcesBloc, ResourcesState>(
                              builder: (context, state) {
                                if (state is ResourcesLoaded) {
                                  // print(state.allResourcesModel.data!.record!.count!.videoCount.toString());
                                  // print('state.allResourcesModel.data!.record!.count!.videoCount.toString()');
                                  List<String> count = [];
                                  final i = state.allResourcesModel.data!.record!
                                      .count!.imageCount
                                      .toString();
                                  final v = state.allResourcesModel.data!.record!
                                      .count!.videoCount
                                      .toString();
                                  final a = state.allResourcesModel.data!.record!
                                      .count!.audioCount
                                      .toString();
                                  final t = state.allResourcesModel.data!.record!
                                      .count!.textCount
                                      .toString();
                                  count.add(i);
                                  count.add(v);
                                  count.add(a);
                                  count.add(t);

                                  return Text(count[index]);
                                }
                                return Text('0');
                              },
                              listener: (context, state) {},
                            )
                          ],
                        ),
                      )),
                );
              },
            ),
          ],
        ),
      )

    );
  }
}