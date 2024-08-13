
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../utilities/shared_pref.dart';
import '../../widgets/popup_menu_widget.dart';
import '../add_category/data/model/add_cate_model.dart';
import '../subcate1.1/bloc/sub_cate1_bloc.dart';
import '../subcate1.1/bloc/sub_cate1_event.dart';
import '../subcate1.1/sub_category_1.1_screen.dart';
import '../subcate1.2/final_resources_screen.dart';
import '../subcate1.2/sub_category_1.2_screen.dart';
import '../subcategory/bloc/sub_cate_bloc.dart';
import '../subcategory/bloc/sub_cate_event.dart';
import '../subcategory/sub_cate_screen.dart';
import 'package:http/http.dart' as http;

import 'bottomSheetCubit/main_bottom_sheet_cubit.dart';


class MyNode {
  final String sId;
  final String userId;
  final String name;
  final List<String> keywords;
  final List<Styles> styles;
  final List<MyNode> children;

  const MyNode({
    required this.sId,
    required this.userId,
    required this.name,
    required this.keywords,
    required this.styles,
    this.children = const <MyNode>[],
  });
}

class MyTreeView extends StatefulWidget {
  final String mainRootId;
  final List<MyNode> root;


  const MyTreeView({
    required this.root,
    required this.mainRootId

});

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  // In this example a static nested tree is used, but your hierarchical data
  // can be composed and stored in many different ways.





  // This controller is responsible for both providing your hierarchical data
  // to tree views and also manipulate the states of your tree nodes.
  late final TreeController<MyNode> treeController;

  @override
  void initState() {
    print("my nodedata=>${widget.root[0].name}");
    super.initState();
    treeController = TreeController<MyNode>(
      // Provide the root nodes that will be used as a starting point when
      // traversing your hierarchical data.
      roots: widget.root,
      // Provide a callback for the controller to get the children of a
      // given node when traversing your hierarchical data. Avoid doing
      // heavy computations in this method, it should behave like a getter.
      childrenProvider: (MyNode node) => node.children,
    );
  }

  @override
  void dispose() {
    // Remember to dispose your tree controller to release resources.
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This package provides some different tree views to customize how
    // your hierarchical data is incorporated into your app. In this example,
    // a TreeView is used which has no custom behaviors, if you wanted your
    // tree nodes to animate in and out when the parent node is expanded
    // and collapsed, the AnimatedTreeView could be used instead.
    //
    // The tree view widgets also have a Sliver variant to make it easy
    // to incorporate your hierarchical data in sophisticated scrolling
    // experiences.
    return TreeView<MyNode>(
      // This controller is used by tree views to build a flat representation
      // of a tree structure so it can be lazy rendered by a SliverList.
      // It is also used to store and manipulate the different states of the
      // tree nodes.
      treeController: treeController,
      // Provide a widget builder callback to map your tree nodes into widgets.
      nodeBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
        // Provide a widget to display your tree nodes in the tree view.
        //
        // Can be any widget, just make sure to include a [TreeIndentation]
        // within its widget subtree to properly indent your tree nodes.
        return MyTreeTile(
          mainRootId: widget.mainRootId,

          // Add a key to your tiles to avoid syncing descendant animations.
          key: ValueKey(entry.node),
          // Your tree nodes are wrapped in TreeEntry instances when traversing
          // the tree, these objects hold important details about its node
          // relative to the tree, like: expansion state, level, parent, etc.
          //
          // TreeEntrys are short lived, each time TreeController.rebuild is
          // called, a new TreeEntry is created for each node so its properties
          // are always up to date.
          entry: entry,


          // Add a callback to toggle the expansion state of this node.
          onTap: () => treeController.toggleExpansion(entry.node),
        );
      },
    );
  }
}

// Create a widget to display the data held by your tree nodes.
class MyTreeTile extends StatefulWidget {
   MyTreeTile({
    super.key,
    required this.entry, required this.onTap,
     required this.mainRootId
      });

  final TreeEntry<MyNode> entry;
  final VoidCallback onTap;
  final String mainRootId;

  @override
  State<MyTreeTile> createState() => _MyTreeTileState();
}

