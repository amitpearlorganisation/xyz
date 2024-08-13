import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:self_learning_app/features/subcate1.2/bloc/sub_cate2_bloc.dart';
import 'package:self_learning_app/features/subcategory/sub_cate_screen.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

import '../../utilities/shared_pref.dart';
import '../dashboard/dashboard_screen.dart';
import '../subcategory/bloc/sub_cate_bloc.dart';
import '../subcategory/bloc/sub_cate_event.dart';
import 'bloc/sub_cate1_bloc.dart';
import 'bloc/sub_cate1_event.dart';

class UpdateSubCate1Screen extends StatefulWidget {
  final String rootId;
  final Color selectedColor;
  final String categoryTitle;
  final List<String> keyWords;
  const UpdateSubCate1Screen(
      {Key? key,
      required this.rootId,
      required this.selectedColor,
      required this.categoryTitle,
      required this.keyWords})
      : super(key: key);

  @override
  State<UpdateSubCate1Screen> createState() => _UpdateSubCate1ScreenState();
}

class _UpdateSubCate1ScreenState extends State<UpdateSubCate1Screen> {
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
    isLoading = true;
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
        context.showSnackBar(
            SnackBar(content: Text('Subcategory update Successfully')));
        //  context.read<SubCategory1Bloc>().add(SubCategory1LoadEvent(rootId: widget.rootId));
        context
            .read<SubCategoryBloc>()
            .add(SubCategoryLoadEvent(rootId: widget.rootId));
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return DashBoardScreen(msgstatus: false,);
          },
        ));
      } else {
        context.showSnackBar(
            const SnackBar(content: Text('opps something went worng')));
      }
      print(res.body);
      print('data');
    } on SocketException catch (e) {
      context.showSnackBar(
          const SnackBar(content: Text('No internet Connection...')));
    } finally {
      isLoading = false;
    }
    return null;
  }

  Future<int?> deleteCategory() async {
    isLoading = true;
    var token = await SharedPref().getToken();
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
        context.showSnackBar(
            SnackBar(content: Text('Subcategory deleted Successfully')));
        context
            .read<SubCategory1Bloc>()
            .add(SubCategory1LoadEvent(rootId: widget.rootId));
        context
            .read<SubCategoryBloc>()
            .add(SubCategoryLoadEvent(rootId: widget.rootId));
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return DashBoardScreen(msgstatus: false,);
          },
        ));
      } else {
        context.showSnackBar(
            const SnackBar(content: Text('opps something went worng')));
      }
      print(res.body);
      print('data');
    } on SocketException catch (e) {
      context.showSnackBar(
          const SnackBar(content: Text('No internet Connection')));
    } finally {
      isLoading = false;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print('inside 1.1');
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
                          deleteCategory();
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
