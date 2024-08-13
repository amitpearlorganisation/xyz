import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:self_learning_app/features/maincatbottomSheet/treeViewBottomSheet.dart';
import 'package:http/http.dart' as http;
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:textfield_tags/textfield_tags.dart';


import '../../utilities/constants.dart';
import '../../utilities/shared_pref.dart';
import '../../widgets/popup_menu_widget.dart';
import '../subcate1.1/bloc/sub_cate1_bloc.dart';
import '../subcate1.1/bloc/sub_cate1_event.dart';
import '../subcategory/bloc/sub_cate_bloc.dart';
import '../subcategory/bloc/sub_cate_event.dart';
import '../subcategory/sub_cate_screen.dart';
import 'bottomSheetCubit/main_bottom_sheet_cubit.dart';

class MainCatBottomSheet extends StatefulWidget {
  final List<String>? tags;
  final Color? color;
  final String? categoryName;
  final String? rootId;

  MainCatBottomSheet({
    Key? key,
    this.categoryName,
    this.rootId,
    this.color,
    this.tags,
  }) :super(key: key);

  @override
  State<MainCatBottomSheet> createState() => _MainCatBottomSheetState();
}

class _MainCatBottomSheetState extends State<MainCatBottomSheet> {
  Color? pickedColor = Colors.green;
  TextEditingController categoryName1Controller = TextEditingController();
  final TextfieldTagsController _controller = TextfieldTagsController();

  bool? isLoading = false;

  void pickColor({required BuildContext context}) {
    context.showNewDialog(
      AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            portraitOnly: true,
            pickerColor: pickedColor!,
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

  Future<int?> addCategory({required String catName}) async {
    EasyLoading.show();
    Map<String, dynamic> payload = {};
    List<String> keywords = _controller.getTags!;
    List<Map<String, String>> styles = [
      {"key": "font-size", "value": "2rem"},
      {"key": "background-color", "value": pickedColor!.value.toString()}
    ];
    payload.addAll({
      "name":catName ,
    });
    payload.addAll({"keywords": keywords});
    payload.addAll({"styles": styles});
    payload.addAll({
      "rootId": widget.rootId,
    });
    var token = await SharedPref().getToken();
    String base = DEVELOPMENT_BASE_URL;
    String endPoints = "category/create";
    var url = Uri.parse(base + endPoints);

    try {

      var res = await http.post(
        Uri.parse("$url"),
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (res.statusCode == 201) {
        EasyLoading.dismiss();
        context.showSnackBar(
            SnackBar(content: Text('Subcategory created successfully')));
        context
            .read<SubCategory1Bloc>()
            .add(SubCategory1LoadEvent(rootId: widget.rootId));
        context
            .read<SubCategoryBloc>()
            .add(SubCategoryLoadEvent(rootId: widget.rootId));
        setState(() {
          context.read<MainBottomSheetCubit>().onGetSubCategoryList(
              rootId: widget.rootId.toString());
        });
        Navigator.pop(context, true);
      } else {
        EasyLoading.dismiss();
        EasyLoading.showError("Somethings wents wrong", duration: Duration(seconds: 3));
        context.showSnackBar(
            const SnackBar(content: Text('opps something went worng')));
      }
    } on SocketException catch (e) {
      context.showSnackBar(
          const SnackBar(content: Text('Server eror')));
    } finally {
      isLoading = false;
    }

    return null;
  }
  @override
  void initState() {
    context.read<MainBottomSheetCubit>().onGetSubCategoryList(
        rootId: widget.rootId.toString());
    // TODO: implement initState
    super.initState();
  }
  void _showDialog(BuildContext context) {
    categoryName1Controller.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: MediaQuery.of(context).size.height*0.5,
            width: MediaQuery.of(context).size.width*0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Create subcategory',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 16),
                      ),
                    ),
                    IconButton(onPressed: (){
                      Navigator.pop(context);
                    }, icon: Icon(Icons.close, size: 25, color: Colors.green, weight: 600,))
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                    padding: const EdgeInsets.only(left: 10, right: 5),
                    height: context.screenHeight * 0.06,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10)),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(80),
                          ],
                          controller: categoryName1Controller,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                            hintText: 'Title',
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.add,
                              size: context.screenWidth * 0.08,
                            ),
                            // errorText: state.email.invalid
                            //     ? 'Please ensure the email entered is valid'
                            //     : null,
                          ),
                          keyboardType: TextInputType.text,
                          onFieldSubmitted: (value) {},
                          textInputAction: TextInputAction.next,
                        ))),
                SizedBox(
                  height: context.screenHeight * 0.02,
                ),
                TextFieldTags(
                  textfieldTagsController: _controller,
                  initialTags: const ['tags'],
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
                                        color:
                                        Color.fromARGB(255, 74, 137, 92),
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
                                            onTap: () {},
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
                SizedBox(
                  height: context.screenHeight * 0.05,
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
                        if (categoryName1Controller.text.isEmpty ||
                            categoryName1Controller == null) {
                          context.showSnackBar(const SnackBar(
                              content: Text('Category Name is Requried')));
                        } else {
                          addCategory(catName: categoryName1Controller.text);
                        }
                      },
                      child: isLoading == true
                          ? const CircularProgressIndicator()
                          : const Center(
                        child: Text('        Save\n Subcategory'),
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),

        );
      },
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.categoryName.toString(), // Replace with your actual category name
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>SubCategoryScreen(
                                color: widget.color,
                                key: widget.key,
                                categoryName:widget.categoryName ,
                                rootId: widget.rootId,
                                tags: widget.tags,
                              )));
