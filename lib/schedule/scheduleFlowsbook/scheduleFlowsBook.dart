import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:self_learning_app/features/dashboard/dashboard_screen.dart';

import '../../features/create_flow/show_prompts_screen.dart';
import '../../features/create_flow/slide_show_screen.dart';
import '../../utilities/notificationmangae.dart';
import '../../utilities/shared_pref.dart';
import '../cubit/scheduleflow_cubit.dart';

class ScheduleFlowBook extends StatefulWidget {
  @override
  _ScheduleFlowBookState createState() => _ScheduleFlowBookState();
}

class _ScheduleFlowBookState extends State<ScheduleFlowBook> {
  late Timer _timer;
  NotificationManage notificationManage = NotificationManage();

  @override
  void initState() {
    context.read<ScheduleflowCubit>()..getScheduledFlow();
    startTimer(); // Start the timer
    super.initState();
  }


  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    // Start a timer that updates the UI every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Update the UI with the current remaining time
      setState(() {});
    });
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toUtc(); // Parse and convert to local timezone
    String formattedDateTime = DateFormat('yyyy-MM-dd hh:mm a').format(dateTime); // Format date and time in AM/PM format
    return formattedDateTime;
  }

  // String calculateCountdown(String dateString) {
  //   DateTime selectedTime = DateTime.parse(dateString).toUtc();
  //   var currentTime = DateTime.now();
  //   var Ist = selectedTime.subtract(Duration(hours: 4));
  //
  //   // Calculate the difference as a Duration
  //   Duration difference = Ist.difference(currentTime);
  //
  //   // Check if the duration is negative
  //   bool isTimerZero = difference.isNegative;
  //
  //   // Convert the duration to its absolute value
  //   difference = difference.abs();
  //
  //   int days = difference.inDays;
  //   int hours = difference.inHours.remainder(24);
  //   int minutes = difference.inMinutes.remainder(60);
  //   int seconds = difference.inSeconds.remainder(60);
  //
  //   // Format the countdown string
  //   return isTimerZero
  //       ? 'Time passed'
  //       : '$days d\n${hours.toString().padLeft(2, '0')} hr ${minutes.toString().padLeft(2, '0')} min\n${seconds.toString().padLeft(2, '0')} sec';
  // }

  String calculateCountdown(String dateString) {
    DateTime selectedTime = DateTime.parse(dateString).toUtc();
    DateTime currentTime = DateTime.now();

    // Check if current time is in IST
    bool isCurrentTimeInIST = currentTime.timeZoneOffset == Duration(hours: 5, minutes: 30);

    // Adjust selected time based on current time zone
    DateTime adjustedSelectedTime;
    if (isCurrentTimeInIST) {
      adjustedSelectedTime = selectedTime.subtract(Duration(hours: 5, minutes: 30));
    } else {
      adjustedSelectedTime = selectedTime.subtract(Duration(hours: 6));
    }

    // Calculate the difference as a Duration
    Duration difference = adjustedSelectedTime.difference(currentTime);

    // Check if the duration is negative
    bool isTimerZero = difference.isNegative;

    // Convert the duration to its absolute value
    difference = difference.abs();

    int days = difference.inDays;
    int hours = difference.inHours.remainder(24);
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    // Format the countdown string
    return isTimerZero
        ? 'Time passed'
        : '$days d\n${hours.toString().padLeft(2, '0')} hr ${minutes.toString().padLeft(2, '0')} min\n${seconds.toString().padLeft(2, '0')} sec';
  }
  Future<void> deleteFlow({required String flowId, required String flowName}) async {
    Dio dio = Dio();
    EasyLoading.show();
    var token = await SharedPref().getToken();
    final Map<String, dynamic> headers = {
      'Authorization': 'Bearer $token',
    };
    try {

      // Create Dio instance

      // Make the delete request
      Response response = await dio.delete(
        'https://backend.savant.app/web/flow/subFlow/$flowId',
        options: Options(
          headers:headers,
        ),
      );

      // Check the status code and show appropriate message
      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        EasyLoading.showSuccess('$flowName ScheduleFlow Deleted successfully');
        setState(() {
          context.read<ScheduleflowCubit>()..getScheduledFlow();
        });
      } else if (response.statusCode == 400) {
        EasyLoading.dismiss();
        EasyLoading.showError('Something went wrong');
      }
    } catch (e) {
      EasyLoading.dismiss();
      print("delete${e.toString()}");
      // Show error message in case of exception
      EasyLoading.showError(e.toString());
    }
  }

  AwesomeDialog showDeleteFlow({
    required String FlowName,
    required String FlowId,
    required BuildContext context,
  }) {
    return AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      dialogType: DialogType.QUESTION,
      body: Center(
        child: Text(
          'Are you sure\nYou want to delete\n$FlowName',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {
        deleteFlow(flowName: FlowName, flowId: FlowId);
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
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     DashBoardScreen(msgstatus: false,);
      //   },
      // ),
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context, true);
        }, icon: Icon(Icons.arrow_back)),
        title: Text("Schedule flows"),
      ),
      body: BlocBuilder<ScheduleflowCubit, ScheduleflowState>(
        builder: (context, state) {
          if (state is ScheduleFlowLoading) {
            return Center(
              child: Container(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is ScheduleDateLoaded) {
            if (state.dateflowList!.isEmpty) {
              return Center(child: Text("No flow is added"));
            } else {
              debugPrint('Notification Scheduled for ${state.dateflowList![0].dateTime}');
              DateTime dateTime = DateTime.parse(state.dateflowList![0].dateTime!).toUtc();
              print("local time is checking now ${dateTime}");
              var time = DateTime.parse(dateTime.toString()).toUtc();
              print("American time Zone ${time.subtract(Duration(hours: 4))}");

              // alram(dateTime: dateTime);
              return CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        int currentIndex = 1 + index;
                        return GestureDetector(
                          onTap: () {
                            // Navigate to the string screen
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.grey.shade200, width: 1.5),
                            ),
                            child: ListTile(
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(45),
                                    ),
                                    child: Text(currentIndex.toString()),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    state.dateflowList![index].title,
                                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  calculateCountdown(state.dateflowList![index].dateTime.toString()) == "Time passed"
                                      ? IconButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                                          return SlideShowScreen(
                                            flowList: state.dateflowList![index].flowList,
                                            flowName: state.dateflowList![index].title,
                                          );
                                        }));
                                      },
                                      icon: Icon(Icons.play_arrow)
                                  )
                                      : Text(
                                    calculateCountdown(state.dateflowList![index].dateTime.toString()),
                                    style: TextStyle(fontWeight: FontWeight.w300),
                                  ),
/*
                                  IconButton(
                                      onPressed: () {
                                        showDeleteFlow(context: context, FlowId: state.dateflowList![index].id,FlowName:state.dateflowList![index].title );
                                        // Call your delete function here, for example:
                                      },
                                      icon: Icon(Icons.delete)
                                  ),
*/
                                ],
                              ),

                              subtitle: Container(
                                padding: EdgeInsets.only(left: 35),
                                child: Text(formatDateTime(state.dateflowList![index].dateTime.toString())),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: state.dateflowList!.length,
                    ),
                  ),
                ],
              );
            }
          }
          if (state is ScheduleFlowError) {
            return Center(child: Text("Server error"));
          }
          return Center(child: Text("Something went wrong"));
        },
      ),
    );
  }
}
