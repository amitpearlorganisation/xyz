import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:photo_view/photo_view.dart';
import 'package:self_learning_app/features/add_Dailog/dailog_screen.dart';
import 'package:self_learning_app/features/create_flow/slide_show_screen.dart';
import 'package:self_learning_app/features/dailog_category/repo/promptResRepo.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:video_player/video_player.dart';

import '../../utilities/colors.dart';
import '../../widgets/add_prompt_quickAddresourceScreen.dart';
import '../../widgets/add_resources_screen.dart';
import '../add_Dailog/bloc/get_dailog_bloc/get_dailog_bloc.dart';
import '../add_Dailog/bloc/new_dailog/new_dialog_dart_cubit.dart';
import '../add_Dailog/createflowfordailog/createDailogFlow.dart';
import '../add_Dailog/dailogPrompt/dailog_prompt.dart';
import '../add_Dailog/model/addDailog_model.dart';
import '../add_Dailog/newDialog.dart';
import '../add_promts/add_promts_screen.dart';
import '../add_promts_to_flow/add_promts_to_flow_screen.dart';
import '../category/bloc/category_bloc.dart';
import '../create_flow/bloc/create_flow_screen_bloc.dart';
import '../create_flow/create_flow_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../create_flow/data/model/flow_model.dart';
import '../create_flow/flow_screen.dart';
import '../promt/promts_screen.dart';
import '../quick_add/PromptBloc/quick_prompt_bloc.dart';
import '../resources/maincategory_resources_screen.dart';
import '../subcategory/primaryflow/primaryflow.dart';
import 'bloc/add_prompt_res_cubit.dart';

class DailogCategoryScreen extends StatefulWidget {
  String dailoId;
  List<AddResourceListModel> resourceList;
  List<AddPromptListModel> promptList;

  DailogCategoryScreen(
      {super.key,
      required this.resourceList,
      required this.promptList,
      required this.dailoId});

  @override
  State<DailogCategoryScreen> createState() => _DailogCategoryScreenState();
}

class _DailogCategoryScreenState extends State<DailogCategoryScreen> {
  @override
  List<dynamic> mixList = ["amit", 40, 60, "vipin", 30, 20, "abhi", "govind"];
  List<String> promtList = [
    "Prompt1",
    "Prompt2",
    "Prompt3",
    "Prompt4",
    "Prompt5"
  ];
  TextEditingController dailog_create_controller = TextEditingController();

  final AddPromptResCubit cubitAddPromptRes = AddPromptResCubit();

  List<ListItem> itemCheck = [];
  List<AddPromptListModel> createflowprompt = [];
  List<AddResourceListModel> reswithPromptList = [];
  final Dio _dio = Dio();
  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text('Add prompts for'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      // To allow scrolling if the content is too tall
                      builder: (context) {
                        return BottomSheetforAddQuickPrompt(
                          dialogId: widget.dailoId,
                        );
                      });
                },
                child: Text('Quick List'),
              ),
              SizedBox(height: 10),
