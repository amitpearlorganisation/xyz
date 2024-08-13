import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../schedule/notificationflowmodel.dart';
import '../../schedule/scheduleFlowsbook/scheduleFlowsBook.dart';
import '../../utilities/colors.dart';
import '../../utilities/notificationmangae.dart';
import '../../utilities/shared_pref.dart';
import '../create_flow/data/model/flow_model.dart';
import '../create_flow/slide_show_screen.dart';
import '../dailog_category/dailog_cate_screen.dart';
import 'bloc/get_dailog_bloc/get_dailog_bloc.dart';
import 'bloc/new_dailog/create_dialog_new/newDailogCreate.dart';
import 'bloc/new_dailog/new_dialog_dart_cubit.dart';
import 'create_dailog_screen.dart';
import 'dailogPrompt/dailog_prompt.dart';

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  print("Handling background dialof section message: ${message.messageId}");


  // Do something with the notification
}
class NewDialog extends StatefulWidget {
  const NewDialog({super.key});

  @override
  State<NewDialog> createState() => _NewDialogState();
}

class _NewDialogState extends State<NewDialog> {
  List<PromptCheckModel> promptList = [];
  List<String> promptId = [];
  bool showCheck = false;
  bool showSelectbtn = false;

  Color lightenRandomColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1.0);
    final int red = (color.red + (255 - color.red) * factor).round();
    final int green = (color.green + (255 - color.green) * factor).round();
    final int blue = (color.blue + (255 - color.blue) * factor).round();
    return Color.fromARGB(255, red, green, blue);
  }

  Color generateRandomColor() {
    final Random random = Random();
    final int red = random.nextInt(256); // 0-255 for the red channel
    final int green = random.nextInt(256); // 0-255 for the green channel
    final int blue = random.nextInt(256); // 0-255 for the blue channel
    final originalColor = Color.fromARGB(255, red, green, blue);
    final pastelColor = lightenRandomColor(originalColor, 0.8); // 30% lighter

    return pastelColor;
  }

  AwesomeDialog showDeleteDailog(
      {required String dailogName,
      required String dailogId,
      required int index,
      required BuildContext context}) {
    return AwesomeDialog(
        context: context,
        animType: AnimType.BOTTOMSLIDE,
        dialogType: DialogType.QUESTION,
        body: Center(
          child: Text(
            'Are you sure\nYou want to delete\n$dailogName',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        title: 'This is Ignored',
        desc: 'This is also Ignored',
        btnOkOnPress: () {
          context.read<GetDailogBloc>().add(DeleteDailogEvent(
              dailogId: dailogId, index: index, dailogName: dailogName));
        },
        btnOkColor: Colors.red,
        closeIcon: Icon(Icons.close),
        btnCancelOnPress: () {},
        btnOkText: "Delete",
        btnOkIcon: Icons.delete)
      ..show();
  }
  List<FlowModel> flowList = [];

  Future<void> fetchNotificationFlow({required String flowId, required RemoteMessage message}) async {
    if (!mounted) return; // Check if the widget is still mounted
    if(flowId.isNotEmpty){
      EasyLoading.show(status: "loading");
      NotificationFlow notificationFlow = NotificationFlow();
      flowList = await notificationFlow.getFlow(flowId: flowId);

      _handleNotificationClick(message: message, flowList: flowList);
      EasyLoading.dismiss();
    }else{
      EasyLoading.showToast("flow id is null");
      print("flow id is empty");
    }

    // Optionally, you can print or process the flowList here
    print("This is inside the notification flow ${flowList}");
  }

NewDialogDartCubit newDialogDartCubit = NewDialogDartCubit();
  Dio _dio = Dio();

  @override
  void initState() {
    // methodcheck();
    super.initState();
  }
  void updateNotificationValue() {
    Timer(Duration(seconds: 20), () {
      notificationManage.setnotiValue = true;
      print("Notification value updated to true after 30 seconds - ${notificationManage.getnotiValue}");
    });
  }

  NotificationManage notificationManage = NotificationManage();
  void _handleNotificationClick({required RemoteMessage message, required List<FlowModel> flowList}) {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>SlideShowScreen(
      flowList: flowList[0].flowList, flowName: flowList[0].title,
    ))).then((value) {
      setState(() {
        notificationManage.setnotiValue = false;
        print("setstate category - ${notificationManage.getnotiValue}");
        context.read<NewDialogDartCubit>().getQuickPromptList();
      });
      updateNotificationValue();
    });

  }
  firebaseFun() async {
    print("Initializing Firebase Messaging");

    requestNotificationPermission();

    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    String? token = await _firebaseMessaging.getToken();
    print("FCM token is $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received message: ${message.notification?.body}");
      showSimpleNotification(
        Text(message.notification?.title ?? ""),
        subtitle: Text(message.notification?.body ?? ""),
        background: Colors.red.shade700,
        duration: Duration(seconds: 2),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Received message: ${message.notification?.body}");
        print("on open app message");
        if(notificationManage.getnotiValue == true) {
          fetchNotificationFlow(
              flowId: message.data["id"], message: message);
        }
        else{
          print("Notification value is false");
        }      } else {
        print("Notification message is null");
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("Received initial message: $message");
        fetchNotificationFlow(
            flowId: message.data["id"], message: message);      }
    });
  }

  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: false,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  void methodcheck() async {
    await firebaseFun();
  }
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(

        ),
        body: Column(
          children: [
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
                  Text("Dialogs"),
                  Text("Folders"),
                ],
              ),
            ),
            Expanded(
                child: TabBarView(
              children: [
                BlocProvider(
                  create: (context) => newDialogDartCubit..getQuickPromptList(),
                  child: Scaffold(
                    floatingActionButton: Container(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            if (promptId.length == 0) {
                              EasyLoading.showToast("sorry no prompt select");
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewAddDailogScreen(
                                            promptId: promptId,
                                          )));
                            }
                          },
                          child: Text("Create dialog"),
                        )),
                    body:
                    BlocBuilder<NewDialogDartCubit, NewDialogDartState>(
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
                                child: Center(child: Text("Empty prompts")));
                          } else {
                            return
                              CustomScrollView(
                              slivers: <Widget>[
                                SliverToBoxAdapter(
                                  child: Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: promptId.length >= 1 ? Colors.green : (showCheck ? Colors.red : Colors.grey),
                                              onPrimary: Colors.white, // Set the text color to white
                                            ),
                                          onPressed: () {
                                            if (showCheck == true) {
                                              showCheck = false;
                                              promptId.clear();
                                              promptList.clear();
                                              setState(() {});
                                            } else if (showCheck == false) {
                                              showCheck = true;
                                              setState(() {});
                                            }
                                          },
                                          child: Text("select"),
                                        ),
                                      )),
                                ),
                                SliverGrid(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      promptList.add(PromptCheckModel(
                                          promptId: state
                                              .promtModelList[index].promptid
                                              .toString(),
                                          isCheck: false));
                                      return GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>SlideShowScreen2(
                                            flowName: "",
                                            side1type: state.promtModelList[index].side1Type.toString(),
                                            side2type: state.promtModelList[index].side2Type.toString(),
                                            promptTitle: state.promtModelList[index].promptname.toString(),
                                          side1contentTitle: state.promtModelList[index].side1content.toString(),
                                            side2contentTitle: state.promtModelList[index].side2content.toString(),
                                          )));
                                        },
                                        child: Card(
                                          child: Stack(children: [
                                            showCheck
                                                ? Align(
                                                    alignment: Alignment.topRight,
                                                    child: Checkbox(
                                                      // Checkbox at the top left
                                                      value:
                                                          promptList[index].isCheck,
                                                      // Initial value (you can use a state variable to manage it)
                                                      onChanged: (bool? newValue) {
                                                        if (promptList[index]
                                                                .isCheck ==
                                                            true) {
                                                          promptList[index]
                                                              .isCheck = false;
                                                          promptId.remove(
                                                              promptList[index]
                                                                  .promptId);

                                                          print(promptId);
                                                          setState(() {});
                                                        } else if (promptList[index]
                                                                .isCheck ==
                                                            false) {
                                                          promptList[index]
                                                              .isCheck = true;
                                                          promptId.add(
                                                              promptList[index]
                                                                  .promptId);
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
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 15,
                                    childAspectRatio: 2.0,
                                  ),
                                )
                              ],
                            );
                          }
                        }
                        return Text("Something wents wrong");
                      },
                    ),
                  ),
                ),
                BlocProvider(
                  create: (context) => GetDailogBloc()..add(HitGetDailogEvent()),
                  child: BlocListener<GetDailogBloc, GetDailogState>(
                    listener: (context, state) {
                      if (state is DailogDeleteSuccessfully) {
                        context.read<GetDailogBloc>().add(HitGetDailogEvent());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            /// need to set following properties for best effect of awesome_snackbar_content
                            elevation: 0,
                            duration: Duration(seconds: 5),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: AwesomeSnackbarContent(
                              title: state.dailogname,
                              message: 'Successfully deleted!',

                              /// change contentType to ContentType.success, ContentType.warning, or ContentType.help for variants
                              contentType: ContentType.success,
                            ),
                          ),
                        );
                      }

                      // TODO: implement listener
                    },
                    child: Scaffold(
                        floatingActionButton: FloatingActionButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddDailogScreen()));
                            },
                            child: Icon(Icons.add)),
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
                                  child: TextField(
                                    // controller: dailog_search_controller,
                                    onChanged: (val) {
                                      EasyLoading.showToast(val);
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      // Set the background color to transparent
                                      border: InputBorder.none,
                                      // Remove the border
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      // Adjust padding as needed
                                      suffixIcon: Icon(Icons.search),
                                    ),
                                  )),
                            ),
                            Expanded(
                              child: CustomScrollView(
                                slivers: <Widget>[
                                  SliverToBoxAdapter(
                                    child: BlocBuilder<GetDailogBloc,
                                        GetDailogState>(
                                      builder: (context, state) {
                                        print(state);

                                        print("Checking condion");
                                        if (state is GetDailogLoadingState) {
                                          print("Checking condion 2");

                                          return Container(
                                            alignment: Alignment.center,

                                            width: double.infinity,
                                            height: MediaQuery.of(context).size.height*0.8,
                                            child: Container(
                                              width: 50,
                                              height: 50,
                                              child: CircularProgressIndicator(
                                                  color: Colors.black),
                                            ),
                                          );
                                        }
                                        if (state is GetDailogSuccessState) {
                                          if (state.dailogList!.length == 0) {
                                            print("Checking condion 3");

                                            return Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8,
                                                width: double.infinity,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "Dailog is empty\nCreate Dailog",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1),
                                                ));
                                          } else {
                                            print("Checking condion 4");

                                            return
                                              Container(
                                              width: double.infinity,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.8,
                                              child:
                                              GridView.builder(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 2.0),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              600
                                                          ? 2
                                                          : MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  1200
                                                              ? 3
                                                              : 6,
                                                  childAspectRatio: 3 / 2,
                                                ),
                                                itemCount:
                                                    state.dailogList!.length,
                                                itemBuilder: (context, index) {
                                                  double containerHeight =
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              600
                                                          ? 140.0
                                                          : MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  1200
                                                              ? 200.0
                                                              : 300.0;
                                                  double containerWidth =
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              600
                                                          ? 150.0
                                                          : MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  1200
                                                              ? 300.0
                                                              : 300.0;
                                                  return Container(
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 10),
                                                    padding: EdgeInsets.zero,
                                                    height: 200,
                                                    width: 200,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    DailogCategoryScreen(
                                                                      promptList:
                                                                          state
                                                                              .promptList!,
                                                                      resourceList:
                                                                          state
                                                                              .resourceList!,
                                                                      dailoId: state
                                                                          .dailogList![
                                                                              index]
                                                                          .dailogId,
                                                                    )));
                                                      },
                                                      child: Card(
                                                          elevation: 2.0,
                                                          color:
                                                              generateRandomColor(),
                                                          child: Stack(
                                                            children: [
                                                              Center(
                                                                child: Text(state
                                                                    .dailogList![
                                                                        index]
                                                                    .dailogName),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child:
                                                                    PopupMenuButton(
                                                                  icon: Icon(
                                                                    Icons
                                                                        .more_vert,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  itemBuilder:
                                                                      (context) {
                                                                    return [
                                                                      const PopupMenuItem(
                                                                          value:
                                                                              'update',
                                                                          child: InkWell(
                                                                              child: Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Icon(
                                                                                Icons.update,
                                                                                color: primaryColor,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 8.0,
                                                                              ),
                                                                              Text("Update"),
                                                                            ],
                                                                          ))),
                                                                      const PopupMenuItem(
                                                                          value:
                                                                              'delete',
                                                                          child: InkWell(
                                                                              child: Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Icon(
                                                                                Icons.delete,
                                                                                color: primaryColor,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 8.0,
                                                                              ),
                                                                              Text("Delete"),
                                                                            ],
                                                                          )))
                                                                    ];
                                                                  },
                                                                  onSelected:
                                                                      (String
                                                                          value) {
                                                                    switch (
                                                                        value) {
                                                                      case 'update':
                                                                        /*Navigator.push(context, MaterialPageRoute(
                                                    builder: (context) {
                                                      return UpdateCateScreen(
                                                        rootId: state.cateList[index].sId,
                                                        selectedColor: currentColor,
                                                        categoryTitle: state.cateList[index].name,
                                                        tags: state.cateList[index].keywords,
                                                      );
                                                    },
                                                  ));*/
                                                                        break;
                                                                      case 'delete':
                                                                        showDeleteDailog(
                                                                            dailogName: state
                                                                                .dailogList![
                                                                                    index]
                                                                                .dailogName,
                                                                            index:
                                                                                index,
                                                                            dailogId: state
                                                                                .dailogList![
                                                                                    index]
                                                                                .dailogId,
                                                                            context:
                                                                                context);

                                                                        break;
                                                                    }
                                                                  },
                                                                ),
                                                              )
                                                            ],
                                                          )),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          }
                                        }

                                        if (state is GetDailogErrorState) {
                                          print("Checking condion 5");

                                          return Center(
                                            child: Text("Something went wrong"),
                                          );
                                        }
                                        print(state);
                                        print("Checking condion 6");

                                        return Center(
                                          child: Text("Something went wrong"),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                )
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class PromptCheckModel {
  String promptId;
  bool isCheck;

  PromptCheckModel({required this.promptId, required this.isCheck});
}
