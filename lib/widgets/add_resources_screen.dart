import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:self_learning_app/features/add_media/add_audio_screen.dart';
import 'package:self_learning_app/features/add_media/add_text_screen.dart';
import 'package:self_learning_app/features/add_media/add_video_screen.dart';
import 'package:self_learning_app/features/resources/bloc/resources_bloc.dart';
import 'package:self_learning_app/features/resources/subcategory_resources_screen.dart';
import 'package:self_learning_app/utilities/colors.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';

import '../features/add_media/add_image_screen.dart';
import '../features/dailog_category/bloc/add_prompt_res_cubit.dart';
import '../features/resources/maincategory_resources_screen.dart';
import '../features/resources/resources_screen.dart';
import 'add_prompt_quickAddresourceScreen.dart';

//without app bar for add category or subcatrogry resource or promt

class AddResourceScreen extends StatefulWidget {
  final int whichResources;
  final String rootId;
  final String categoryName;
  AddResourceScreen({Key? key, required this.rootId, required this.whichResources, required this.categoryName}) : super(key: key);

  @override
  State<AddResourceScreen> createState() => _AddResourceScreenState();
}

List<String> mediaTitle = [
  'Take Picture',
  'Record Video',
  'Record Audio',
  'Enter Text'
];

List<IconData> mediaIcons = [
  Icons.camera,
  Icons.video_call_outlined,
  Icons.audio_file_outlined,
  Icons.text_increase
];

class _AddResourceScreenState extends State<AddResourceScreen> {
  final AddPromptResCubit cubitAddPromptRes = AddPromptResCubit();



  @override
  void initState() {


    context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: ''));

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    print("checking category id ${widget.rootId}");
    return Scaffold(

/*
      floatingActionButton: SizedBox(
          height: context.screenHeight*0.1,
        child: FittedBox(
          child: ElevatedButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) =>
                    MaincategoryResourcesList(rootId: widget.rootId!,
                        level: "",
                        mediaType: '',
                        title: widget.categoryName!),));
            },
            child: Text("View All", style: TextStyle(fontSize: 9),),
          ),
        ),
      ),
*/
        body:
        SizedBox(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: mediaIcons.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 0, top: 10),
            child: Container(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue[50]),
              child: ListTile(
                  title: Text(mediaTitle[index]),
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
                                        rootId: widget.rootId,
                                        whichResources: widget.whichResources,
                                      );
                                    },
                                  )).then((value) => {
                                  setState(() {
                                    context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: ''));

                                  })

                                  });
                                }
                                break;
                              case 1:
                                {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return AddVideoScreen(
                                        rootId: widget.rootId,
                                        whichResources: widget.whichResources,
                                      );
                                    },
                                  )).then((value) => {
                                    setState(() {
                                      context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: ''));

                                    })

                                  });
                                }
                                break;
                              case 2:
                                {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return AddAudioScreen(
                                        rootId: widget.rootId,
                                        whichResources: widget.whichResources,
                                      );
                                    },
                                  )).then((value) => {
                                    setState(() {
                                      context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: ''));

                                    })

                                  });
                                }
                                break;
                              case 3:
                                {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return AddTextScreen(
                                          rootId: widget.rootId,
                                          whichResources:
                                              widget.whichResources);
                                    },
                                  )).then((value) => {
                                    setState(() {
                                      context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: ''));

                                    })

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
                                        rootId: widget.rootId,
                                        mediaType: 'image',
                                      );
                                    }
                                  case 1:
                                    {
                                      return AllResourcesList(
                                        rootId: widget.rootId,
                                        mediaType: 'video',
                                      );
                                    }
                                  case 2:
                                    {
                                      return AllResourcesList(
                                        rootId: widget.rootId,
                                        mediaType: 'audio',
                                      );
                                    }
                                  case 3:
                                    {
                                      return AllResourcesList(
                                        rootId: widget.rootId,
                                        mediaType: 'text',
                                      );
                                    }
                                }

                                return AllResourcesList(
                                  rootId: widget.rootId,
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
            ),
          );
        },
      ),
    ));
  }
}

/// this for r

class AddResourceScreen2 extends StatefulWidget {
  final int whichResources;
  final String? resourceId;
  bool ?number;
  AddResourceScreen2({Key? key, required this.whichResources, this.resourceId,required this.number})
      : super(key: key);

