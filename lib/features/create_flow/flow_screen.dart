

import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:self_learning_app/features/create_flow/bloc/create_flow_screen_bloc.dart';
import 'package:self_learning_app/features/create_flow/data/model/flow_model.dart';
import 'package:self_learning_app/features/create_flow/show_prompts_screen.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../utilities/shared_pref.dart';
import '../add_promts/add_promts_screen.dart';
import '../add_promts_to_flow/add_promts_to_flow_screen.dart';
import '../promt/promts_screen.dart';
import '../resources/bloc/resources_bloc.dart';
import '../resources/maincategory_resources_screen.dart';
import 'create_flow_screen.dart';

class FlowScreen extends StatefulWidget {
  final String rootId;
  final String categoryname;
  const FlowScreen({super.key, required this.rootId, required this.categoryname});

  @override
  State<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  List<int> saveIndex = [];
  List<FlowModel> getFlowId = [];

  bool isSelected = false; // Define isSelected variable to track checkbox selection
  int selectedIndex = -1;
  final TextfieldTagsController _controller = TextfieldTagsController();


  @override

  Future<void> PrimaryfetchData() async {
    try {
      final idList = await getPrimaryflow(catId: widget.rootId);

      setState(() {
        getFlowId.clear();
        getFlowId = idList;
        print("to get flow id===>${getFlowId.length}");
      });
    } catch (error) {
      print('Error: $error');
    }
  }
  Future<List<FlowModel>> getPrimaryflow({required String catId})async {
    Response response;
    List<FlowModel> flowList = [];

    try{
      final token = await SharedPref().getToken();
      response = await Dio().get(
          'https://backend.savant.app/web/flow?categoryId=$catId&type=primary',
          options: Options(
              headers: {"Authorization": 'Bearer $token'}
          ),
          data: {'type':'primary'}

      );

      print("checking flow id in this data ${response.data}");
      print("checkPrimaryResponse====${response.data["data"]["record"][0]['type']}");
      print("--------->Break");
      print("catId ---$catId");

      if(response.statusCode == 400){
        throw Exception('Failed to fetch data from the API');
      }
      if(response.statusCode==200 && response.data['data']['record'][0]['type'] == 'primary'){

        for(var item in response.data['data']['record']) {


          flowList.add(FlowModel(
            title: item['title'],
            id: item['_id'],
            categoryId: item['categoryId'],
            flowList: [],
          ));
        }
        return flowList;
        }

  }on DioError catch (e) {
      print(e);
      throw e;
    }
 return flowList;
  }
  AwesomeDialog Deleteflow({
    required String flowID,
    required String flowName,
    required int index,
    required List<FlowModel> flowList


  }) {
    return AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      dialogType: DialogType.QUESTION,
      body: Center(
        child: Text(
          'Are you sure\nYou want to delete $flowName',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {
        context.read<CreateFlowBloc>().add(
            DeleteFlow(
                flowId: flowID,
                flowList: flowList,
                deleteIndex: index,
                context: context
            )
        );
        // context.read<QuickPromptBloc>().add(DeleteQuickPromptEvent(promptName: promptName,promptId: promptId,index:index
        // ));
      },
      btnOkColor: Colors.red,
      closeIcon: Icon(Icons.close),
      btnCancelOnPress: () {},
      btnOkText: "Delete",
      btnOkIcon: Icons.delete,
    )..show();
  }
  void _showDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController(text: '');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add new Flow'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(width: 1.5, color: Colors.grey)
                ),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter Flow name...',
                    border: InputBorder.none

                  ),

                ),
              ),
              SizedBox(height: 5,),

              Container(

                child: TextFieldTags(
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
              ),

            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Do something with the TextField value

                //bloc.add(CreateAndSaveFlow(title: titleController.text));


                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPromptsToFlowScreen(
                        keywords: _controller.getTags!,
                        title: titleController.text,
                        rootId: widget.rootId, promptList: [],),)).then((value) {
                  if(value != null && value == true){
                    Navigator.pop(context, true);
                  }else{
                    Navigator.pop(context, false);
                  }
                });
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    ).then((value) {
      if(value != null && value == true){
        Future.delayed(Duration(seconds: 1));
        context.read<CreateFlowBloc>().add(LoadAllFlowEvent(catID: widget.rootId));
      }
    });
  }

  void initState() {
    context.read<CreateFlowBloc>().add(LoadAllFlowEvent(catID: widget.rootId));
    PrimaryfetchData();

    super.initState();
  }
  Widget build(BuildContext context) {
    print("ui is refresh");
    return Scaffold(
      floatingActionButton: ElevatedButton(
        child: Text("Create Flow"),
        onPressed: (){
          _showDialog(context);

        },
      ),


      body: BlocConsumer<CreateFlowBloc, CreateFlowState>(
        listener: (context, state) {
          if(state is flowDeletedSuccess){
              context.read<CreateFlowBloc>().add(LoadAllFlowEvent(catID: widget.rootId));

          }
         // if(state is flowSelected){
         //   print("flow select from flow screen");
         // }
         // if(state is flowSelectionFailed){
         //   ScaffoldMessenger(child: Text("opps sorry is selected"),);
         //
         // }

        },
        builder: (context, state) {
          if (state is FlowLoading) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if(state is LoadFailed){
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: const Center(
                child: Text('Failed to Load data!'),
              ),
            );
          }
          if (state is LoadSuccess) {
            if(state.flowList.length == 0){
              return Container(
                height: MediaQuery.of(context).size.height * 0.9,
                child: const Center(
                  child: Text('No Flow created yet!'),
                ),
              );
            }else{
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.flowList.length,
                  itemBuilder: (context, index) {
                    int selectedIndex = -1;

                    final title = state.flowList[index].title;
                    // final isSelected = saveIndex.contains(index);
                    // getFlowId.clear();
                    // PrimaryfetchData();
                    bool isSelected = false;
                     isSelected = getFlowId.any((getFlow) => getFlow.id == state.flowList[index].id);
                    print("to view flow id length==>${isSelected}");
                    print('content');

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(

                          onLongPress: () async {


                            context.read<CreateFlowBloc>().add(FlowSelected(
                                  flowId: state.flowList[index].id,
                                  type: "primary",
                                  flowList: state.flowList,
                                  index: index,
                                rootId: widget.rootId
                              ));
                            await Future.delayed(Duration(seconds: 1));
                             PrimaryfetchData();
                            getPrimaryflow(catId: widget.rootId);



                        },
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ShowPromtsScreen(flowList: state.flowList[index].flowList, flowName: state.flowList[index].title,),));
                        },
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        title: Text(
                          title != null
                              ?'${title.substring(0,1).toUpperCase()}${title.substring(1)}'
                              : 'Untitled',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, ),),
                        leading:  Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Checkbox(
                              value: isSelected, // Set checkbox state based on whether this item is selected
                              onChanged: ( value) async {
                                print("on-------");
                                context.read<CreateFlowBloc>().add(FlowSelected(
                                    flowId: state.flowList[index].id,
                                    type: "primary",
                                    flowList: state.flowList,
                                    index: index,
                                    rootId: widget.rootId
                                ));
                                await Future.delayed(Duration(seconds: 1));
                                PrimaryfetchData();
                                getPrimaryflow(catId: widget.rootId);
                                value = isSelected;
                                setState(() {

                                });


                              },
                            ),
                          ],
                        ),
                      trailing:Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          IconButton(
                            icon: Icon(Icons.update), // Your update icon
                            onPressed: () {
                              List<PromptListModel> promptList = [];
                              state.flowList[index].flowList.forEach((item) {
                                promptList.add(PromptListModel(item.promptName, item.promptId, generateRandomColor()));
                              }
                              );
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddPromptsToFlowScreen(
                                keywords: [],
                                update: true,
                                title: title,
                                flowId: state.flowList[index].id,
                                promptList: promptList,
                                rootId: widget.rootId,
                              ),)).then((value) {
                                context.read<CreateFlowBloc>().add(LoadAllFlowEvent(catID: widget.rootId));
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete), // Your update icon
                            onPressed: () {
                              Deleteflow(index: index,
                              flowName: state.flowList[index].title,
                               flowID: state.flowList[index].id,
                               flowList: state.flowList
                              );
                              }
                              )



                        ],
                      ),
                        /*isSelected==true?
                          Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                    color: Colors.blue.withOpacity(0.3)
                              ),
                              child: Icon(Icons.check, color: Colors.green)):null*/
                      ),

                    );
                  });
            }
          }
          return const Text('something went wrong');
        },
      ),
    );
  }
  Color generateRandomColor() {
    Random random = Random();

    // Define RGB value ranges for white, blue, and gray colors
    final whiteRange = Range(200, 256); // RGB values between 200-255
    final blueRange = Range(0, 100);    // RGB values between 0-100
    final grayRange = Range(150, 200);  // RGB values between 150-199

    Color randomColor;

    do {
      // Generate random RGB values
      int red = random.nextInt(256);
      int green = random.nextInt(256);
      int blue = random.nextInt(256);

      randomColor = Color.fromRGBO(red, green, blue, 1.0);
    } while (whiteRange.contains(randomColor.red) &&
        whiteRange.contains(randomColor.green) &&
        whiteRange.contains(randomColor.blue) ||
        blueRange.contains(randomColor.red) &&
            blueRange.contains(randomColor.green) &&
            blueRange.contains(randomColor.blue) ||
        grayRange.contains(randomColor.red) &&
            grayRange.contains(randomColor.green) &&
            grayRange.contains(randomColor.blue));

    return randomColor;
  }

}

// class SaveIndexModel extends Equatable {
//   final List<int> selectedIndices;
//   // final List<FlowModel> itemList;
//
//   SaveIndexModel(this.selectedIndices);
//
//   @override
//   List<Object?> get props => [selectedIndices];
// }