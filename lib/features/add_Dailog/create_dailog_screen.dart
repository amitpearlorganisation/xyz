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

import '../category/bloc/category_bloc.dart';
import '../dashboard/bloc/dashboard_bloc.dart';
import '../dashboard/dashboard_screen.dart';
import '../quick_add/data/repo/model/quick_type_model.dart';
import '../quick_add/data/repo/model/quick_type_prompt_model.dart';
import 'bloc/create_dailog_bloc/create_dailog_bloc.dart';

class AddDailogScreen extends StatefulWidget {
  const AddDailogScreen({Key? key}) : super(key: key);

  @override
  State<AddDailogScreen> createState() => _AddDailogScreenState();
}

class _AddDailogScreenState extends State<AddDailogScreen> {
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
        EasyLoading.showError("Server error", duration: Duration(seconds: 3));
        context.showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Category added Successfully')));
      } else {
        context
            .showSnackBar(SnackBar(content: Text('opps something went worng')));
      }
      print(res.body);
      print('data');
    } on SocketException catch (e) {
      context.showSnackBar(const SnackBar(content: Text('No Internet')));
    } finally {
      isLoading = false;
    }
    return null;
  }
 bool isExpandable = false;
  bool isResourceExpandable = false;

  final Dio _dio = Dio();
  List<QuickPromptModel> quickPromptList = [];
  List<QuickResourceModel> quickResourceList = [];

  bool isLoadingPrompt = true;
  void getQuickPromptList() async {
    try {
      var token = await SharedPref().getToken();
      final Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };

      Response res = await _dio.get(
        "https://backend.savant.app/web/prompt/",
        options: Options(headers: headers),
      );

      final jsonResponse = res?.data;
      print("promtpId checking$jsonResponse");
      final data = jsonResponse['data'];
      final recordList = data['record'] as List;

      for (var record in recordList) {
        String id = record['_id'];
        String name = record['name'];
        String side1Content = record["side1"]["content"];
        String side2Content = record["side2"]['content'];
        String side1Type = record['side1']['type'];
        String side2Type = record['side2']['type'];
        String firstWord = side1Type.split('-')[0];
        String SecondWord = side2Type.split('-')[0];

        quickPromptList.add(QuickPromptModel(
          promptid: id,
          promptname: name,
          side1content: side1Content,
          side2content: side2Content,
          side1Type: firstWord,
          side2Type: SecondWord
        ));
      }

      // Update the UI and set isLoading to false.
      setState(() {
        isLoadingPrompt = false;
      });
    } catch (e) {
      print("Error: $e");
      // You can handle the error as needed
      setState(() {
        isLoadingPrompt = false; // Make sure to set isLoading to false in case of an error.
      });
    }
  }
  void getQuickResourceList() async {
    try {
      var token = await SharedPref().getToken();
      final Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };

      Response res = await _dio.get(
        "https://backend.savant.app/web/resource/quickAdd",
        options: Options(headers: headers),
      );

      final jsonResponse = res?.data;

      if (jsonResponse != null && jsonResponse['data'] != null) {
        final data = jsonResponse['data'];
        final record = data['record'];
        final records = record['records'] as List;

        for (var resource in records) {
          String resourceId = resource['_id'];
          String resourceName = resource['title'];

          quickResourceList.add(QuickResourceModel(
            resourceId: resourceId,
            resourceName: resourceName,
          ));
        }
      } else {
        print("Error: Invalid response format"); // Handle the error as needed
      }

      // Update the UI and set isLoading to false.
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      // You can handle the error as needed
      setState(() {
        isLoading = false; // Make sure to set isLoading to false in case of an error.
      });
    }
  }


  List<String> resourceList = ["amit", "vipin", "deepak", "shubham", "atul", "jake", "sandeep", "prem" ];
  List<checkModel> _list =[];
  List<resourceCheckModel> _resList = [];
  List<String> selectedPromptIds = [];
  List<String> selectedResourceIds =[];
  @override
  void initState() {
    getQuickPromptList();
    getQuickResourceList();
    super.initState();
  }
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
                  initialTags: const ['flag-dialog'],
                  textSeparators: const [' ', ','],
                  letterCase: LetterCase.normal,
                  validator: (String tag) {
                    if (tag == 'php') {
                      return 'No, please just no';
                    } else if (_controller!.getTags!.contains(tag)) {
                      return 'you already entered that';
                    }
                    return null;
                  },
                  inputfieldBuilder:
                      (context, tec, fn, error, onChanged, onSubmitted) {
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
                            hintText: _controller!.hasTags
                                ? ''
                                : "Enter tag...(Optional)",
                            errorText: error,
                            prefixIconConstraints: BoxConstraints(
                                maxWidth: context.screenWidth * 0.74),
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
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            child: Text(
                                              '#$tag',
                                              style: const TextStyle(
                                                  color: Colors.white),
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
                                              color: Color.fromARGB(
                                                  255, 233, 233, 233),
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
                          onChanged: onChanged,
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

                ExpansionPanelList(
                  animationDuration: Duration(milliseconds:1000),
                  dividerColor:Colors.red,
                  elevation:1,
                  children: [
                    ExpansionPanel(
                      body: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: <Widget>[

                            Container(
                              height: quickPromptList.length==2?100:200,
                              width: double.infinity,
                              child: quickPromptList.length==0?Text("No data"):ListView.builder(
                                itemCount: quickPromptList.length,
                                itemBuilder: (context, index) {

                                  return
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      color: Colors.blue[50],
                                      child: CheckboxListTile(
                                        activeColor: Colors.red,
                                        checkColor: Colors.white,
                                        // value: _saved.contains(context), // changed
                                        value: _list[index].isCheck,
                                        onChanged: (val) {
                                          print("object  ${val}");
                                          setState(() {
                                            _list[index].isCheck = val!;
                                            if (val) {
                                              selectedPromptIds.add(quickPromptList[index].promptid.toString());
                                            } else {
                                              // If the checkbox is unchecked, remove the promptId from the list.
                                              selectedPromptIds.remove(quickPromptList[index].promptid.toString());
                                            }
                                          });
                                        },
                                        title: Text(quickPromptList![index].promptname.toString()),
                                      )
                                    );
                                },
                              ),
                        ),




                          ],
                        ),
                      ),
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Select prompt",
                            style: TextStyle(
                              color:Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                      isExpanded: isExpandable,
                    ),

                  ],
                  expansionCallback: (int item, bool status) {
                    setState(() {
                      isExpandable = !isExpandable;
                    });
                  },
                )  ,
                SizedBox(height: 10,),
                ExpansionPanelList(
                  animationDuration: Duration(milliseconds: 1000),
                  dividerColor: Colors.red,
                  elevation: 1,
                  children: [
                    ExpansionPanel(
                      body: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: quickResourceList.length>=2?100:200,
                              width: double.infinity,
                              child:
                              quickResourceList.length==0?Center(child: Text("No data")):  ListView.builder(
                                itemCount: quickResourceList.length,
                                itemBuilder: (context, index) {
                                  _resList.add(resourceCheckModel(selectedResourceIds.toString(), false));
                                  // plese check name and id of resmodel
                                  if (index >= 0 && index < _resList.length) { // Check index bounds
                                    return Container(
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      color: Colors.blue[50],
                                      child: CheckboxListTile(
                                        activeColor: Colors.green,
                                        checkColor: Colors.red,
                                        value: _resList[index].isCheck,
                                        onChanged: (val) {
                                          setState(() {
                                            _resList[index].isCheck = val!;
                                            updateSelectedResourceIds(
                                              quickResourceList[index].resourceId.toString(),
                                              val,
                                            );
                                          });
                                        },
                                        title: Text(quickResourceList[index].resourceName.toString()),
                                      ),
                                    );
                                  } else {
                                    return Container( child: Text("Empty not data "),); // Placeholder for an invalid index
                                  }
                                },
                              )
                            ),
                          ],
                        ),
                      ),
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Select resource",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                      isExpanded: isResourceExpandable,
                    ),
                  ],
                  expansionCallback: (int item, bool status) {
                    setState(() {
                      isResourceExpandable = !isResourceExpandable;
                    });
                  },
                ),
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

                          context.read<CreateDailogBloc>().add(AddDailogEvent(color:pickedColor!.value.toString() , dailogName:categoryNameController.text,promtIds: selectedPromptIds,
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