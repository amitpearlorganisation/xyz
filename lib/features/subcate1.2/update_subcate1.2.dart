import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:self_learning_app/features/subcate1.2/bloc/sub_cate2_bloc.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';

import '../category/bloc/category_bloc.dart';
import '../dashboard/dashboard_screen.dart';
import '../subcate1.1/bloc/sub_cate1_bloc.dart';
import '../subcate1.1/bloc/sub_cate1_event.dart';
import 'bloc/sub_cate2_event.dart';

class UpdateSubCate2Screen extends StatefulWidget {
  final String rootId;
  final Color selectedColor;
  final String categoryTitle;
  final List<String> keyWords;
  const UpdateSubCate2Screen(
      {Key? key,
      required this.rootId,
      required this.selectedColor,
      required this.categoryTitle,
      required this.keyWords})
      : super(key: key);

  @override
  State<UpdateSubCate2Screen> createState() => _UpdateSubCate2ScreenState();
}

class _UpdateSubCate2ScreenState extends State<UpdateSubCate2Screen> {
  Color? pickedColor;
  bool? isLoading = false;
  TextEditingController categoryNameController = TextEditingController();

  @override
  void initState() {
    categoryNameController.text = widget.categoryTitle;
    pickedColor = widget.selectedColor;
    super.initState();
  }

  void pickColor({required BuildContext context}) {
    context.showNewDialog(
      AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            portraitOnly: true,
            pickerColor: widget.selectedColor!,
            onColorChanged: (value) {
              setState(() {
                pickedColor = value;
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

  Future<int?> addCategory() async {
EasyLoading.show();
    List<String> keywords = ['test,test1'];
    List<Map<String, String>> styles = [
      {"key": "font-size", "value": "2rem"},
      {"key": "background-color", "value": pickedColor!.value.toString()}
    ];
    Map<String, dynamic> payload = {};
    payload.addAll({
      "name": categoryNameController.text,
    });
    payload.addAll({"keywords": keywords});
    payload.addAll({"styles": styles});
    var token = await SharedPref().getToken();
    try {
      var res = await http.patch(
        Uri.parse(
            'https://backend.savant.app/web/category/${widget.rootId}'),
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (res.statusCode == 200) {
        EasyLoading.dismiss();
        EasyLoading.showSuccess("Category updated successfully");
        context.showSnackBar(
            SnackBar(content: Text('Subcategory update Successfully')));
        context
            .read<SubCategory2Bloc>()
            .add(SubCategory2LoadEvent(rootId: widget.rootId));
        context
            .read<SubCategory1Bloc>()
            .add(SubCategory1LoadEvent(rootId: widget.rootId));
        // Navigator.pushReplacement(context, MaterialPageRoute(
        //   builder: (context) {
        //     return DashBoardScreen(msgstatus: false,);
        //   },
        // ));
        Navigator.pop(context, {
          'success': true,
          'categoryName': categoryNameController.text,
        });      } else {
        EasyLoading.dismiss();
        EasyLoading.showError("Somethings wents wrong");
        context.showSnackBar(
            const SnackBar(content: Text('opps something went worng')));
      }
      print(res.body);
      print('data');
    } on SocketException catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString());
      context.showSnackBar(
          const SnackBar(content: Text('No internet Connection...')));
    } finally {
      isLoading = false;
    }
    return null;
  }

  Future<int?> deleteCategory() async {
EasyLoading.show();    var token = await SharedPref().getToken();
    try {
      var res = await http.delete(
        Uri.parse(
            'https://backend.savant.app/web/category/${widget.rootId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (res.statusCode == 200) {
        EasyLoading.dismiss();
        Navigator.pop(context, true);
        Navigator.pop(context, true);

      } else {
        EasyLoading.dismiss();
        EasyLoading.showError("Somethings went wrong");
        context.showSnackBar(
            const SnackBar(content: Text('opps something went worng')));
      }
      print(res.body);
      print('data');
    } on SocketException catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString());
      context.showSnackBar(
          const SnackBar(content: Text('No internet Connection')));
    } finally {
      isLoading = false;
    }
    return null;
  }

  AwesomeDialog showDeleteCategory() {
    return AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      dialogType: DialogType.QUESTION,
      body: Center(
        child: Text(
          'Are you sure\nYou want to delete\n${widget.categoryTitle}',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {
        deleteCategory()  ;    },
      btnOkColor: Colors.red,
      closeIcon: Icon(Icons.close),
      btnCancelOnPress: () {},
      btnOkText: "Delete",
      btnOkIcon: Icons.delete,
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.categoryTitle);
    print('subcateg .11. edit');
    return Scaffold(
        appBar: AppBar(title: Text(widget.categoryTitle)),
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
                    'Update Subcategory',
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
                    height: context.screenHeight * 0.08,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10)),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextFormField(
                          controller: categoryNameController,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(fontSize: 18),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.add,
                              size: context.screenWidth * 0.08,
                            ),
                            // errorText: state.email.invalid
                            //     ? 'Please ensure the email entered is valid'
                            //     : null,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onFieldSubmitted: (value) {},
                          textInputAction: TextInputAction.next,
                        ))),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () {
                          pickColor(context: context);
                        },
                        child: Container(
                            height: 25, width: 25, color: pickedColor)),
                    const Text('  Choose Color ')
                  ],
                ),
                const SizedBox(
                  height: 35,
                ),
                SizedBox(
                  width: context.screenWidth * 0.35,
                  height: context.screenHeight * 0.068,
                  child: ElevatedButton(
                      onPressed: () {
                        if (categoryNameController.text.isEmpty ||
                            categoryNameController == null) {
                          context.showSnackBar(const SnackBar(
                              content: Text('SubCategory Name is Requried')));
                        } else {
                          addCategory();
                        }
                      },
                      child: isLoading == true
                          ? const CircularProgressIndicator()
                          : Text('Update')),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: context.screenWidth * 0.35,
                  height: context.screenHeight * 0.068,
                  child: ElevatedButton(
                      onPressed: () {
                        if (categoryNameController.text.isEmpty ||
                            categoryNameController == null) {
                          context.showSnackBar(const SnackBar(
                              content: Text('SubCategory Name is Required')));
                        } else {
                          showDeleteCategory();
                        }
                      },
                      child: isLoading == true
                          ? const CircularProgressIndicator()
                          : const Text('Delete')),
                )
              ],
            ),
          ),
        ));
  }
}
