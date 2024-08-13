import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../category/bloc/category_bloc.dart';
import '../dashboard/dashboard_screen.dart';

class UpdateCateScreen extends StatefulWidget {
  final String? rootId;
  final List<String>? tags;
  final Color? selectedColor;
  final String? categoryTitle;
  const UpdateCateScreen(
      {Key? key,
      this.rootId,
      this.selectedColor,
      this.categoryTitle,
      this.tags})
      : super(key: key);

  @override
  State<UpdateCateScreen> createState() => _UpdateCateScreenState();
}

class _UpdateCateScreenState extends State<UpdateCateScreen> {
  Color? pickedColor;

  @override
  void initState() {
    pickedColor = widget.selectedColor;
    categoryNameController.text = widget.categoryTitle!;
    super.initState();
  }

  TextEditingController categoryNameController = TextEditingController();
  final TextfieldTagsController _controller = TextfieldTagsController();

  bool? isLoading = false;

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
    List<String> keywords = _controller!.getTags!;
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
    print("keyword for main category$keywords");
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
      print("main category update ${res.body}");
      if (res.statusCode == 200) {
        context.showSnackBar(
            SnackBar(content: Text('Category update Successfully')));
        context.read<CategoryBloc>().add(CategoryLoadEvent());
        Navigator.pop(context, true);
      } else {
        context.showSnackBar(
            const SnackBar(content: Text('opps something went worng')));
      }
      print(res.body);
      print('data');
    } on SocketException catch (_) {
      context
          .showSnackBar(const SnackBar(content: Text('No internet available')));
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
            SnackBar(content: Text('Category deleted Successfully')));
        context.read<CategoryBloc>().add(CategoryLoadEvent());
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
    } on SocketException catch (_) {
      context
          .showSnackBar(const SnackBar(content: Text('No internet available')));
    } finally {
      isLoading = false;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.categoryTitle!)),
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
                    'Create Category',
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
                            hintText: 'Category Name',
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
                SizedBox(
                  height: context.screenHeight * 0.023,
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
                        print(_controller!.getTags);
                        if (categoryNameController.text.isEmpty ||
                            categoryNameController == null) {
                          context.showSnackBar(const SnackBar(
                              content: Text('Category Name is Requried')));
                        } else {
                          addCategory();
                        }
                      },
                      child: isLoading == true
                          ? const CircularProgressIndicator()
                          : Text('Update Category')),
                ),
                SizedBox(
                  height: 20,
                ),
                // SizedBox(
                //   width: context.screenWidth * 0.35,
                //   height: context.screenHeight * 0.068,
                //   child: ElevatedButton(
                //       onPressed: () {
                //         if (categoryNameController.text.isEmpty ||
                //             categoryNameController == null) {
                //           context.showSnackBar(const SnackBar(
                //               content: Text('Category Name is Requried')));
                //         } else {
                //           deleteCategory();
                //         }
                //       },
                //       child: isLoading == true
                //           ? const CircularProgressIndicator()
                //           : const Text('Delete Category')),
                // )
              ],
            ),
          ),
        ));
  }
}
