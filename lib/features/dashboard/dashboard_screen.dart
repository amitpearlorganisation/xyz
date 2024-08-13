import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:self_learning_app/features/login/login_screen.dart';
import 'package:self_learning_app/schedule/schedule.dart';
import 'package:self_learning_app/schedule/scheduleFlowsbook/scheduleFlowsBook.dart';
import 'package:self_learning_app/utilities/colors.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../schedule/cubit/scheduleflow_cubit.dart';
import '../../widgets/pushnotification.dart';
import '../add_Dailog/dailog_screen.dart';
import '../add_Dailog/newDialog.dart';
import '../add_category/add_cate_screen.dart';
import '../category/category_screen.dart';
import 'bloc/dashboard_bloc.dart';



class DashBoardScreen extends StatefulWidget {
  bool msgstatus;
  DashBoardScreen({required this.msgstatus});

  static const TextStyle optionStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  static List<Widget> _widgetOptions = <Widget>[
    AllCateScreen(),
    AddCateScreen(),
    NewDialog(),
    Schedule(),
    // DailogScreen(),
  ];

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  StreamSubscription<RemoteMessage>? _messageSubscription;

  bool checkNoti = true;

  @override
  void initState() {
    super.initState();
    // methodcheck();
  }



  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> logout() async {
    EasyLoading.show();
    try {
      var token = await SharedPref().getToken();

      // Decode JWT to get the user ID
      Map<String, dynamic> payload = Jwt.parseJwt(token!);
      String? userId = payload["id"];  // Adjust according to your JWT structure

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'bearer $token';

      // Make the POST request using Dio
      Response response = await dio.post(
        'https://backend.savant.app/web/user/logout',
        data: {
          "userId": userId,
          "deviceToken": token
        },
      );
EasyLoading.dismiss();
      if (response.statusCode == 200) {

        EasyLoading.showSuccess('Logout successful');

        // Clear shared preferences
        await SharedPref().sClear();
        await SharedPref().clear().then((value) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const LoginScreen();
              },
            ),
                (route) => false,
          );
        });      }

      else {
        EasyLoading.dismiss();
        EasyLoading.showError('Something went wrong');
      }

      print(response.data);
    } catch (error) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: $error');
      print('Error: $error');
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: BlocBuilder<DashboardBloc, int>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white70,
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset('assets/savant.png'),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    context.showNewDialog(AlertDialog(
                      title: const Text(
                        'Are you sure you want to logout?',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      actions: [
                        MaterialButton(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          shape: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          color: Colors.white,
                          textColor: primaryColor,
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            print("hello logout");
                            await logout();
                          },
                          child: Text('Logout'),
                        ),
                      ],
                    ));
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
              centerTitle: true,
              title: const Text('DashBoard'),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.shifting,
              enableFeedback: true,
              showUnselectedLabels: true,
              selectedItemColor: Colors.white,
              elevation: 0,
              currentIndex: state,
              onTap: (value) {
                context.read<DashboardBloc>().ChangeIndex(value);
              },
              unselectedItemColor: Colors.white,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                  backgroundColor: primaryColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.create),
                  label: '   Create \n Category',
                  backgroundColor: primaryColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: '  Create \n Dailogs',
                  backgroundColor: primaryColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_sharp),
                  label: 'Schedule',
                  backgroundColor: primaryColor,
                ),
              ],
            ),
            body: Center(
              child: DashBoardScreen._widgetOptions.elementAt(state),
            ),
          );
        },
      ),
      onWillPop: () {
        return Future.value(true);
      },
    );
  }
}