/*
                        navigate(context: context);
*/

                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                              decoration: BoxDecoration(
                                  color: Colors.blueAccent.shade200,
                                  borderRadius: BorderRadius.circular(100)
                              ),
                              child:
                              Icon(Icons.near_me_sharp, color: Colors.red,
                              ),
                            ),
                          ),
                          SizedBox(width: 5,),
                          InkWell(
                            onTap: (){
                              _showDialog(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),

                              decoration: BoxDecoration(

                                  color: Colors.deepPurple[400],
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Icon(Icons.create_new_folder, color: Colors.white,),
                            ),
                          ),
                          SizedBox(width: 5,),
                          PopupMenuWidget(categoryName: widget.categoryName, categoryId: widget.rootId,
                            level: "Level 1",
                          ), // Add the PopupMenuWidget here

                        ],
                      ),
                    )

                  ],
                ),
              ),
            ),
            Container(
              height: 1.5,
              width: double.infinity,
              color: Colors.black38,
            ),
            BlocBuilder<MainBottomSheetCubit, MainBottomSheetState>(
              builder: (context, state) {
                if(state is MainBottomSheetLoading){
                  return Center(
                    child: Container(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is MainBottomSheetLoaded) {
                  if(state.cateList.isEmpty){
                    return Center(
                      child: Text("Create Subcategory"),
                    );
                  }
                  return Expanded(
                    child: MyTreeView(
                      mainRootId: widget.rootId.toString(),
                      root: state.cateList.map((item) {
                        print("xyz response ${item.catlist}");
                        // Map each item in catlist to a MyNode
                        MyNode myNode = MyNode(
                          sId: item.sId ?? "",
                          userId: item.userId ?? "",
                          name: item.name ?? "",
                          keywords: item.keywords ?? [],
                          styles: [], // You may need to populate styles based on your actual data
                          children: item.catlist.map((subItem) {
                            // Map each subcategory in catlist to a MyNode
                            MyNode subNode = MyNode(
                              sId: subItem.sId ?? "",
                              userId: subItem.userId ?? "",
                              name: subItem.name ?? "",
                              keywords: subItem.keywords ?? [],
                              styles: [], // You may need to populate styles based on your actual data
                              children: subItem.catlist.map((subItem2) {
                                // Map each subcategory in the third level to a MyNode
                                return MyNode(
                                  sId: subItem2.sId ?? "",
                                  userId: subItem2.userId ?? "",
                                  name: subItem2.name ?? "",
                                  keywords: subItem2.keywords ?? [],
                                  styles: [], // You may need to populate styles based on your actual data
                                  children: [], // This is an empty list because we are considering only three levels of subcategories
                                );
                              }).toList(),
                            );
                            return subNode;
                          }).toList(),
                        );

                        return myNode;
                      }).toList(),
                    ),
                  );
                }

                return Text("Somethings wents wrong");
              },
            )
          ],
        ),
      ),
    );
  }
}
