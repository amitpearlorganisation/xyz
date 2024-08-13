import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:self_learning_app/features/dailog_category/bloc/add_prompt_res_cubit.dart';

import 'package:self_learning_app/utilities/extenstion.dart';

import '../../utilities/shared_pref.dart';
import '../camera/camera_screen.dart';
import '../promt/promts_screen.dart';
import '../quick_add/data/bloc/quick_add_bloc.dart';
import '../quick_add/quick_add_screen.dart';
import '../resources/bloc/resources_bloc.dart';
import '../resources/resources_screen.dart';
import 'bloc/add_media_bloc.dart';

class AddTextScreen extends StatefulWidget {
  final String rootId;
  final int whichResources;
  final String? resourceId;
  const AddTextScreen({Key? key, required this.rootId,required this.whichResources,this.resourceId}) : super(key: key);

  @override
  State<AddTextScreen> createState() => _AddTextScreenState();
}

final TextEditingController resourceTitleController = TextEditingController();
final TextEditingController resourceContentContoller = TextEditingController();

class _AddTextScreenState extends State<AddTextScreen> {
  AddMediaBloc addMediaBloc = AddMediaBloc();


  @override
  void initState() {
    resourceTitleController.clear();
    resourceContentContoller.clear();
    super.initState();
  }

  Future<void> postData(
      {required String content, required String title}) async {
    EasyLoading.show();

    var token = await SharedPref().getToken();
    var dio = Dio();
    final url = 'https://backend.savant.app/web/resource';

    // Data to be sent
    Map<String, dynamic> data = {
      "title": title,
      "type": "text",
      "content": content,
      "rootId": widget.rootId
    };

    try {
      var response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: {"Authorization": 'Bearer $token'},
        ),
      );
      EasyLoading.dismiss();
      if (response.statusCode == 201 || response.statusCode == 200) {
        EasyLoading.showSuccess("${title} is successfully created");
        Future.delayed(Duration(seconds: 2));
        Navigator.pop(context, true);
      } else {
        print('Failed to post data: ${response.statusCode}');
        EasyLoading.showError("Somethings went wrong");
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Somethings went wrong");

      print('Error occurred: $e');
    }
  }

  @override


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add Text Resource')),
        backgroundColor: const Color(0xFFEEEEEE),
        body: Column(
          children: [
            Spacer(),
            Container(
              padding: EdgeInsets.all(10),
              height: context.screenHeight * 0.15,
              width: context.screenWidth,
              child: TextField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(80),
                ],
                style: TextStyle(fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.red),
                controller: resourceTitleController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                  hintText: 'Enter Title here...',
                  hintStyle: TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w500),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0))
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              width: double.infinity,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.1,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(width: 1.5, color: Colors.grey.shade200)
              ),
              child: TextField(
                controller: resourceContentContoller,
                maxLines: 8,
                style: TextStyle(letterSpacing: 2, color: Colors.black87),
                decoration: InputDecoration(

                  hintText: 'Enter text .....',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  if(resourceTitleController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Title required!')));
                  }
                  if(resourceContentContoller.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('content required!')));
                  }

                  if (resourceTitleController.text != '' && resourceTitleController.text !="") {
                    postData(title: resourceTitleController.text,
                        content: resourceContentContoller.text);
                  } else {

                  }
                },
                child: const Text('Upload Resource')),
            Spacer(flex: 3,),
          ],
        ));
  }
}
