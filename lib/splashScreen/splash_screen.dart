import 'dart:async';
import 'dart:math';

import 'package:fade_out_particle/fade_out_particle.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:self_learning_app/features/dashboard/dashboard_screen.dart';

import '../features/login/login_screen.dart';
import '../utilities/notificationmangae.dart';
import '../utilities/shared_pref.dart';
import '../widgets/pushnotification.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  bool msg = false;
  NotificationManage notificationManage = NotificationManage();
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    notificationManage.setnotiValue = true;
    methodcheck();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  void methodcheck() async{

    // _messagingService
    //     .init(context);
   Future.delayed(Duration(seconds: 2), () {
     SharedPref().getToken().then((token) {
       if (token != null) {

         print(token);
         Navigator.of(context).pushAndRemoveUntil(
           MaterialPageRoute(
             builder: (context) => DashBoardScreen(msgstatus: msg),
           ),
               (route) => false,
         ).then((value) {
           if(value==null){
             print("null conditon of splash scrreen");
             notificationManage.setnotiValue = true;

           }
           else{
             notificationManage.setnotiValue = true;

           }


         });
       } else {
         setState(() {
           Navigator.of(context).pushAndRemoveUntil(
             MaterialPageRoute(builder: (context) => LoginScreen()),
                 (route) => false,
           );
         });
       }
     }).catchError((error) {
       // Handle any errors that occur during token retrieval
       print('Error retrieving token: $error');
       setState(() {
         Navigator.of(context).pushAndRemoveUntil(
           MaterialPageRoute(builder: (context) => LoginScreen()),
               (route) => false,
         );
       });
     });
   });
  }

  @override

  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(255, 100, 90, 1), // Mixture of pink and red
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300, // Adjust width of the container
            height: 300, // Adjust height of the container
            child: Image.asset(
              "assets/icons/splash_logo.png",
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(height: 20), // Adjust spacing between text and image
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeOutParticle(
                disappear: true,
                child: Text('Savant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                  fontSize: 24
                ),),
                duration: Duration(seconds: 5),
              ),
              SizedBox(width: 20,),
              SpinKitWaveSpinner(
                color: Colors.greenAccent,
                size: 50.0,
                waveColor: Colors.greenAccent,
                trackColor: Colors.white12,
              ),
            ],
          ),

        ],
      ),
    );
  }
}