/*
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddPromptsScreen(
                                resourceId: resourceId.toString(),
                                categoryId: widget.dailoId,
                              )));
                },
                child: Text('Custom'),
              ),
*/
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {

                Navigator.of(context).pop();// Close the dialog
                setState(() {
                  cubitAddPromptRes.getResPrompt(dailogId: widget.dailoId);

                });
              },
              icon: Icon(Icons.close),
            ),
          ],
        );
      },
    );
  }

  AwesomeDialog successDailog(
      {required String promptName,
      required String resourceName,
      required BuildContext context}) {
    return AwesomeDialog(
      context: context,
      animType: AnimType.LEFTSLIDE,
      dialogType: DialogType.SUCCES,
      body: Center(
        child: Text(
          '$promptName is successfully added in $resourceName',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
    )..show();
  }

  String? userId;
  String? resourceId;
  Map<dynamic, dynamic>? payload;

void deletPrompt({required String promptId}) async{
  var token = await SharedPref().getToken();
  final Map<String, dynamic> headers = {
    'Authorization': 'Bearer $token',
  };
  try{
    Response res = await _dio.delete("https://backend.savant.app/web/prompt/$promptId", options: Options(headers: headers));
    if(res.statusCode==200){
      EasyLoading.showToast("prompt is successully deleted");
      cubitAddPromptRes.getResPrompt(dailogId: widget.dailoId);

  setState(() {

      });
    }
  }
  catch(e){
    EasyLoading.showToast(e.toString());
  }
}

  @override
  void initState() {
    super.initState();
    // Call the separate method to perform asynchronous operation
    _fetchUserId();
  }

  // Separate method for asynchronous operation
  Future<void> _fetchUserId() async {
    userId = await SharedPref().getToken();
    payload = Jwt.parseJwt(userId!);
    setState(() {
      resourceId = payload?['id'];
    });
    print("resourceId=====>$resourceId");
  }


  Widget build(BuildContext context) {
    print("Dailog id is ${widget.dailoId.toString()}");
    return BlocProvider(
      create: (context) =>
          cubitAddPromptRes..getResPrompt(dailogId: widget.dailoId),
      child: BlocListener<AddPromptResCubit, AddPromptResState>(
        listener: (context, state) {
          if (state is AddPromptResSuccess) {}
          if (state is ResourceDeletedSuccess) {
            EasyLoading.showToast("Delete Successfull");
            context
                .read<AddPromptResCubit>()
                .getResPrompt(dailogId: widget.dailoId);
          }
        },
        child: DefaultTabController(
            length: 2,
            child: Scaffold(
              floatingActionButton: SpeedDial(
                animatedIcon: AnimatedIcons.list_view,
                overlayColor: Colors.transparent,
                elevation: 10,
                curve: Curves.bounceIn,
                shape: CircleBorder(),
                animatedIconTheme: IconThemeData(size: 22.0),
                activeBackgroundColor: Colors.blue,
                overlayOpacity: 0.1,
                spacing: 12,
                spaceBetweenChildren: 12,
                children: [
                  SpeedDialChild(
                      label: "Add Resource",
                      backgroundColor: Colors.green[100],
                      child: Icon(Icons.source, color: primaryColor),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return AddResourceScreen(
                                rootId: widget.dailoId,
                                whichResources: 1,
                                categoryName: "name");
                          },
                        ));
                      }),
                  SpeedDialChild(
                    onTap: () {
                      _showMyDialog(context);
                    },
                    label: "Add Prompt",
                    backgroundColor: Colors.green[100],
                    child: Icon(
                      Icons.add_box,
                      color: primaryColor,
                    ),
                  ),
                  SpeedDialChild(
                      label: "create flow",
                      backgroundColor: Colors.green[100],
                      child: Icon(
                        Icons.file_copy,
                        color: primaryColor,
                      ),
                      onTap: () {

                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            // To allow scrolling if the content is too tall
                            builder: (context) {
                              return BottomSheetForCreateFlow(
                                dailogId: widget.dailoId,
                                promptList: widget.promptList,
                                reswithPromptList: reswithPromptList,
                              );
                            });
                        // createDailog();
                        /* Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CreateFlowScreen(
                          rootId: "widget.rootId!",
                          categoryName: "widget.categoryName",
                        );
                      }));*/
                      }),
                  SpeedDialChild(
                      label: "select primary flow",
                      backgroundColor: Colors.green[100],
                      child: Icon(Icons.play_arrow, color: primaryColor),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FlowScreen(
                                    categoryname: "", rootId: widget.dailoId)));
                        /* showModalBottomSheet(
                            context: context,
                            isScrollControlled: true, // To allow scrolling if the content is too tall
                            builder: (context) {
                              return BottomSheetForPrimaryFlow(dailogId: widget.dailoId, );
                            });*/
                      }),
                  SpeedDialChild(
                      label: "schedule",
                      backgroundColor: Colors.green[100],
                      child: Icon(Icons.schedule, color: primaryColor))
                ],
              ),
              appBar: AppBar(
                  elevation: 1,
                  title: Text("Dailog Category Screen"),
                  actions: [
/*
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateFlowScreen(rootId: widget.rootId!),));
                    },),
*/
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PrimaryFlow(
                                        categoryName: "",
                                        CatId: widget.dailoId,
                                        flowId: "1",
                                      )));
                        },
                        icon: Icon(
                          Icons.play_circle,
                          size: 30,
                        )),
                    SizedBox(
                      width: 10,
                    )
                  ]),
              body: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    height: 100,
                    color: Colors.red,
                    child: BlurryContainer(
                      height: 50,
                      color: Colors.white,
                      elevation: 5,
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text("Search"), Icon(Icons.search)],
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    color: Color(0xffFF8080),
                    child: TabBar(
                      labelColor: Colors.blueAccent,
                      unselectedLabelColor: Colors.white,
                      indicatorColor: Colors.red,
                      indicatorWeight: 4,
                      indicatorPadding: EdgeInsets.symmetric(horizontal: 16),
                      labelPadding: EdgeInsets.zero,
                      automaticIndicatorColorAdjustment: true,
                      tabs: [
                        Text("Resources"),
                        Text("Prompts"),
                      ],
                    ),
                  ),
                  Expanded(
                      child: TabBarView(
                    children: <Widget>[
                      BlocBuilder<AddPromptResCubit, AddPromptResState>(
                        buildWhen: (previous, current) =>
                            previous != current &&
                            current is GetResourcePromptDailog,
                        builder: (context, state) {
                          if (state is AddPromptResLoading) {
                            return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator());
                          }
                          if (state is GetResourcePromptDailog) {
                            if (state.res_prompt_list == 0 || state.res_prompt_list.isEmpty) {
                              return Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height*0.9,
                                  child: Center(child: Text("!No resource ")));
                            } else {
                              return CustomScrollView(
                                slivers: <Widget>[
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        reswithPromptList.clear();
                                        reswithPromptList.add(
                                            AddResourceListModel(
                                                resourceId: state
                                                    .res_prompt_list[index]
                                                    .resourceId,
                                                resourceName: state
                                                    .res_prompt_list[index]
                                                    .resourceName,
                                                resourceType: "resourceType",
                                                resourceContent:
                                                    "resourceContent",
                                                resPromptList: state
                                                    .res_prompt_list[index]
                                                    .resPromptList));



                                        final item = widget.resourceList[index];
                                        Color iconColor = Colors
                                            .transparent; // Provide a default value
                                        String? leadingText;
                                        final content = "resource";
                                        String? title = "new resource";

                                        // If the item is a string, display it as a card that navigates to a screen
                                        return GestureDetector(
                                          onTap: () {
                                            // Navigate to the string screen
                                            /*Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return StringScreen(item);
                                }));*/
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 5),
                                            height: 70,
                                            child: Card(
                                              color: Colors.blue[50],
                                              elevation: 1,
                                              child: Center(
                                                child: ListTile(
                                                  title: Text(
                                                      'Resource: ${state.res_prompt_list[index].resourceName}'),
                                                  leading: GestureDetector(
                                                    onTap: () {
                                                      print(
                                                          "popupmenuIcon dailogbox");
                                                      // _showImageDialog(
                                                      //     context,
                                                      //     content,
                                                      //     item.toString());
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 45,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                                .deepOrangeAccent[
                                                            200],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(90),
                                                      ),
                                                      child: Text("R"),
                                                      /*    getFileType(
                                                                  content) ==
                                                              'Photo'
                                                          ? CachedNetworkImage(
                                                              imageUrl:
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              height: 35,
                                                              width: 35,
                                                              progressIndicatorBuilder:
                                                                  (context, url,
                                                                          downloadProgress) =>
                                                                      Center(
                                                                child: CircularProgressIndicator(
                                                                    value: downloadProgress
                                                                        .progress),
                                                              ),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Icon(Icons
                                                                      .error),
                                                            )
                                                          : getMediaType(
                                                                      content) ==
                                                                  'video'
                                                              ? const Icon(
                                                                  Icons
                                                                      .video_camera_back_outlined,
                                                                  size: 35,
                                                                )
                                                              : getMediaType(
                                                                          content) ==
                                                                      'audio'
                                                                  ? const Icon(
                                                                      Icons
                                                                          .audiotrack,
                                                                      size: 35)
                                                                  : Text(
                                                                      "R",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),*/
                                                    ),
                                                  ),
                                                  trailing: PopupMenuButton(
                                                    icon: Icon(
                                                      Icons.more_vert,
                                                      color: Colors.red,
                                                    ),
                                                    itemBuilder: (context) {
                                                      return [
                                                        const PopupMenuItem(
                                                            value: 'AddPrompt',
                                                            child: InkWell(
                                                                child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons.update,
                                                                  color:
                                                                      primaryColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 8.0,
                                                                ),
                                                                Text(
                                                                    "AddPrompt"),
                                                              ],
                                                            ))),
                                                        const PopupMenuItem(
                                                            value: 'ViewPrompt',
                                                            child: InkWell(
                                                                child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons.update,
                                                                  color:
                                                                      primaryColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 8.0,
                                                                ),
                                                                Text(
                                                                    "View Prompt"),
                                                              ],
                                                            ))),
                                                        const PopupMenuItem(
                                                            value: 'dltres',
                                                            child: InkWell(
                                                                child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons.delete,
                                                                  color:
                                                                      primaryColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 8.0,
                                                                ),
                                                                Text("Delete"),
                                                              ],
                                                            )))
                                                      ];
                                                    },
                                                    onSelected: (String value) {
                                                      switch (value) {
                                                        case 'AddPrompt':
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          AddPromptsScreen(
                                                                            categoryId:
                                                                                widget.dailoId,
                                                                            resourceId:
                                                                                state.res_prompt_list[index].resourceId,
                                                                          )));

                                                          break;
                                                        case 'dltres':
                                                          context.read<
                                                              AddPromptResCubit>()
                                                            ..deleteResource(
                                                                resourceId: state
                                                                    .res_prompt_list[
                                                                        index]
                                                                    .resourceId);

                                                          break;
                                                        case 'ViewPrompt':
                                                          print(
                                                              "ResPromptListLength=${widget.resourceList[index].resPromptList.length}");
                                                          SideSheet.left(
                                                              body: SideSheetDrawer(
                                                                  resourceId: state
                                                                      .res_prompt_list[
                                                                          index]
                                                                      .resourceId,
                                                                  resPromptList: widget
                                                                      .resourceList[
                                                                          index]
                                                                      .resPromptList,
                                                                  ResourceName: widget
                                                                      .resourceList[
                                                                          index]
                                                                      .resourceName),
                                                              context: context);

                                                          break;
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      childCount: state.res_prompt_list.length,
                                    ),
                                  ),
                                ],
                              );
                            }
                          }
                          return Text("Some Things went worng");
                        },
                      ),
                      BlocConsumer<AddPromptResCubit, AddPromptResState>(
                        listener: (context, state) {
                          if(state is GetPromptUpdate){
                            context.read<AddPromptResCubit>().getResPrompt(dailogId: widget.dailoId);

                          }
                        },
                        builder: (context, state) {
                          return BlocBuilder<AddPromptResCubit,
                              AddPromptResState>(
                            builder: (context, state) {
                              if (state is AddPromptResLoading) {
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  width: double.infinity,
                                  child: Center(
                                      child: Container(
                                          width: 55,
                                          height: 55,
                                          child: CircularProgressIndicator())),
                                );
                              }
                              if (state is GetResourcePromptDailog) {
                                if (state.def_prompt_list.length == 0) {
                                  return Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    child: Text("Sorry No Prompt"),
                                  );
                                } else {

                                  return CustomScrollView(
                                    slivers: <Widget>[
                                      SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (BuildContext context, int index) {
                                            createflowprompt.clear();
                                            createflowprompt
                                                .add(AddPromptListModel(
                                              promptId: state
                                                  .def_prompt_list[index]
                                                  .promptId,
                                              parentPromptId: state
                                                  .def_prompt_list[index]
                                                  .parentPromptId,
                                              promptTitle:state.def_prompt_list[index].promptTitle,
                                              promptSide1Content: state
                                                  .def_prompt_list[index]
                                                  .promptSide1Content,
                                              promptSide2Content: state
                                                  .def_prompt_list[index]
                                                  .promptSide2Content,
                                            ));

                                            // If the item is an integer, display it as a card that navigates to a different screen
                                            return GestureDetector(
                                              onTap: () {
                                                // Navigate to the integer screen
                                                /* Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return IntScreen(item);
                                }));*/
                                              },
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 5),
                                                height: 70,
                                                child: Card(
                                                  color: Colors.teal[50],
                                                  elevation: 1,
                                                  child: Center(
                                                    child: ListTile(
                                                      title: Text(
                                                          'Prompt: ${state.def_prompt_list[index].promptTitle}'),
                                                      leading: Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                vertical: 2),
                                                        alignment:
                                                            Alignment.center,
                                                        width: 45,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.pink[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(90),
                                                        ),
                                                        child: Text(
                                                          "P",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      trailing: PopupMenuButton(
                                                        icon: Icon(
                                                          Icons.more_vert,
                                                          color: Colors.red,
                                                        ),
                                                        itemBuilder: (context) {
                                                          return [
                                                            const PopupMenuItem(
                                                                value:
                                                                    'AddResource',
                                                                child: InkWell(
                                                                    child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .update,
                                                                      color:
                                                                          primaryColor,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          8.0,
                                                                    ),
                                                                    Text(
                                                                        "Add to Resource"),
                                                                  ],
                                                                ))),
                                                            const PopupMenuItem(
                                                                value:
                                                                    'viewprompt',
                                                                child: InkWell(
                                                                    child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .update,
                                                                      color:
                                                                          primaryColor,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          8.0,
                                                                    ),
                                                                    Text(
                                                                        "View Prompt"),
                                                                  ],
                                                                ))),
                                                            const PopupMenuItem(
                                                                value: 'delete',
                                                                child: InkWell(
                                                                    child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color:
                                                                          primaryColor,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          8.0,
                                                                    ),
                                                                    Text(
                                                                        "Delete"),
                                                                  ],
                                                                )))
                                                          ];
                                                        },
                                                        onSelected:
                                                            (String value) {
                                                          switch (value) {
                                                            case 'AddResource':
                                                              showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return BottomSheet(
                                                                    dialogId: widget.dailoId,
                                                                    promptName: widget
                                                                        .promptList[
                                                                            index]
                                                                        .promptTitle,
                                                                    res_prompt_list: state.res_prompt_list,
                                                                    promptId: state.def_prompt_list[index].promptId
                                                                  );
                                                                },
                                                              );
                                                              break;
                                                            case 'viewprompt':
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                                  return SlideShowScreen2(
                                                                    flowName: "",
                                                                    side1type:
                                                                        "",
                                                                    promptTitle: state
                                                                        .def_prompt_list[
                                                                            index]
                                                                        .promptTitle,
                                                                    side2contentTitle: state
                                                                        .def_prompt_list[
                                                                            index]
                                                                        .promptSide2Content,
                                                                    side1contentTitle: state
                                                                        .def_prompt_list[
                                                                            index]
                                                                        .promptSide1Content,
                                                                    side2type:
                                                                        "",
                                                                  );
                                                                },
                                                              ));
                                                              break;
                                                            case 'delete':
                                                              deletPrompt(promptId: state.def_prompt_list[index].promptId);
                                                              break;
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          childCount:
                                              state.def_prompt_list.length,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }
                              return Text("Something wents wrong");
                            },
                          );
                        },
                      ),
                    ],
                  )),
                ],
              ),
            )),
      ),
    );
  }

}

