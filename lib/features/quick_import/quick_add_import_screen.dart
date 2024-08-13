import 'dart:convert';
import 'dart:io';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:self_learning_app/features/subcate1.2/bloc/sub_cate2_bloc.dart';
import 'package:self_learning_app/features/subcate1.2/bloc/sub_cate2_event.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../utilities/shared_pref.dart';
import '../category/bloc/category_bloc.dart';
import '../dashboard/bloc/dashboard_bloc.dart';
import '../dashboard/dashboard_screen.dart';
import '../subcate1.1/bloc/sub_cate1_bloc.dart';
import '../subcate1.1/bloc/sub_cate1_event.dart';
import '../subcate1.1/bloc/sub_cate1_state.dart';
import '../subcategory/bloc/sub_cate_bloc.dart';
import '../subcategory/bloc/sub_cate_event.dart';
import '../subcategory/bloc/sub_cate_state.dart';
import 'bloc/quick_add_bloc.dart';

class QuickAddImportScreen extends StatefulWidget {
  final String title;
  final String quickAddId;
  final String  mediaType;
  final String resourcecontent;
  const QuickAddImportScreen(
      {Key? key, required this.title, required this.quickAddId,required this.mediaType, required this.resourcecontent})
      : super(key: key);

  @override
  State<QuickAddImportScreen> createState() => _QuickAddImportScreenState();
}

class _QuickAddImportScreenState extends State<QuickAddImportScreen> {
  TextEditingController categoryNameController = TextEditingController();

  final TextfieldTagsController? _controller = TextfieldTagsController();
  bool? isLoading = false;
  Color? pickedColor = Colors.green;

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