  @override
  State<AddResourceScreen2> createState() => _AddResourceScreen2State();
}

class _AddResourceScreen2State extends State<AddResourceScreen2> {
  List<String> mediaTitle = [
    'Take Picture',
    'Record Video',
    'Record Audio',
    'Enter Text',
    'Add prompt'
  ];

  List<IconData> mediaIcons = [
    Icons.camera,
    Icons.video_call_outlined,
    Icons.audio_file_outlined,
    Icons.text_increase,
    Icons.folder
  ];

  Future<dynamic> getToken() async {
    var token = await SharedPref().getToken();
    return token;
  }

  String? parentPromptId;

  @override
  void initState() {
    super.initState();
    // Use the 'await' keyword to wait for the completion of the 'getToken' function
    // and then process the result
    _fetchToken();
  }

// Define a separate method for fetching and processing the token
  Future<void> _fetchToken() async {
    dynamic fetchToken = await getToken();
    Map<String, dynamic> payload = Jwt.parseJwt(fetchToken);
    parentPromptId = payload["id"];
    print("----------->$parentPromptId");
  }


  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Quick Add'),

        ),

        body: Column(
          children: [
           SizedBox(
              //  height: context.screenHeight/2.8,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: mediaIcons.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 0, top: 10),
                    child: Container(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue[50]),
                      child: ListTile(
                          title: Text(mediaTitle[index]),
                          leading: Icon(mediaIcons[index]),
                          trailing: SizedBox(
                            width: context.screenWidth / 3,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: context.screenWidth * 0.035,
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    switch (index) {
                                      case 0:
                                        {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context) {
                                              return AddImageScreen(
                                                whichResources: widget.whichResources,
                                                rootId: widget.resourceId!,
                                              );
                                            },
                                          ));
                                        }
                                        break;
                                      case 1:
                                        {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context) {
                                              return AddVideoScreen(
                                                whichResources: widget.whichResources,
                                                resourceId: widget.resourceId,
                                                rootId: widget.resourceId!,
                                              );
                                            },
                                          ));
                                        }
                                        break;
                                      case 2:
                                        {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context) {
                                              return AddAudioScreen(
                                                whichResources: widget.whichResources,
                                                resourceId: widget.resourceId,
                                                rootId: widget.resourceId!,
                                              );
                                            },
                                          ));
                                        }
                                        break;
                                      case 3:
                                        {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context) {
                                              return AddTextScreen(
                                                whichResources: widget.whichResources,
                                                resourceId: widget.resourceId,
                                                rootId: widget.resourceId!,
                                              );
                                            },
                                          ));
                                        }
                                        break;
                                      case 4 :
                                        {
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddPromptsAddResourceScreen(categoryId: "",resourceId: parentPromptId.toString(),)));

                                        }
                                    }
                                  },
                                ),
                                if (widget.whichResources != 2)
                                  SizedBox(
                                    width: context.screenWidth * 0.035,
                                  ),
                                //  IconButton(
                                //   icon:  const Icon(Icons.remove_red_eye),onPressed: () {
                                //   Navigator.push(context, MaterialPageRoute(builder: (context) {
                                //     return  AllResourcesList(rootId: resourceId!,mediaType: '',);
                                //   },));
                                // },)
                              ],
                            ),
                          )),
                    ),
                  );
                },
              ),
            ),
          // SizedBox(height: 10,),
          // Container(
          //     padding: const EdgeInsets.only(top: 5, bottom: 5),
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(10),
          //         color: Colors.blue[50]),
          //     width:double.infinity,
          //     child: ListTile(
          //       title: Text("Add Prompt"),
          //       leading: Icon(Icons.file_copy),
          //       trailing: (SizedBox(
          //         width: context.screenWidth / 3,
          //
          //         child: Row(
          //           children: [
          //             SizedBox(
          //               width: context.screenWidth * 0.035,
          //             ),
          //             IconButton(onPressed: (){
          //               Navigator.push(context, MaterialPageRoute(builder: (context)=>AddPromptsAddResourceScreen(categoryId: "1",resourceId: parentPromptId.toString(),)));
          //
          //             }, icon: Icon(Icons.add)),
          //           ],
          //         ),
          //       )),
          //     )
          //
          // )
          //   ,
          //
          //   SizedBox(height: 10,),

          ],
        ));
  }
}
