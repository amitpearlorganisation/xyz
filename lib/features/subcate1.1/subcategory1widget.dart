import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:self_learning_app/features/subcate1.1/summary2bloc/summary2_bloc.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

import '../../../utilities/colors.dart';
import '../../../utilities/shared_pref.dart';
import '../../../widgets/add_resources_screen.dart';
import '../../utilities/constants.dart';
import '../../widgets/AddResourcewidget.dart';
import '../../widgets/flowView.dart';
import '../../widgets/resourceScreenWidget.dart';
import '../create_flow/bloc/create_flow_screen_bloc.dart';
import '../create_flow/create_flow_screen.dart';
import '../create_flow/flow_screen.dart';
import '../resources/maincategory_resources_screen.dart';
import '../subcate1.2/sub_category_1.2_screen.dart';
import '../subcategory/SummaryBloc/summary_bloc.dart';
import '../subcategory/model/sub_cate_model.dart';
import '../update_category/update_cate_screen.dart';
import 'bloc/sub_cate1_bloc.dart';
import 'bloc/sub_cate1_event.dart';
import 'bloc/sub_cate1_state.dart';
import 'create_subcate1_screen.dart';
import 'model/sub_cate_model.dart';

class SubCategory1Widget extends StatefulWidget {
  final String? rootId;
  final Color? color;
  final String? categoryName;
  final int ? level;

  SubCategory1Widget({required this.rootId, required this.color, required this.categoryName, required this.level});
  @override
  State<SubCategory1Widget> createState() => _SubCategory1WidgetState();
}

class _SubCategory1WidgetState extends State<SubCategory1Widget> {
  TextEditingController summaryController = TextEditingController();

