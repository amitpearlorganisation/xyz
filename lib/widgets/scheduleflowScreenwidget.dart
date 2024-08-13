import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:overlay_support/overlay_support.dart';

import '../features/create_flow/data/model/flow_model.dart';
import '../features/create_flow/slide_show_screen.dart';
import '../schedule/cubit/scheduleflow_cubit.dart';
import '../schedule/notificationflowmodel.dart';
import '../schedule/scheduleFlowsbook/scheduleFlowsBook.dart';
import '../utilities/notificationmangae.dart';
import '../utilities/reqNotification.dart';
import 'dateTimePicker.dart';



@pragma("vm:entry-point")

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  String id =message.data['id'];
  print("Handling background schedule screen message: ${id}");
  // Do something with the notification
}
class ScheduleflowScreenWidget extends StatefulWidget {
  const ScheduleflowScreenWidget({super.key});

  @override
  State<ScheduleflowScreenWidget> createState() =>
      _ScheduleflowScreenWidgetState();
}

class _ScheduleflowScreenWidgetState extends State<ScheduleflowScreenWidget> {
  DateTime? currentDate;
  TimeOfDay? currentTime;

  @override
  void initState() {
    notificationManage.setnotiValue = true;

    super.initState();
    updateFisrtValue();
    methodcheck();

    currentDate = DateTime.now();
    currentTime = TimeOfDay.now();
    context.read<ScheduleflowCubit>().getFlow();
  }

  @override

  List<FlowModel> flowList = [];

  Future<void> fetchNotificationFlow({required RemoteMessage message}) async {
    if (!mounted) return; // Check if the widget is still mounted
    var flowId = message.data['id'];
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
  void updateNotificationValue() {

    Timer(Duration(seconds: 5), () {
      notificationManage.setnotiValue = true;
      print("Notification value updated to true after 5 seconds - ${notificationManage.getnotiValue}");
    });
  }

  void updateFisrtValue() {

    Timer(Duration(milliseconds: 400), () {
      notificationManage.setnotiValue = true;
      print("Notification value updated to true after 10 seconds - ${notificationManage.getnotiValue}");
    });
  }

  NotificationManage notificationManage = NotificationManage();

  void _handleNotificationClick({required RemoteMessage message, required List<FlowModel> flowList}) {
    if (!mounted) return; // Check if the widget is still mounted
    if(flowList[0].flowList.isNotEmpty && notificationManage.getnotiValue == true){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlideShowScreen(
            flowList: flowList[0].flowList,
            flowName: flowList[0].title,
          ),
        ),
      ).then((value) {
        if (!mounted) return; // Check if the widget is still mounted
        flowList.clear();
        setState(() {
          notificationManage.setnotiValue = false;
          print("setstate - ${notificationManage.getnotiValue}");
          context.read<ScheduleflowCubit>().getFlow();
        });
        updateNotificationValue();
      });
    }
    else{
      print("notification value is empty");
    }

  }
  firebaseFun() async {
    print("Initializing Firebase Messaging");

    await CheckRequestNotification().requestNotificationPermission();

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
      print("on open message");
      if (message.notification != null) {
        print("Received message: ${message.data['id']}");
        fetchNotificationFlow(
            message: message);
      } else {
        print("Notification message is null");
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      print("Notification this is intital message 1");
      String? flowId = message?.data['id'];
        print("flow id in intial ${flowId}");
      if (message?.notification != null) {

        fetchNotificationFlow(
             message: message!);



      } else {
        print("Notification this is intital message is run is null");
      }
    });
  }


  void methodcheck() async {
    await firebaseFun();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ScheduleFlowBook())).then((value) {
                  setState(() {
                    context.read<ScheduleflowCubit>().getFlow();

                  });
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Schedule Flows"),
          )),
      body: BlocConsumer<ScheduleflowCubit, ScheduleflowState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return BlocBuilder<ScheduleflowCubit, ScheduleflowState>(
            builder: (context, state) {
              if (state is ScheduleFlowLoading) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                );
              }
              if (state is ScheduleFlowLoaded) {
                if (state.flowList == 0 || state.flowList!.isEmpty) {
                  return Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: Center(child: Text("!No flows ")),
                  );
                } else {
                  return CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {

                                print("the flow id ${state.flowList![index].id}");
                                // Navigate to the string screen
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                height: 70,
                                child: Card(
                                  color: Colors.white,
                                  elevation: 1,
                                  child: Center(
                                    child: ListTile(
                                      title: Text(
                                        state.flowList![index].title,
                                      ),
                                      trailing: IconButton(
                                        onPressed: () {
                                          print("we can see flow id ${state.flowList![index].id}");
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return DateTimePickerDialog(
                                                initialDate: currentDate!,
                                                initialTime: currentTime!,
                                                flowId:
                                                    state.flowList![index].id,
                                                flowname: state.flowList![index].title,
                                              );
                                            },
                                          ).then((value) {
                                            setState(() {
                                              notificationManage.setnotiValue=true;
                                              context
                                                  .read<ScheduleflowCubit>()
                                                  .getFlow();
                                            });
                                          });
                                        },
                                        icon: Icon(Icons.calendar_month),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: state.flowList!.length,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: 80), // Adjust the height to match the size of your FloatingActionButton
                      ),
                    ],
                  );
                }
              }
              return Center(child: Text("Some Things went wrong"));
            },
          );
        },
      ),
    );
  }
}