class ListItem {
  int index;
  bool isCheck;

  ListItem({required this.index, this.isCheck = false});
}

class BottomSheet extends StatefulWidget {
  String promptId;
  String promptName;
  String dialogId;
  List<AddResourceListModel> res_prompt_list;

  BottomSheet(
      {super.key,
      required this.promptName,
      required this.promptId,
      required this.dialogId,
      required this.res_prompt_list
      });

  @override
  State<BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet> {
  @override
  final Dio _dio = Dio();
  List<ListItem> itemCheck = [];
  String resId = "";
  String? resourceName;
  final AddPromptResCubit cubitAddPromptRes = AddPromptResCubit();

  void addingPromptInResource({required String dialogId, required String promptId, required String resourceId}) async{
    print("===----->${promptId}");
    var token = await SharedPref().getToken();
    final Map<String, dynamic> headers = {
      'Authorization': 'Bearer $token',
    };
    try{
      Response res = await _dio.patch("https://backend.savant.app/web/prompt/update/$promptId", options: Options(headers: headers),
          data: {
            "resourceId":resourceId,
            "categoryId":widget.dialogId
          }
      );
      if(res.statusCode==200){
        EasyLoading.showToast("prompt is successfully added");
        cubitAddPromptRes.getResPrompt(dailogId: dialogId);
        Navigator.pop(context);
        Navigator.pop(context);
      }
      else{
        EasyLoading.showToast("Error");
      }
    }catch(e){
      EasyLoading.showToast(e.toString());
      print("------${e.toString()}");
    }

  }
  Widget build(BuildContext context) {
    return Column(children: [
        SizedBox(
          height: 10,
        ),
        Text(
          "Choose Resource for ${widget.promptName}",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 20),
        ),
        SizedBox(
          height: 10,
        ),
     widget.res_prompt_list.length==0?Text("Resource is not available") :Container(
        height: MediaQuery
            .of(context)
            .size
            .height * 0.4, // Set the height
        child: ListView.builder(
          itemCount: widget.res_prompt_list.length,
          itemBuilder: (BuildContext context, int index) {
            String firstLetter =
            widget.res_prompt_list[index].resourceName.substring(0, 1);
            itemCheck.add(ListItem(index: index, isCheck: false));
            return Card(
              color: Colors.blue[50],
              child: ListTile(
                leading: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90),
                        color: Colors.red[200]),
                    child: Text(
                      firstLetter.toUpperCase(),
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    )),
                title: Text(widget.res_prompt_list[index].resourceName),
                trailing: itemCheck[index].isCheck
                    ? Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.red[200],
                        borderRadius: BorderRadius.circular(90)),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ))
                    : null,
                onTap: () {
                  resId = widget.res_prompt_list[index].resourceId;
                  resourceName = widget.res_prompt_list[index].resourceName;
                  print("-promptId${widget.promptId}");
                  print("-resid${resId}");
                  print("-dialogId${widget.dialogId}");
                  setState(() {
                    for (int i = 0; i < itemCheck.length; i++) {
                      if (i == index) {
                        itemCheck[i].isCheck = true;
                      } else {
                        itemCheck[i].isCheck = false;
                      }
                    }
                  });
                  // Define the action when a list item is tapped.
                  // You can add your logic here.
                },
              ),
            );
          },
        ),
      ),
        Spacer(),
        Container(
            width: MediaQuery.of(context).size.width * 0.98,
            height: 50,
            color: Colors.cyanAccent,
            child: ElevatedButton(
                onPressed: () {
                  print("onpress is $resourceName");
                  if (resId == "") {
                    EasyLoading.showError(
                        duration: Duration(seconds: 2), "please choose resource");
                  } else if (resId != "") {
                    addingPromptInResource(dialogId: widget.dialogId, promptId: widget.promptId, resourceId: resId);
                    /*context.read<AddPromptResCubit>().addpromptRes(
                        promptId: widget.promptId,
                        promptName: widget.promptName,
                        resourceId: resId,
                        resourceName: resourceName!,
                        context: context);*/
                  }
                },
                child: Text("Submit"))),
        SizedBox(
          height: 2,
        )
      ]);
  }
}

