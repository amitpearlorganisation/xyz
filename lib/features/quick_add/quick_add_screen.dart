import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:self_learning_app/features/dashboard/dashboard_screen.dart';
import 'package:self_learning_app/features/quick_add/data/bloc/quick_add_bloc.dart';
import 'package:self_learning_app/features/quick_add/data/repo/quick_add_repo.dart';
import 'package:self_learning_app/features/quick_add/prompt_add_in_dialog.dart';
import 'package:self_learning_app/features/quick_import/quick_add_import_screen.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

import '../../widgets/view_resource.dart';
import '../add_Dailog/bloc/new_dailog/create_dialog_new/newDailogCreate.dart';
import '../quick_import/repo/quick_add_repo.dart';
import 'PromptBloc/quick_prompt_bloc.dart';

class QuickTypeScreen extends StatefulWidget {
  const QuickTypeScreen({Key? key}) : super(key: key);

  @override
  State<QuickTypeScreen> createState() => _QuickTypeScreenState();
}

class _QuickTypeScreenState extends State<QuickTypeScreen> {
  // final QuickAddBloc quickAddBloc=QuickAddBloc();
  @override

  List<String> promptId = [];

  void initState() {
    // triggerEvent();

    super.initState();
    context.read<QuickAddBloc>().add(LoadQuickTypeEvent());
    context.read<QuickPromptBloc>().add(QuickAddPromptEvent());
  }
  AwesomeDialog updateResource({
    required String sId,
    required String resourceId,
    required String mediaType,
    required String resourceContent,
    required String resourceTitle

  }) {
    TextEditingController updateResourceController = TextEditingController(text: resourceTitle);
    print("sid--$sId");
    print("rootId--$resourceId");
    // 662f2b1ff151e91aba2bbd69
    // 6515391d6b4ba0023446e1d3

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
          await  QuickImportRepo.updateResources(rootId: "6646c8d8f151e91aba2c456c",resourceId: "6515391d6b4ba0023446e1d3" ,
              mediaType: mediaType, resourceTitle: updateResourceController.text,
              resourceContent: resourceContent ).then((value) {
            setState(() {
              context.read<QuickAddBloc>().add(LoadQuickTypeEvent());

              // context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: widget.mediaType));

            });
          });

        },
        btnOkColor: Colors.green.shade300,
        closeIcon: Icon(Icons.close),
        btnCancelOnPress: () {},
        btnOkText: "Update",
        btnOkIcon: Icons.update)
      ..show();
  }

  AwesomeDialog showResource({
    required String resId,
    required BuildContext context,
  }) {
    return AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      dialogType: DialogType.QUESTION,
      body: Center(
        child: Text(
          'Are you sure\nYou want to delete resource',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {
        context.read<QuickAddBloc>().add(QuickDeleteResource(id: resId, context: context));

      },
      btnOkColor: Colors.red,
      closeIcon: Icon(Icons.close),
      btnCancelOnPress: () {},
      btnOkText: "Delete",
      btnOkIcon: Icons.delete,
    )..show();
  }
  AwesomeDialog promptdelete({
    required String promptId,
    required BuildContext context,
    required String promptName,
    required int index
  }) {
    return AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      dialogType: DialogType.QUESTION,
      body: Center(
        child: Text(
          'Are you sure\nYou want to delete $promptName',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {
        context.read<QuickPromptBloc>().add(DeleteQuickPromptEvent(promptName: promptName,promptId: promptId,index:index
        ));
      },
      btnOkColor: Colors.red,
      closeIcon: Icon(Icons.close),
      btnCancelOnPress: () {},
      btnOkText: "Delete",
      btnOkIcon: Icons.delete,
    )..show();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
              title: const Text('Quick Adds'),
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Resource List'),
                  Tab(text: 'Prompt List'),
                ],
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return  DashBoardScreen(msgstatus: false,);
                    },
                  ));
                },
              )),
          body: TabBarView(
            children: [
              BlocConsumer<QuickAddBloc, QuickAddState>(
                builder: (context, state) {
                  print(state);
                  if (state is QuickAddLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is QuickAddLoadedState) {
                    var list =
                        state.list!.data!.record!.records!.reversed.toList();
                    if (list.isEmpty) {
                      return const Center(
                        child: Text('No quick adds found.'),
                      );
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, top: 10, bottom: 5),
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                            key: const ValueKey(0),
                            startActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              dismissible: DismissiblePane(onDismissed: () {
                                QuickAddRepo.deletequickAdd(
                                    id: list[index].sId!, context: context);
                                context
                                    .read<QuickAddBloc>()
                                    .add(LoadQuickTypeEvent());
                              }),
                              children: [

                                SlidableAction(

                                  onPressed: (context) {
                                    QuickAddRepo.deletequickAdd(
                                        id: list[index].sId!, context: context);
                                    context
                                        .read<QuickAddBloc>()
                                        .add(LoadQuickTypeEvent());
                                  },
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',

                                ),

                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding:
                                    const EdgeInsets.only(top: 7, bottom: 7),
                                decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10)),
                                //height: context.screenHeight*0.08,
                                child: Center(
                                  child: ListTile(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewResource(
                                        title: list[index].title.toString(),
                                        content: list[index].content.toString(),
                                      )));
                                    },
                                      leading: getType(list[index]
                                                  .type
                                                  .toString()) ==
                                              'image'
                                          ? const Icon(Icons.image)
                                          : getType(list[index]
                                                      .type
                                                      .toString()) ==
                                                  'video'
                                              ? const Icon(Icons
                                                  .video_camera_back_outlined)
                                              : getType(list[index]
                                                          .type
                                                          .toString()) ==
                                                      'audio'
                                                  ? const Icon(Icons.audiotrack)
                                                  : Icon(Icons.text_format),
                                      title:
                                          Text(list[index].title ?? 'Untitled'),
                                      trailing: SizedBox(
                                        width: context.screenWidth / 3.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                print(list[index].sId!);
                                                Navigator.push(context,
                                                    CupertinoPageRoute(
                                                  builder: (context) {
                                                    return QuickAddImportScreen(
                                                      mediaType: getType(
                                                          list[index]
                                                              .type
                                                              .toString()),
                                                      quickAddId:
                                                          list[index].sId!,
                                                      title:
                                                          list[index].title ??
                                                              'Image Type',
                                                      resourcecontent: list[
                                                                  index]
                                                              .content ??
                                                          "resource content",
                                                    );
                                                  },
                                                ));
                                              },
                                              icon: Icon(Icons.add),
                                            ),
                                            IconButton(onPressed: (){
                                             showResource(resId: list[index].sId!, context: context);

                                            }, icon: Icon(Icons.delete)),
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                  return const Center(
                    child: Text('Something Went Wrong'),
                  );
                },
                listener: (BuildContext context, Object? state) {
                  if(state is QuickResourceDelete){
                    EasyLoading.showSuccess("Quick Resource Delete Successfully");
                    setState(() {
                      context.read<QuickAddBloc>().add(LoadQuickTypeEvent());
                      context.read<QuickPromptBloc>().add(QuickAddPromptEvent());
                    });
                  }
                },
              ),
              BlocConsumer<QuickPromptBloc, QuickPromptState>(
                builder: (context, state) {
                  print(state);
                  if (state is QuickAddLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is QuickPromptAddLoadedState) {
                    if (state.list!.isEmpty) {
                      return const Center(
                          child: Text('No quick prompts found.'));
                    }
                    if (state is QuickAddErrorState) {
                      return Center(child: Text('Error'));
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, top: 10, bottom: 5),
                        shrinkWrap: true,
                        itemCount: state.list?.length,
                        itemBuilder: (context, index) {
                          print("prompt list name ${state.list?.length}");

                          return Slidable(
                            key: const ValueKey(0),
                            startActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              dismissible:
                                  DismissiblePane(onDismissed: () async {
                                context.read<QuickPromptBloc>().add(
                                    DeleteQuickPromptEvent(
                                        promptId: state.list![index].promptid,
                                        promptName:
                                            state.list![index].promptname,
                                        index: index));
                              }),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    /*    QuickAddRepo.deletequickAdd(
                                      id: list[index].sId!, context: context);
                                  context
                                      .read<QuickAddBloc>()
                                      .add(LoadQuickTypeEvent());*/
                                  },
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding:
                                    const EdgeInsets.only(top: 7, bottom: 7),
                                decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10)),
                                //height: context.screenHeight*0.08,
                                child: Center(
                                  child: ListTile(
                                      leading: Text("P"),
                                      title: Text(
                                          state.list![index].promptname ??
                                              "Untitle"),
                                      trailing: SizedBox(
                                        width: context.screenWidth / 3.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                // print(list[index].sId!);
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text('Add Prompt'),
                                                      content: Container(
                                                        width: MediaQuery.of(context).size.width*0.4,
                                                        height: MediaQuery.of(context).size.height*0.3,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                                'Choose a folder type:'),
                                                            SizedBox(height: MediaQuery.of(context).size.height*0.1,),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                promptId.clear();
                                                                promptId.add(state.list![index].promptid.toString());
                                                                print("promptIds---->${promptId}");
                                                                Navigator.push(context,
                                                                    MaterialPageRoute(
                                                                    builder: (context) => NewAddDailogScreen(
                                                                      promptId: promptId,
                                                                    )));

                                                                },
                                                                // Handle New Folder button click

                                                              child: Text(
                                                                  'New Folder'),
                                                            ),
                                                            SizedBox(height: 10,),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.push(context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => PromptAddingInDialog(
                                                                          promptId: state.list![index].promptid.toString(),
                                                                        )));
                                                              },
                                                              child: Text(
                                                                  'Existing Folder'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              icon: Icon(Icons.add),
                                            ),
                                            IconButton(
                                                onPressed: (){
                                                  promptdelete(context: context,promptId:state.list![index].promptid.toString(),
                                                  promptName: state.list![index].promptname.toString(),
                                                    index: index
                                                  );
                                                },
                                                icon: Icon(Icons.delete),),
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                listener: (BuildContext context, Object? state) {
                  if(state is QuickPromptDeletingSuccess){
                    setState(() {
                      context.read<QuickAddBloc>().add(LoadQuickTypeEvent());
                      context.read<QuickPromptBloc>().add(QuickAddPromptEvent());
                    });
                  }

                },
              ),
            ],
          )),
    );
  }
}

String getType(String type) {
  switch (type) {
    case 'QUICKADD-image':
      return 'image';
    case 'QUICKADD-video':
      return 'video';
    case 'QUICKADD-audio':
      return 'audio';
    case 'QUICKADD-text':
      return 'text';
    default:
      return 'unknown'; // Handle unknown types or provide a default value
  }
}

//#ggggggggggggggg