  @override
  void initState() {
    context.read<Summary2Bloc>().add(
        Summary2LoadedEvent(rootId: widget.rootId));
    context.read<SubCategory1Bloc>().add(
        SubCategory1LoadEvent(rootId: widget.rootId));
    context.read<CreateFlowBloc>().add(LoadAllFlowEvent(catID: widget.rootId!));
    super.initState();

  }
  addCategory({required String summary}) async {
    EasyLoading.show();

    print("_---rood id is ${widget.rootId}");
    final Dio _dio = Dio();
    var token = await SharedPref().getToken();
    Map<String, dynamic> headers = {
      'Authorization': 'bearer' + ' ' + token.toString(),
    };
    String base = DEVELOPMENT_BASE_URL;
    String endPoint = "category/${widget.rootId}";
    var url = base + endPoint;
    var res = await _dio.patch(
      'https://backend.savant.app/web/category/${widget.rootId}',
      data: {"summary": summary},
      options: Options(headers: headers),
    );
    print("main category update ${res.data}");
    if (res.statusCode == 200) {
      EasyLoading.dismiss();
      summaryController.clear();
      context.showSnackBar(
          SnackBar(content: Text('Summary added successfully')));
      context.read<Summary2Bloc>().add(Summary2LoadedEvent(rootId: widget.rootId));
      setState(() {

      });
    } else {
      context.showSnackBar(
          const SnackBar(content: Text('opps something went worng')));
    }
    print('data');
  }
  AwesomeDialog showDeleteSummary({
    required List<String> summaryList1,
    required BuildContext context,
  }) {
    return AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      dialogType: DialogType.QUESTION,
      body: Center(
        child: Text(
          'Are you sure\nYou want to delete summary',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {
        updateSummary(summaryList:summaryList1 );
      },
      btnOkColor: Colors.red,
      closeIcon: Icon(Icons.close),
      btnCancelOnPress: () {},
      btnOkText: "Delete",
      btnOkIcon: Icons.delete,
    )..show();
  }
  AwesomeDialog DeleteCategory({
    required String catID,
    required String catName,
    required List<SubCategory1Model> cateList,
    required int index

  }) {
    return AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      dialogType: DialogType.QUESTION,
      body: Center(
        child: Text(
          'Are you sure\nYou want to delete $catName',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {
        context.read<SubCategory1Bloc>().add(
            SubCategory1DeleteEvent(
              rootId: catID ??
                  '',
              context: context,
              catList: cateList,
              deleteIndex: index,
            ));
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
  void dispose() {
    super.dispose();
  }

  List<String> summary = [];
  void updateSummary({required List<String> summaryList})async{
    final Dio _dio = Dio();
    var token = await SharedPref().getToken();
    Map<String, dynamic> headers = {
      'Authorization': 'bearer' + ' ' + token.toString(),
    };

    print("summary list in update summary $summaryList");
    var res = await _dio.patch(
      'https://backend.savant.app/web/category/update/summary/${widget.rootId}',
      data: {"summary": summaryList},
      options: Options(headers: headers),
    );
    print("status code known ${res.statusCode}");
    if(res.statusCode ==200){
      EasyLoading.showSuccess("Summary deleted successfully");
      print("summary deleted successfully");
      setState(() {
        context.read<Summary2Bloc>().add(
            Summary2LoadedEvent(rootId: widget.rootId));
        context.read<SubCategory1Bloc>().add(
            SubCategory1LoadEvent(rootId: widget.rootId));
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(


        floatingActionButton: ElevatedButton(
        child: Text("Create SubCategory"),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateSubCate1Screen(rootId: widget.rootId,
            subCatName: widget.categoryName,
          ))).then((value) {
            if(value){
              setState(() {
                context.read<SubCategory1Bloc>().add(
                    SubCategory1LoadEvent(rootId: widget.rootId));
              });
            }
          });
        },
      ),
      body:
      Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(

                child:
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8 ,vertical: 5),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.1,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(width: 1.5, color: Colors.grey.shade200)
                  ),
                  child: TextField(
                    controller: summaryController ,
                    maxLines: 8,
                    style: TextStyle(letterSpacing: 2,color: Colors.black87),
                    decoration: InputDecoration(

                      hintText: 'Add Summary .....',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 8,bottom: 5),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.red.shade200,
                    borderRadius: BorderRadius.circular(45)
                ),
                child: IconButton(
                  onPressed: (){
                    if(summaryController.text.trim().isNotEmpty) {
                      addCategory(summary: summaryController.text);
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Summary is empty'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating, // Optional: behavior
                          clipBehavior: Clip.antiAlias, // Optional: clip behavior


                        ),
                      );                    }
                  },
                  icon: Icon(Icons.send, color: Colors.green,size: 20,),
                ),
              )

            ],
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height*0.3,
            child: BlocBuilder<Summary2Bloc, Summary2State>(builder: (context, state){
              if(state is Summary2Loading){
                return SizedBox();
                //   Center(
                //   child: Container(
                //     height: 50,
                //     width: 50,
                //     child: CircularProgressIndicator(),
                //   ),
                // );
              }
              if(state is Summary2LoadedState){
                summary.clear();
                for(var data in state.sumaryList[0].summary){
                  summary.add(data);
                }

                return CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate
                            : SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                List<String>? sumary =state.sumaryList[0].summary; // Use i instead of index
                                for (var sum in sumary!){
                                  print("hello this is summary checking $sum");
                                }
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(width: 0.2, color: Colors.black87),
                              ),
                              child: ListTile(
                                title: Text(
                                  state.sumaryList[0].summary[index], // Use i instead of index
                                  style: TextStyle(
                                    fontWeight: FontWeight.w100,
                                    color: Colors.black87,
                                    fontSize: 13,
                                    letterSpacing: 1,
                                    decorationThickness: 0.5,
                                    wordSpacing: 1,
                                    height: 1.2,
                                  ),
                                ),
                                trailing: IconButton(onPressed: (){

                                  sumary.removeAt(index);
                                  for(var sum in sumary){
                                    print("now we can see the remaining summary and that ist $sum");
                                  }

                                  // updateSummary(summaryList: sumary);
                                  showDeleteSummary(summaryList1: sumary, context: context);

                                },
                                    icon: Icon(Icons.delete)
                                ),
                                
                              ),
                            );
                          },
                          childCount: state.sumaryList[0].summary.length,
                        ),
                      )]
                );


              }

              return Center(child: Text("Something wents wrong"),);

            }),
          ),
          Expanded(
            child: BlocBuilder<SubCategory1Bloc, SubCategory1State>(
              builder: (context, state) {
                if(state is SubCategory1Loading){
                  return Center(
                    child: Container(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if(state is SubCategory1Loaded){

                  return  CustomScrollView(

                    slivers: [


                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () async {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return

                                      SubCategory2Screen(
                                        subCateTitle:
                                        state.cateList[index].name!,
                                        rootId: state.cateList[index].sId!,
                                        color: widget.color,
                                        keyWords:
                                        state.cateList[index].keywords!,
                                      );
                                  },
                                ));

                              },
                              child: Card(
                                elevation: 1,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                shadowColor: Colors.grey.shade50,
                                child:
                                Slidable(
                                  enabled: true,
                                  key: const ValueKey(0),
                                  startActionPane: ActionPane(
                                    motion: const ScrollMotion(),


                                    // dismissible: DismissiblePane(onDismissed: () {}),
                                    children: [
                                      // A SlidableAction can have an icon and/or a label.
                                      SlidableAction(
                                        onPressed: (BuildContext context) {
                                          Navigator.push(context, MaterialPageRoute(
                                              builder: (context) =>
                                                  AddResourceWidget(
                                                    rootId: state.cateList[index]
                                                        .sId!,
                                                    whichResources: 1,
                                                    categoryName: state
                                                        .cateList[index].name!,)
                                          ));
                                        },
                                        autoClose: false,
                                        backgroundColor: Color(0xFFFE4A49),
                                        foregroundColor: Colors.white,
                                        icon: Icons.folder,
                                        label: 'Add Resource',
                                      ),
                                      SlidableAction(
                                        onPressed: (BuildContext context) {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context) =>
                                                resourceScreenWidget(
                                                    level: "Level 1",
                                                    rootId: state.cateList[index]
                                                        .sId!,
                                                categoryName: state.cateList[index]
                                                        .name!),));
                                        },
                                        backgroundColor: Color(0xFF21B7CA),
                                        autoClose: false,

                                        foregroundColor: Colors.white,
                                        icon: Icons.view_array,
                                        label: 'View Resource',
                                      ),
                                    ],
                                  ),
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    // dismissible: DismissiblePane(onDismissed: () {}),
                                    children: [
                                      SlidableAction(
                                        // An action can be bigger than the others.
                                        flex: 2,
                                        onPressed: (BuildContext context) {
                                          Navigator.push(context, MaterialPageRoute(
                                              builder: (context) {
                                                return CreateFlowScreen(
                                                  rootId: state.cateList[index].sId!, categoryName: widget.categoryName??"",
                                                );
                                              }));
                                        },
                                        backgroundColor: Color(0xFF7BC043),
                                        autoClose: false,
                                        foregroundColor: Colors.white,
                                        icon: Icons.create,
                                        label: 'Create flow',
                                      ),
                                      SlidableAction(
                                        onPressed: (BuildContext context) {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context) {
                                              return ViewFlow(
                                                rootId: state.cateList[index].sId!,
                                                categoryname: widget.categoryName??"",
                                              );
                                            },
                                          ));
                                        },
                                        backgroundColor: Color(0xFF0392CF),
                                        autoClose: false,
                                        foregroundColor: Colors.white,
                                        icon: Icons.view_agenda,
                                        label: 'View Flow',
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      state.cateList[index].name.toString(),
                                      style: const TextStyle(
                                          color: primaryColor),
                                    ),
                                    trailing: PopupMenuButton(
                                      icon: Icon(
                                        Icons.arrow_drop_down, color: Colors.red,),
                                      itemBuilder: (context) {
                                        return [
                                          const PopupMenuItem(
                                              value: 'update',
                                              child: InkWell(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .start,
                                                    children: [
                                                      Icon(Icons.update,
                                                        color: primaryColor,),
                                                      SizedBox(width: 8.0,),
                                                      Text("update"),
                                                    ],
                                                  ))
                                          ),
                                          const PopupMenuItem(
                                              value: 'delete',
                                              child: InkWell(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .start,
                                                    children: [
                                                      Icon(Icons.delete,
                                                        color: primaryColor,),
                                                      SizedBox(width: 8.0,),
                                                      Text("delete"),
                                                    ],
                                                  ))
                                          ),
                                        ];
                                      },
                                      onSelected: (String value) {
                                        switch (value) {
                                          case 'update':
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) {
                                                return UpdateCateScreen(
                                                  rootId: state.cateList[index].sId,
                                                  selectedColor: widget.color,
                                                  categoryTitle: state.cateList[index]
                                                      .name,
                                                  tags: state.cateList[index]
                                                      .keywords,
                                                );
                                              },
                                            )).then((value) {
                                              setState(() {
                                                context.read<Summary2Bloc>().add(
                                                    Summary2LoadedEvent(rootId: widget.rootId));
                                                context.read<SubCategory1Bloc>().add(
                                                    SubCategory1LoadEvent(rootId: widget.rootId));
                                                context.read<CreateFlowBloc>().add(LoadAllFlowEvent(catID: widget.rootId!));
                                              });
                                            });

                                            break;
                                          case 'delete':
                                            print("object");
                                            DeleteCategory(catName: state.cateList[index].name ??
                                                '', catID: state.cateList[index].sId.toString(),
                                                cateList: state.cateList,
                                                index: index
                                            );

                                            break;
                                        }
                                      },
                                    ),

                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: state.cateList.length,
                        ),
                      ),

                    ],
                  );

                }
                return SizedBox();
              },
            ),
          ),
        ],
      ),

    );
  }
}