class SideSheetDrawer extends StatefulWidget {
  final AddPromptResCubit cubitAddPromptRes = AddPromptResCubit();
  String resourceId;
  String ResourceName;
  List<PromptListforResourceModel> resPromptList;

  SideSheetDrawer(
      {super.key,
      required this.resPromptList,
      required this.ResourceName,
      required this.resourceId});

  @override
  State<SideSheetDrawer> createState() => _SideSheetDrawerState();
}

class _SideSheetDrawerState extends State<SideSheetDrawer> {
  List<FlowDataModel> flowList = [];

  void initilizeflowList() {
    for (int index = 0; index < widget.resPromptList.length; index++) {
      flowList.add(FlowDataModel(
          resourceTitle: widget.ResourceName,
          resourceType: "text",
          resourceContent: "",
          side1Title: widget.resPromptList[index].promptSide1Content,
          side1Type: "",
          side1Content: widget.resPromptList[index].promptSide1Content,
          side2Title: widget.resPromptList[index].promptSide2Content,
          side2Type: "",
          side2Content: widget.resPromptList[index].promptSide2Content,
          promptName: widget.resPromptList[index].promptTitle,
          promptId: widget.resPromptList[index].promptId));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initilizeflowList();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    return BlocProvider(
      create: (context) => AddPromptResCubit()
        ..getPromptFromResource(resourceId: widget.resourceId),
      child: BlocBuilder<AddPromptResCubit, AddPromptResState>(
        builder: (context, state) {
          if (state is AddPromptResLoading) {
            return Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }
          if (state is GetPromptFromResourceSuccess) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.deepOrangeAccent[100],
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: Colors.deepOrangeAccent[100],
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    height: MediaQuery.of(context).size.height * 0.8,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: state.flowModel.length == 0
                        ? Center(
                            child: Text(
                            "sorry no prompt",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          ))
                        : ReorderableListView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            children: <Widget>[
                              for (int index = 0;
                                  index < state.flowModel.length;
                                  index += 1)
                                Container(
                                  height: 50,
                                  key: Key('$index'),
                                  color: Colors.green[100],
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      maxRadius: 17,
                                      backgroundColor: Colors.deepOrangeAccent,
                                      foregroundColor: Colors.black,
                                      child: Text(
                                        extractFirstLetter(
                                            flowList[index].promptName),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    trailing: Icon(Icons.menu),
                                    tileColor: index.isOdd
                                        ? oddItemColor
                                        : evenItemColor,
                                    title: Row(
                                      children: [
                                        Text(state.flowModel[index].promptName)
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                            onReorder: (int oldIndex, int newIndex) {
                              setState(() {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                //print(state.addFlowModel)
                                FlowDataModel item =
                                    state.flowModel.removeAt(oldIndex);
                                state.flowModel.insert(newIndex, item);
/*
                  PromtModel model = state.promtModel!.removeAt(oldIndex);
                  state.promtModel!.insert(newIndex, model);*/
                              });
                            },
                          ),
                  ),
                  state.flowModel.length == 0
                      ? SizedBox()
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SlideShowScreen(
                                            flowList: state.flowModel,
                                            flowName: "flowName")));
                              },
                              child: Text("Play prompts")),
                        )
                ],
              ),
            );
          }
          return Text("Something went wrong");
        },
      ),
    );
  }

  String extractFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text.substring(0, 1).toUpperCase();
  }
}