  Future<int?> addCategory() async {
    isLoading = true;
    Map<String, dynamic> payload = {};
    List<String> keywords = _controller!.getTags!;
    List<Map<String, String>> styles = [
      {"key": "font-size", "value": "2rem"},
      {"key": "background-color", "value": pickedColor!.value.toString()}
    ];
    payload.addAll({
      "name": categoryNameController.text,
    });
    payload.addAll({"keywords": keywords});
    payload.addAll({"styles": styles});
    var token = await SharedPref().getToken();
    try {
      var res = await http.post(
        Uri.parse('https://backend.savant.app/web/category/create'),
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      final data = jsonDecode(res.body);
      print("respone of create category ${res.body}");
      if (res.statusCode == 201) {
        print("create new category res===---==-=-==-=${res.body}");
        context.showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Category added Successfully')));
        context.read<CategoryBloc>().add(CategoryLoadEvent());
        context.read<DashboardBloc>().ChangeIndex(0);
        final categoryId = data['data']['record']['id'];
        print('Category ID: $categoryId');
        context.read<QuickImportBloc>().add(
            ButtonPressedEvent(
                mediaType: widget.mediaType,
                title: widget.title,
                quickAddId: widget.quickAddId,
                rootId: categoryId,
              resourceContent: widget.resourcecontent,
            ));
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


  @override
  void initState() {
    context.read<QuickImportBloc>().add(LoadQuickTypeEvent());
    context.read<SubCategory1Bloc>().add(SubCategory1LoadEmptyEvent());
    super.initState();
  }

  String ddvalue = '';
  String subCateId = '';
  bool isFirstTime=true;



  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
        appBar: AppBar(title: Text(widget.title,),

        ),
        body: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox( height: 20,),
            const Text(
              'Save as new category',
              style: TextStyle(
                  fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                  onPressed: () {

                    _saveAsCatShowDialog(context);

                    // )
                    // ));
                    // context.showNewDialog(AlertDialog(title: const Text('Are you sure you want to save as category.'),actions: [
                    //   ElevatedButton(onPressed: () {
                    //     context.read<QuickImportBloc>().add(
                    //         SaveAsNewCategoryEvent(
                    //           mediaType: widget.mediaType,
                    //             title: widget.title,
                    //             quickAddId: widget.quickAddId));
                    //     context.read<CategoryBloc>().add(CategoryLoadEvent());
                    //   }, child: const Text('Save')),
                    //   ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'))
                    // ],));

                  },
                  child: const Text('Save as Category')),
            ),
            const SizedBox(
              height: 20,
            ),
            BlocConsumer<QuickImportBloc, QuickImportState>(
              listener: (context, state) {
                if (state is QuickImportSuccessfullyState) {
                  context.showSnackBar(
                      const SnackBar(content: Text("added succesfuuly")));
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                    builder: (context) {
                      return  DashBoardScreen(msgstatus: false,);
                    },
                  ), (route) => false);
                }
              },
              builder: (context, state) {
                if (state is QuickImportLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is QuickImportLoadedState) {
                  if (state.list!.isNotEmpty) {
                    if(isFirstTime) {
                      context.read<SubCategoryBloc>().add(SubCategoryLoadEvent(rootId: state.list!.first.sId));
                    }
                    print(state.list!.first.sId);
                    return Container(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Save as main category',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField2(
                                  hint: const Text(
                                    'Choose Category',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  decoration: InputDecoration(
                                    fillColor: Colors.grey,
                                    contentPadding: const EdgeInsets.only(
                                        left: 0, top: 15, bottom: 15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  key: UniqueKey(),
                                  value: state.value,
                                  items: state.list!.map<DropdownMenuItem<String?>>((e) {

                                    return DropdownMenuItem<String>(
                                      value: e.sId,
                                      child: SizedBox(
                                          width: context.screenWidth/1.5,
                                          child: Text(e.name!,overflow: TextOverflow.ellipsis,)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    isFirstTime=false;
                                    context.read<QuickImportBloc>().add(ChangeDropValue(
                                        title: value, list: state.list));
                                    context.read<SubCategoryBloc>().add(SubCategoryLoadEvent(rootId: value));
                                  },
                                ),
                              ),
                              GestureDetector(child: Icon(Icons.add_circle,size: 30,),onTap: () {
                                print(state.value??state.list!.first.sId??'');
                                context.showNewDialog(AlertDialog(title: const Text('Are you sure you want to save as Main category.'),actions: [
                                  ElevatedButton(onPressed: () {

                                    context.read<QuickImportBloc>().add(
                                        ButtonPressedEvent(
                                            quickAddId: widget.quickAddId,
                                          mediaType: widget.mediaType,
                                            title: widget.title,
                                            rootId: state.value??state.list!.first.sId??'',
                                        resourceContent: widget.resourcecontent??"resourceContent"
                                        ));
                                    context.read<CategoryBloc>()
                                        .add(CategoryLoadEvent());
                                  }, child: const Text('Save')),
                                  ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'))
                                ],));
                              },)

                            ],
                          ),


                          SizedBox(
                            height: context.screenHeight * 0.1,
                          ),
                          /// sub category Bloc start here
                          Text("Save as subcategory", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),

                          SizedBox(height: 10,),

                          BlocBuilder<SubCategoryBloc, SubCategoryState>(
                            builder: (context, Subcatestate) {

                              print(Subcatestate);
                              if (Subcatestate is SubCategoryLoaded) {

                                if(Subcatestate.cateList.isNotEmpty){
                                  // if(isFirstTime) {
                                  //   context.read<SubCategory1Bloc>().add(SubCategory1LoadEvent(rootId: state.list!.first.sId));
                                  // }
                                }
                                return Subcatestate.cateList.isEmpty
                                    ? const SizedBox()
                                    : Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(

                                                child: DropdownButtonFormField2(
                                                  value:Subcatestate.ddValue,
                                                  hint: const Text(
                                                    'Choose SubCategory',
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                  decoration: InputDecoration(
                                                    fillColor: Colors.grey,
                                                    contentPadding: const EdgeInsets.only(
                                                        left: 0, top: 15, bottom: 15),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(15),
                                                    ),
                                                  ),
                                                  key: UniqueKey(),
                                                  items: Subcatestate.cateList
                                                      .map<DropdownMenuItem<String?>>(
                                                          (e) {
                                                    return DropdownMenuItem<String>(
                                                      value: e.sId,
                                                      child: SizedBox(
                                                        width: context.screenWidth/1.5,
                                                          child: Text(e.name!,overflow: TextOverflow.ellipsis,)),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    print(value);
                                                   context.read<SubCategoryBloc>().add(SubCateChangeDropValueEvent(subCateId: value,list: Subcatestate.cateList));
                                                    context.read<SubCategory1Bloc>().add(SubCategory1LoadEvent(rootId: value));
                                                  },
                                                ),
                                              ),
                                              GestureDetector(child: Icon(Icons.add_circle,size: 30),onTap: () {
                                                print("subcategory root id == ${Subcatestate.ddValue}");
                                                context.showNewDialog(AlertDialog(title: Text('Are you sure you want to save as Subcategory.'),actions: [
                                                  ElevatedButton(onPressed: () {
                                                    context.read<QuickImportBloc>().add(
                                                        ButtonPressedEvent(
                                                            quickAddId: widget.quickAddId,
                                                            mediaType: widget.mediaType,
                                                            title: widget.title,
                                                            rootId: Subcatestate.ddValue,
                                                        resourceContent: widget.resourcecontent
                                                        ));
                                                    context.read<CategoryBloc>()
                                                        .add(CategoryLoadEvent());
                                                  }, child: const Text('Save')),
                                                  ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'))
                                                ],));



                                              },)
                                            ],
                                          ),
                                        ],
                                      );
                              }
                              return const SizedBox();
                            },
                          ),

                          SizedBox(
                            height: context.screenHeight * 0.1,
                          ),

                          ///sub Category 1 DropDown
                          BlocBuilder<SubCategory1Bloc,SubCategory1State>(
                            builder: (context, subState1) {
                              print(subState1);
                              print('subState1');
                              if( subState1 is SubCategory1Loaded){
                                return subState1.cateList.isEmpty? const SizedBox():
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField2(
                                              value:subState1.ddValue,
                                              hint: const Text(
                                                'Choose SubCategory',
                                                style: TextStyle(color: Colors.black),
                                              ),
                                              decoration: InputDecoration(
                                                fillColor: Colors.grey,
                                                contentPadding: const EdgeInsets.only(
                                                    left: 0, top: 15, bottom: 15),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(15),
                                                ),
                                              ),
                                              key: UniqueKey(),
                                              items: subState1.cateList
                                                  .map<DropdownMenuItem<String?>>(
                                                      (e) {
                                                    return DropdownMenuItem<String>(
                                                      value: e.sId,
                                                      child: SizedBox(
                                                          width: context.screenWidth/1.5,
                                                          child: Text(e.name!,overflow: TextOverflow.ellipsis,)),
                                                    );
                                                  }).toList(),
                                              onChanged: (value) {
                                                print(value);
                                                context.read<SubCategory1Bloc>().add(DDValueSubCategoryChanged(ddValue: value,cateList: subState1.cateList));
                                                context.read<SubCategory2Bloc>().add(SubCategory2LoadEvent(rootId: value));
                                              },
                                            ),
                                          ),
                                          GestureDetector(child: Icon(Icons.add_circle,size: 30),onTap: () {
                                          print("subcategory id ====-==-==-${subState1.ddValue ??state.list!.first.sId}");
                                            context.showNewDialog(AlertDialog(title: Text('Are you sure you want to save as Subcategory.'),actions: [
                                              ElevatedButton(onPressed: () {
                                                context.read<QuickImportBloc>().add(
                                                    ButtonPressedEvent(
                                                        quickAddId: widget.quickAddId,
                                                        mediaType: widget.mediaType,
                                                        title: widget.title,
                                                        rootId: subState1.ddValue??state.list!.first.sId));
                                                context.read<CategoryBloc>()
                                                    .add(CategoryLoadEvent());
                                              }, child: const Text('Save')),
                                              ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'))
                                            ],));



                                          },)
                                        ],
                                      ),
                                    ],
                                  );

                              }
                              return const SizedBox();
                            },),
                        ],
                      ),
                    );
                  } else {
                    return const Text('No Category Found');
                  }
                } else {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                }
              },
            ),
          ],
        )
    );
  }
  void _saveAsCatShowDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.close)),
                ],
              ),

              Text('Enter new category name'),
            ],
          ),
          content: Container(
            decoration: BoxDecoration(
              border: Border.all(), // Add a border
              borderRadius: BorderRadius.circular(8.0), // Add rounded corners
            ),
            child: TextField(
              controller: categoryNameController,
              decoration: InputDecoration(
                hintText: 'Enter Category Name',
                border: InputBorder.none, // Remove the underline
                contentPadding: EdgeInsets.all(8.0), // Add padding
              ),
            ),
          ),
          actions: <Widget>[
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
                        height: 25,
                        width: 25,
                        color: pickedColor ?? Colors.green)),
                const Text('  Choose Color ')
              ],
            ),

            SizedBox(height: 10,),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                child: Text('Save'),
                onPressed: (){
                  print(_controller!.getTags);
                  if (categoryNameController.text.isEmpty) {
                    context.showSnackBar(const SnackBar(
                        content: Text('Category name is requried')));
                  } else {
                    addCategory();
                  }
                }

              ),
            ),
          ],
        );
      },
    );
  }

}