class _MyTreeTileState extends State<MyTreeTile> {
  void navigate({required BuildContext context}){
    if (widget.entry.level == 0) {
Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return SubCategory1Screen(
            keyWords: widget.entry.node.keywords,
            color: Colors.red,
            rootId: widget.entry.node.sId,
            subCateTitle: widget.entry.node.name,
          );
        },
      )).then((value){
        if(value){
          setState(() {
            context.read<MainBottomSheetCubit>().onGetSubCategoryList(
                rootId: widget.mainRootId);
          });
        };
      });      // Navigate to the first screen
    } else if (widget.entry.level == 1) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return SubCategory2Screen(
            keyWords: widget.entry.node.keywords,
            color: Colors.red,
            rootId: widget.entry.node.sId,
            subCateTitle: widget.entry.node.name,
          );
        },
      ));    } else if (widget.entry.level == 2) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return FinalResourceScreen(
            keyWords: widget.entry.node.keywords,
            color: Colors.red,
            rootId: widget.entry.node.sId,
            categoryName: widget.entry.node.name,
          );
        },
      ));    }
  }

   Color? pickedColor = Colors.green;

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

   Future<int?> addCategory({required String rootId}) async {
     EasyLoading.show();
     Map<String, dynamic> payload = {};
     List<String> keywords = _controller.getTags!;
     List<Map<String, String>> styles = [
       {"key": "font-size", "value": "2rem"},
       {"key": "background-color", "value": pickedColor!.value.toString()}
     ];
     payload.addAll({
       "name": categoryNameController.text,
     });
     payload.addAll({"keywords": keywords});
     payload.addAll({"styles": styles});
     payload.addAll({
       "rootId": rootId,
     });
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
       if (res.statusCode == 201) {
         EasyLoading.dismiss();
         context.showSnackBar(
             SnackBar(content: Text('Subcategory created successfully')));
         context.read<SubCategory1Bloc>()
             .add(SubCategory1LoadEvent(rootId: widget.mainRootId));
         context
             .read<SubCategoryBloc>()
             .add(SubCategoryLoadEvent(rootId: widget.mainRootId));
         setState(() {
           context.read<MainBottomSheetCubit>().onGetSubCategoryList(
               rootId: widget.mainRootId.toString());
         });
         Navigator.pop(context, true);

       } else {
         EasyLoading.dismiss();
         EasyLoading.showError("Server Error");
         context.showSnackBar(
             const SnackBar(content: Text('opps something went worng')));
       }
     } on SocketException catch (e) {
       EasyLoading.dismiss();
       EasyLoading.showError(e.toString());
       context.showSnackBar(
           const SnackBar(content: Text('No internet connection...')));
     } finally {
     }

     return null;
   }

  @override
  void _showDialog({required BuildContext context,required String rootId }) {
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
                    height: context.screenHeight * 0.05,
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
                        if (categoryNameController.text.isEmpty ||
                            categoryNameController == null) {
                          context.showSnackBar(const SnackBar(
                              content: Text('Category Name is Requried')));
                        } else {
                          addCategory(rootId: rootId);
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
    // Define colors for card gradients
    Color cardColor = Colors.red.shade50; // Light red color for the root card
    if (widget.entry.level == 0) {
      cardColor = Colors.cyan.shade100;
    } else if (widget.entry.level == 1) {
      cardColor = Colors.cyan.shade50;
    } else if (widget.entry.level == 2) {
      // Darker red color for the second level
      cardColor = Colors.cyan.shade100;
    }

    // Calculate and format the child count
    String childCount = widget.entry.node.children.length.toString();

    // Display the index of the entry, starting from 1
    int index = widget.entry.index != null ? widget.entry.index + 1 : 0;
    String indexString = index != 0 ? index.toString() : "";

    return InkWell(
      onTap: widget.onTap,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: TreeIndentation(
          entry: widget.entry,
          guide: const IndentGuide.connectingLines(indent: 48),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cardColor, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Display the count for entry level 1
                  if (widget.entry.level == 1)
                    Text(
                      childCount,
                      style: TextStyle(
                        color: Colors.green, // Choose your desired color
                        fontWeight: FontWeight.bold,
                      ),
                    ),


                  // Display the index and folder icon for root level
                  if (widget.entry.level == 0)
                    GestureDetector(
                      onTap: () {
                        // Handle onTap for root level
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 12),
                        child: Row(
                          children: [
                            Text(
                              indexString,
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.folder,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.entry.level > 0) // Display only one folder icon for non-root levels
                    Container(
                      margin: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.folder,
                        color: Colors.red,
                      ),
                    ),
                  FolderButton(
                    isOpen: widget.entry.hasChildren ? widget.entry.isExpanded : null,
                    onPressed: widget.entry.hasChildren ? widget.onTap : null,
                  ),

                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.entry.node.name}',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  // Display the count
                  Spacer(),
                  InkWell(
                    onTap: () {
                      // Handle onTap for the "near me" icon
                      navigate(context: context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.shade200,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(Icons.near_me_sharp, color: Colors.red),
                    ),
                  ),

                  SizedBox(width: 5,),
                  // Show create_new_folder button only when entry level is not 2
                  if (widget.entry.level != 2)
                    InkWell(
                      onTap: () {
                        _showDialog(context: context, rootId: widget.entry.node.sId);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.create_new_folder, color: Colors.white),
                      ),
                    ),
                  PopupMenuWidget(categoryName: widget.entry.node.name, categoryId: widget.entry.node.sId, level: "Level${widget.entry.level+2}",
                  ), // Add the PopupMenuWidget here

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}