class BottomSheetForCreateFlow extends StatefulWidget {
  String dailogId;
  List<AddResourceListModel> reswithPromptList;
  List<AddPromptListModel> promptList;

  BottomSheetForCreateFlow(
      {super.key,
      required this.dailogId,
      required this.reswithPromptList,
      required this.promptList});

  @override
  State<BottomSheetForCreateFlow> createState() =>
      _BottomSheetForCreateFlowState();
}

class _BottomSheetForCreateFlowState extends State<BottomSheetForCreateFlow> {
  TextEditingController dailog_create_controller = TextEditingController();
  List<RespromptModel> resourcePromptList=[];
  AwesomeDialog createDailog() {
    return AwesomeDialog(
      context: context,
      headerAnimationLoop: true,
      animType: AnimType.TOPSLIDE,
      // Set the desired animation type
      // Adjust the animation duration
      dialogType: DialogType.SUCCES,
      customHeader: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            color: Colors.blue[100], borderRadius: BorderRadius.circular(90)),
        child: Icon(
          Icons.file_copy, // Change this to the desired icon
          size: 48.0, // Adjust the icon size
          color: Colors.red, // Change the icon color
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Create Flow',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: dailog_create_controller,
              decoration: InputDecoration(
                hintText: 'Dialog Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                ),
              ),
            ),
          )
        ],
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {
        if (dailog_create_controller.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              /// need to set following properties for best effect of awesome_snackbar_content
              elevation: 0,

              duration: Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: "Error",
                message: 'Dailog is not be empty!',

                /// change contentType to ContentType.success, ContentType.warning, or ContentType.help for variants
                contentType: ContentType.failure,
              ),
            ),
          );
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateDailogFlow(
                        respromptlist: resourcePromptList,
                        dailog_flow_name: dailog_create_controller.text,
                        promptList: widget.promptList,
                        dailogId: widget.dailogId,
                      )));
        }
      },
      btnOkColor: Colors.green,
      closeIcon: Icon(Icons.close),
      btnCancelOnPress: () {},
      btnOkText: "Create dailog",
    )..show();
  }
  void storeResourcePrompt({required String dialogId}) async {
    Response? res = await PromptResRepo.fethResourcePrompt(dialogId: dialogId);
    print("storeResourcePrompt ${res?.data}");

    if (res?.data != null) {
      print("9999999999${res?.data["resourcesWithPrompts"]}");
      List<dynamic> resourcesWithPrompts = res?.data['resourcesWithPrompts'];

      for (var item in resourcesWithPrompts) {
        Map<String, dynamic> resource = item['resource'];
        List<dynamic> prompts = item['prompts'];

        String resourceId = resource['_id'];
        String resourceTitle = resource['title'];

        List<PromptInsideResource> promptList = [];

        for (var promptItem in prompts) {
          String promptId = promptItem['_id'];
          String promptTitle = promptItem['name'];
          promptList.add(PromptInsideResource(
            promptId: promptId,
            promptTitle: promptTitle,
          ));
        }

        resourcePromptList.add(RespromptModel(
          resourceId: resourceId,
          resourceTitle: resourceTitle,
          promptList: promptList,
        ));
        print("---------->promptList${resourcePromptList[0].resourceTitle}");

      }
    }

    print("storeResourceis end");
    setState(() {});

  }
  @override
  void initState() {
    storeResourcePrompt(dialogId: widget.dailogId);
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    print("=-==-=-=>${resourcePromptList.length}");
    return BlocProvider(
      create: (context) =>
          AddPromptResCubit()..getFlowDialog(dailogId: widget.dailogId),
      child: BlocConsumer<AddPromptResCubit, AddPromptResState>(
        listener: (context, state) {
          if (state is GetFlowDeletedSuccess) {
            context
                .read<AddPromptResCubit>()
                .getFlowDialog(dailogId: widget.dailogId);
          }
        },
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              children: [
                BlocBuilder<AddPromptResCubit, AddPromptResState>(
                  builder: (context, state) {
                    if (state is AddPromptResLoading) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: double.infinity,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (state is AddPromptResError) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: double.infinity,
                        child: Center(
                          child: Text(state.errorMessage),
                        ),
                      );
                    }
                    if (state is GetFlowSuccess) {
                      if (state.flowList.length == 0) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          width: double.infinity,
                          child: Center(
                            child: Text("Sorry no flow is created"),
                          ),
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.menu, // Replace with your desired icon
                                size: 30.0,
                                color:
                                    Colors.blue, // Change the color as needed
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                color: Colors.white,
                                child: CustomScrollView(
                                  slivers: <Widget>[
                                    SliverGrid(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          print(
                                              "print flow list length ${state.flowList.length}");
                                          final title =
                                              state.flowList[index].title;
                                          final flowId =
                                              state.flowList[index].id;
                                          return Card(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            color: Colors.teal[50],
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: ListTile(
                                                onTap: () {
                                                  List<PromptListModel>
                                                      promptList = [];
                                                  state.flowList[index].flowList
                                                      .forEach((item) {
                                                    promptList.add(
                                                        PromptListModel(
                                                            item.promptName,
                                                            item.promptId,
                                                            Colors.green));
                                                  });
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddPromptsToFlowScreen(
                                                              keywords: [],
                                                          update: true,
                                                          title: title,
                                                          flowId: flowId,
                                                          promptList:
                                                              promptList,
                                                          rootId:
                                                              widget.dailogId,
                                                        ),
                                                      )).then((value) {
                                                    context
                                                        .read<CreateFlowBloc>()
                                                        .add(LoadAllFlowEvent(
                                                            catID: widget
                                                                .dailogId));
                                                  });
                                                },
                                                title: Text(state
                                                        .flowList[index]
                                                        .title ??
                                                    "flow title"),
                                                trailing: IconButton(
                                                  onPressed: () {
                                                    context.read<
                                                        AddPromptResCubit>()
                                                      ..getFlowDelete(
                                                          dailogId:
                                                              widget.dailogId,
                                                          context: context,
                                                          flowId: flowId,
                                                          flowList:
                                                              state.flowList,
                                                          deleteIndex: index);
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                leading: Container(
                                                  height: 40,
                                                  width: 40,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: Colors
                                                              .pinkAccent),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              90)),
                                                  child: Text("F"),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: state.flowList.length,
                                      ),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 2,
                                        childAspectRatio: 7.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Spacer(),
                            ],
                          ),
                        );
                      }
                    }
                    return Text("Some things went wrong");
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    // Other button styling options
                  ),
                  onPressed: () {
                    createDailog();
                  },
                  child: Text("Create flow"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BottomSheetForPrimaryFlow extends StatefulWidget {
  String dailogId;

  BottomSheetForPrimaryFlow({super.key, required this.dailogId});

  @override
  State<BottomSheetForPrimaryFlow> createState() =>
      _BottomSheetForPrimaryFlowState();
}

class _BottomSheetForPrimaryFlowState extends State<BottomSheetForPrimaryFlow> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AddPromptResCubit()..getFlowDialog(dailogId: widget.dailogId),
      child: BlocConsumer<AddPromptResCubit, AddPromptResState>(
        listener: (context, state) {
          if (state is GetFlowDeletedSuccess) {
            context
                .read<AddPromptResCubit>()
                .getFlowDialog(dailogId: widget.dailogId);
          }
        },
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              children: [
                BlocBuilder<AddPromptResCubit, AddPromptResState>(
                  builder: (context, state) {
                    if (state is AddPromptResLoading) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: double.infinity,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (state is AddPromptResError) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: double.infinity,
                        child: Center(
                          child: Text(state.errorMessage),
                        ),
                      );
                    }
                    if (state is GetFlowSuccess) {
                      if (state.flowList.length == 0) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          width: double.infinity,
                          child: Center(
                            child: Text("Sorry no flow is created"),
                          ),
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.menu, // Replace with your desired icon
                                size: 30.0,
                                color:
                                    Colors.blue, // Change the color as needed
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                color: Colors.white,
                                child: CustomScrollView(
                                  slivers: <Widget>[
                                    SliverGrid(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          print(
                                              "print flow list length ${state.flowList.length}");
                                          final title =
                                              state.flowList[index].title;
                                          final flowId =
                                              state.flowList[index].id;
                                          return Card(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            color: Colors.teal[50],
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: ListTile(
                                                onTap: () {
                                                  List<PromptListModel>
                                                      promptList = [];
                                                  state.flowList[index].flowList
                                                      .forEach((item) {
                                                    promptList.add(
                                                        PromptListModel(
                                                            item.promptName,
                                                            item.promptId,
                                                            Colors.green));
                                                  });
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddPromptsToFlowScreen(
                                                              keywords: [],
                                                          update: true,
                                                          title: title,
                                                          flowId: flowId,
                                                          promptList:
                                                              promptList,
                                                          rootId:
                                                              widget.dailogId,
                                                        ),
                                                      )).then((value) {
                                                    context
                                                        .read<CreateFlowBloc>()
                                                        .add(LoadAllFlowEvent(
                                                            catID: widget
                                                                .dailogId));
                                                  });
                                                },
                                                title: Text(state
                                                        .flowList[index]
                                                        .title ??
                                                    "flow title"),
                                                trailing: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .greenAccent[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              90)),
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                leading: Container(
                                                  height: 40,
                                                  width: 40,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: Colors
                                                              .pinkAccent),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              90)),
                                                  child: Text("F"),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: state.flowList.length,
                                      ),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 2,
                                        childAspectRatio: 7.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Spacer(),
                            ],
                          ),
                        );
                      }
                    }
                    return Text("Some things went wrong");
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BottomSheetforAddQuickPrompt extends StatefulWidget {
  String dialogId;

  BottomSheetforAddQuickPrompt({super.key, required this.dialogId});

  @override
  State<BottomSheetforAddQuickPrompt> createState() =>
      _BottomSheetforAddQuickPromptState();
}

