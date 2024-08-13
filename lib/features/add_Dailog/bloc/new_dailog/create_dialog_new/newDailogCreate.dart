import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:self_learning_app/features/add_Dailog/dailog_screen.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../../../dashboard/dashboard_screen.dart';
import '../../create_dailog_bloc/create_dailog_bloc.dart';


class NewAddDailogScreen extends StatefulWidget {
  List<String> promptId;
   NewAddDailogScreen({Key? key, required this.promptId}) : super(key: key);

  @override
  State<NewAddDailogScreen> createState() => _NewAddDailogScreen();
}

class _NewAddDailogScreen extends State<NewAddDailogScreen> {
  TextEditingController categoryNameController = TextEditingController();

  final TextfieldTagsController? _controller = TextfieldTagsController();

  Color? pickedColor = Colors.green;
  bool? isLoading = false;

  void pickColor({required BuildContext context}) {
    context.showNewDialog(
      AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            portraitOnly: true,
            pickerColor: Colors.green,
            onColorChanged: (value) {
              setState(() {
                pickedColor = value;
                print(pickedColor!.value);
                print('pickedColor');
              });
            },
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
  void addDailog(){
    List<String> keywords = _controller!.getTags!;

    context.read<CreateDailogBloc>().add(AddDailogEvent(color:pickedColor!.value.toString() , dailogName:categoryNameController.text,promtIds: selectedPromptIds,
      resourceIds: selectedResourceIds, tags: keywords,
    ));
  }
  Future<int?> addCategory() async {
    EasyLoading.show();
    Map<String, dynamic> payload = {};
    List<String> keywords = _controller!.getTags!.toList();
    List<Map<String, String>> styles = [
      {"key": "font-size", "value": "2rem"},
      {"key": "background-color", "value": pickedColor!.value.toString()}
    ];
    payload.addAll({
      "name": categoryNameController.text,
    });
    payload.addAll({"resourceIds": selectedResourceIds});
    payload.addAll({'promptIds':selectedPromptIds});
    payload.addAll({"keywords": keywords});
    payload.addAll({"styles": styles});
    print("keywrods-==$payload");
    var token = await SharedPref().getToken();

    try {
      var res = await http.post(
        Uri.parse('https://backend.savant.app/web/category/create-dialog'),
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      print("respone of create dailog ${res.body}");
      if (res.statusCode == 201) {
        EasyLoading.dismiss();

        context.showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Category added Successfully')));
      } else {
        EasyLoading.dismiss();
        EasyLoading.showError("Server error",duration: Duration(seconds: 3));
        context
            .showSnackBar(SnackBar(content: Text('opps something went worng')));
      }
      print(res.body);
      print('data');
    } on SocketException catch (e) {
      EasyLoading.dismiss();
      context.showSnackBar(const SnackBar(content: Text('Server error')));
    } finally {
      isLoading = false;
    }
    return null;
  }
  bool isExpandable = false;
  bool isResourceExpandable = false;

  final Dio _dio = Dio();


  bool isLoadingPrompt = true;



  List<String> resourceList = ["amit", "vipin", "deepak", "shubham", "atul", "jake", "sandeep", "prem" ];
  List<checkModel> _list =[];
  List<resourceCheckModel> _resList = [];
  List<String> selectedPromptIds = [];
  List<String> selectedResourceIds =[];
  @override

  void updateSelectedResourceIds(String resourceId, bool isChecked) {
    if (isChecked) {
      if (!selectedResourceIds.contains(resourceId)) {
        setState(() {
          selectedResourceIds.add(resourceId);
        });
      }
    } else {
      setState(() {
        selectedResourceIds.remove(resourceId);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    for (String name in resourceList) {
      _list.add(checkModel(name, false));
    }
    return BlocConsumer<CreateDailogBloc, CreateDailogState>(
      listener: (context, state) {
        if(state is DailogCreateSuccessState){
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 5, // Adjust the elevation as needed
                backgroundColor: Colors.white, // Background overlay color
                child: Container(
                  height: MediaQuery.of(context).size.height*0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Dialog created successfully", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(90)
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );


          // Automatically close the dialog after 5 seconds
          Future.delayed(Duration(seconds: 4), () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashBoardScreen(msgstatus: false,))); // Close the dialog

          });

        }
      },
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(title: Text("Create Dailog")),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Create Dailog',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 16),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 10, right: 5),
                        height: context.screenHeight * 0.07,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10)),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(80),
                              ],
                              controller: categoryNameController,
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                hintText: 'Title',
                                border: InputBorder.none,
                                icon: Icon(
                                  Icons.add,
                                  size: context.screenWidth * 0.06,
                                ),
                                // errorText: state.email.invalid
                                //     ? 'Please ensure the email entered is valid'
                                //     : null,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onFieldSubmitted: (value) {},
                              textInputAction: TextInputAction.next,
                            ))),
                    SizedBox(
                      height: context.screenHeight * 0.03,
                    ),
                    TextFieldTags(
                      textfieldTagsController: _controller,
                      initialTags: const ['tags'],
                      textSeparators: const [','],
                      letterCase: LetterCase.normal,
                      validator: (String tag) {
                        if (tag == 'php') {
                          return 'No, please just no';
                        } else if (_controller!.getTags!.contains(tag)) {
                          return 'you already entered that';
                        }
                        return null;
                      },
                      inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
                        return ((context, sc, tags, onTagDelete) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              controller: tec,
                              focusNode: fn,
                              decoration: InputDecoration(
                                isDense: true,
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 74, 137, 92),
                                    width: 3.0,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 74, 137, 92),
                                    width: 3.0,
                                  ),
                                ),
                                helperStyle: const TextStyle(
                                  color: Color.fromARGB(255, 74, 137, 92),
                                ),
                                hintText: _controller!.hasTags ? '' : "Enter tag...(Optional)",
                                errorText: error,
                                prefixIconConstraints:
                                BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
                                prefixIcon: tags.isNotEmpty
                                    ? SingleChildScrollView(
                                  controller: sc,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children: tags.map((String tag) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                            color: Color.fromARGB(255, 74, 137, 92),
                                          ),
                                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                child: Text(
                                                  '#$tag',
                                                  style: const TextStyle(color: Colors.white),
                                                ),
                                                onTap: () {
                                                  print("$tag selected");
                                                },
                                              ),
                                              const SizedBox(width: 4.0),
                                              InkWell(
                                                child: const Icon(
                                                  Icons.cancel,
                                                  size: 14.0,
                                                  color: Color.fromARGB(255, 233, 233, 233),
                                                ),
                                                onTap: () {
                                                  onTagDelete(tag);
                                                },
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList()),
                                )
                                    : null,
                              ),
                              onChanged: (value) {
                                if (value.contains(' ')) {
                                  final tags = value.split(' ');
                                  tags.forEach((tag) {
                                    if (tag.isNotEmpty) {
                                      _controller?.addTag = tag.trim();
                                    }
                                  });
                                  tec.clear();
                                }
                                onChanged!(value); // Keep original behavior if needed
                              },
                              onSubmitted: onSubmitted,
                            ),
                          );
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: () {
                              pickColor(context: context);
                            },
                            child: Container(
                                height: 25,
                                width: 25,
                                color: pickedColor ?? Colors.green)),
                        const Text('  Choose Color ')
                      ],
                    ),
                    SizedBox(height: 20,),


                    const SizedBox(
                      height: 35,
                    ),
                    SizedBox(
                      width: context.screenWidth * 0.35,
                      height: context.screenHeight * 0.068,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: const BorderSide(color: Colors.red)))),
                          onPressed: () {
                            print(_controller!.getTags);
                            /* for(var item in selectedResourceIds){
                          EasyLoading.showToast(item);
                        }*/
                            if (categoryNameController.text.isEmpty) {
                              context.showSnackBar(const SnackBar(
                                  content: Text('Category name is requried')));
                            } else {
                              /*  for(var item in selectedResourceIds){
                            EasyLoading.showSuccess("items is selectedResource$item");
                          }*/
                              List<String> keywords = _controller!.getTags!;

                              context.read<CreateDailogBloc>().add(AddDailogEvent(color:pickedColor!.value.toString() , dailogName:categoryNameController.text,promtIds: widget.promptId,
                                resourceIds: selectedResourceIds, tags: keywords,
                              ));
                            }
                          },
                          child: isLoading == true
                              ? const CircularProgressIndicator()
                              : Text('Save Dailog')),
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }
}
class checkModel{
  String name;
  bool isCheck;

  checkModel(this.name, this.isCheck);

}

class resourceCheckModel{
  String name;
  bool isCheck;

  resourceCheckModel(this.name, this.isCheck);

}