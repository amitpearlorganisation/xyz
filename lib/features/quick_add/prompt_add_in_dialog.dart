import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../utilities/colors.dart';
import '../../utilities/shared_pref.dart';
import '../add_Dailog/bloc/get_dailog_bloc/get_dailog_bloc.dart';
import '../add_Dailog/bloc/new_dailog/new_dialog_dart_cubit.dart';
import '../add_Dailog/create_dailog_screen.dart';
import '../add_Dailog/model/addDailog_model.dart';
import '../dailog_category/dailog_cate_screen.dart';

class PromptAddingInDialog extends StatefulWidget {
  String promptId;
   PromptAddingInDialog({Key? key, required this.promptId}) : super(key: key);

  @override
  State<PromptAddingInDialog> createState() => _PromptAddingInDialogState();
}

class _PromptAddingInDialogState extends State<PromptAddingInDialog> {
  String selectedDialogId = '';
  int selectedIndex = 0; // Set the initial index


  List<DialogModel> getDialogList = [];
  final Dio _dio = Dio();
  void getDailog() async{
    var token = await SharedPref().getToken();

    Map<String, dynamic> headers = {
      'Authorization': 'bearer' + ' ' + token.toString(),
    };
    try{
      Response res = await _dio.get("https://backend.savant.app/web/category/get-dialogs",  options: Options(headers: headers));
      if(res.data['message']=="No Dialogs found!!"){

      }
      else {
        List<dynamic> dialogs = res!.data['dialogs'];

        for (var dialog in dialogs) {
          String dailogId = dialog['_id'];
          String userId = dialog['userId'];
          String dailogName = dialog['name'];
          print("dailogId=$dailogId");

          getDialogList.add(DialogModel(
            dialogId: dailogId,
            diaogName: dailogName
          ));
          setState(() {

          });
          print("dddddpppp"+getDialogList[0].diaogName);
        }
      }
    }
    catch(e){
      print("error ${e.toString()}");
    }

  }
  String? dialogId;
  void updatePrompt({required String promtId, required String dialogId, required BuildContext context})async{

    List<String> listpromtId =[];
    listpromtId.clear();
    listpromtId.add(promtId);
    print("=-===-=-===-=-===--=>$listpromtId");
    String? token = await SharedPref().getToken();
    final Map<String, dynamic> headers = {
      'Authorization': 'Bearer $token',
    };
    try{

      Response res = await _dio.patch("https://backend.savant.app/web/prompt/update/$dialogId",
          options: Options(headers: headers),
          data: ({"promptIds":listpromtId,
            "categoryId":dialogId
          })
      );
      print("update prompt list -------> ${res.statusCode}");
      if(res.statusCode ==200){
        EasyLoading.showSuccess("prompt add successfully", duration: Duration(seconds: 1));
        await Future.delayed(Duration(seconds: 1));
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);


      }

    }catch(e){
      EasyLoading.showToast(e.toString());
      print("here is catch error is found${e.toString()}");
    }
  }

  @override
  void initState() {
   getDailog();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(),
      body: getDialogList.isEmpty?Text(""):
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10,),
          Text("Select dialog for prompt",style: TextStyle(color: Colors.grey, fontSize: 16),),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<DialogModel>(
              iconSize: 30,
              isExpanded: true,
              value: getDialogList.isNotEmpty ? getDialogList[selectedIndex] : null,
              items: getDialogList.map((dialog) {
                return DropdownMenuItem<DialogModel>(
                  value: dialog,
                  child: Text(dialog.diaogName),
                );
              }).toList(),
              hint: Text(
                "kkk",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  // Handle the selected value
                  selectedDialogId = value?.dialogId ?? ''; // Assuming dialogId is a property of DialogModel
                  selectedIndex = getDialogList.indexOf(value!);
                });
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.2,),
          ElevatedButton(onPressed: (){

            updatePrompt(promtId: widget.promptId,dialogId:selectedDialogId, context: context );
          }, child:Text("Save In dialog") )
        ],
      )
        );



  }
}

class DialogModel{
  String dialogId;
  String diaogName;
  DialogModel({required this.dialogId, required this.diaogName});
}