class _BottomSheetforAddQuickPromptState
    extends State<BottomSheetforAddQuickPrompt> {
  Dio _dio = Dio();
  List<PromptCheckModel> promptList = [];
  List<String> promptId = [];

  bool showCheck = false;
  bool showSelectbtn = false;

  @override
  void initState() {
    context.read<QuickPromptBloc>().add(QuickAddPromptEvent());
    super.initState();
  }

  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewDialogDartCubit()..getQuickPromptList(),
      child: BlocBuilder<NewDialogDartCubit, NewDialogDartState>(
        builder: (context, state) {
          if (state is NewDialogPromptLoading) {
            return Container(
              height: MediaQuery.sizeOf(context).height * 0.9,
              width: double.infinity,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is NewDialogPromptSuccess) {
            if (state.promtModelList.length == 0) {
              return Container(
                  height: MediaQuery.sizeOf(context).height * 0.9,
                  width: double.infinity,
                  child: Text("Empty prompts"));
            } else {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: promptId.length >= 1
                                    ? Colors.green
                                    : (showCheck ? Colors.red : Colors.grey),
                                onPrimary:
                                    Colors.white, // Set the text color to white
                              ),
                              onPressed: () {
                                if (showCheck == true) {
                                  if (promptId.length <= 0) {
                                    showCheck = false;
                                    promptId.clear();
                                    promptList.clear();
                                    setState(() {});
                                  } else {
                                    context
                                        .read<AddPromptResCubit>()
                                        .promptUdateDialog(
                                            dialogId: widget.dialogId,
                                            promptId: promptId,
                                            context: context);

                                    // promptupdate(listpromtId: promptId, dialogId: widget.dialogId);
                                    // PromptResRepo.updatePrompt(listpromtId: promptId, dialogId: widget.dialogId,context: context);
                                  }
                                } else if (showCheck == false) {
                                  showCheck = true;
                                  setState(() {});
                                }
                              },
                              child: promptId.length >= 1
                                  ? Text("Add")
                                  : Text("Select"),
                            ),
                          )),
                    ),
                    SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          promptList.add(PromptCheckModel(
                              promptId: state.promtModelList[index].promptid
                                  .toString(),
                              isCheck: false));
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SlideShowScreen2(
                                        flowName: "",
                                            side1type: state
                                                .promtModelList[index].side1Type
                                                .toString(),
                                            side2type: state
                                                .promtModelList[index].side2Type
                                                .toString(),
                                            promptTitle: state
                                                .promtModelList[index]
                                                .promptname
                                                .toString(),
                                            side1contentTitle: state
                                                .promtModelList[index]
                                                .side1content
                                                .toString(),
                                            side2contentTitle: state
                                                .promtModelList[index]
                                                .side2content
                                                .toString(),
                                          )));
                            },
                            child: Card(
                              color: Colors.lightGreenAccent.shade100,
                              child: Stack(children: [
                                showCheck
                                    ? Align(
                                        alignment: Alignment.topRight,
                                        child: Checkbox(
                                          // Checkbox at the top left
                                          value: promptList[index].isCheck,
                                          // Initial value (you can use a state variable to manage it)
                                          onChanged: (bool? newValue) {
                                            if (promptList[index].isCheck ==
                                                true) {
                                              promptList[index].isCheck = false;
                                              promptId.remove(
                                                  promptList[index].promptId);

                                              print(promptId);
                                              setState(() {});
                                            } else if (promptList[index]
                                                    .isCheck ==
                                                false) {
                                              promptList[index].isCheck = true;
                                              promptId.add(
                                                  promptList[index].promptId);
                                              print(promptId);

                                              setState(() {});
                                            }
                                          },
                                        ),
                                      )
                                    : SizedBox(),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(state
                                      .promtModelList[index].promptname
                                      .toString()),
                                )
                              ]),
                            ),
                          );
                        },
                        childCount: state.promtModelList.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 2,
                        childAspectRatio: 10.0,
                      ),
                    )
                  ],
                ),
              );
            }
          }
          return Text("Something wents wrong");
        },
      ),
    );
  }
}
//jjkk