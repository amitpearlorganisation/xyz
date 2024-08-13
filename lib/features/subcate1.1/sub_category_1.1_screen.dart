import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:self_learning_app/features/create_flow/bloc/create_flow_screen_bloc.dart';
import 'package:self_learning_app/features/subcate1.1/subcategory1widget.dart';
import 'package:self_learning_app/features/subcategory/update_subcategory.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

import '../../utilities/colors.dart';
import '../../utilities/shared_pref.dart';
import '../../widgets/SubCategoryWidget.dart';
import '../../widgets/add_resources_screen.dart';
import '../create_flow/create_flow_screen.dart';
import '../create_flow/flow_screen.dart';
import '../resources/bloc/resources_bloc.dart';
import '../resources/maincategory_resources_screen.dart';
import '../search_subcategory/search_sub_cat.dart';
import '../subcate1.2/sub_category_1.2_screen.dart';
import '../subcategory/SummaryBloc/summary_bloc.dart';
import '../subcategory/bloc/sub_cate_bloc.dart';
import '../subcategory/bloc/sub_cate_event.dart';
import '../subcategory/bloc/sub_cate_state.dart';
import '../subcategory/primaryflow/primaryflow.dart';
import '../update_category/update_cate_screen.dart';
import 'bloc/sub_cate1_bloc.dart';
import 'bloc/sub_cate1_event.dart';
import 'bloc/sub_cate1_state.dart';
import 'create_subcate1_screen.dart';


class SubCategory1Screen extends StatefulWidget {
  final String subCateTitle;
  final List<String>  keyWords;
  final String rootId;
  final Color? color;


  const SubCategory1Screen({Key? key, required this.subCateTitle, required this.rootId, this.color, required this.keyWords}) : super(key: key);

  @override
  State<SubCategory1Screen> createState() => _SubCategory1ScreenState();
}

class _SubCategory1ScreenState extends State<SubCategory1Screen> {
  List<String> mediaTitle = [
    'Take Picture',
    'Record Video',
    'Record Audio',
    'Enter Text'
  ];
  bool value = false;
  final TextEditingController _flowSearchController = TextEditingController();
  TextEditingController summaryController = TextEditingController();
  final TextEditingController _resourceSearchController = TextEditingController();



  List<IconData> mediaIcons = [
    Icons.camera,
    Icons.video_call_outlined,
    Icons.audio_file_outlined,
    Icons.text_increase
  ];
  int _tabIndex = 0;
  CreateFlowBloc _flowBloc = CreateFlowBloc();


  @override
  void initState() {
    print("initstate is working");
    context.read<SummaryBloc>().add(
        SummaryLoadedEvent(rootId: widget.rootId));
    context.read<SubCategory1Bloc>().add(SubCategory1LoadEvent(rootId: widget.rootId));
    context.read<CreateFlowBloc>().add(LoadAllFlowEvent(catID: widget.rootId!));

    super.initState();
    _flowBloc.add(LoadAllFlowEvent(catID: widget.rootId));
  }
  // final List<String> summary = [];


  addSummary({required String summary}) async {
    EasyLoading.show();

    print("_---rood id is ${widget.rootId}");
    final Dio _dio = Dio();
    var token = await SharedPref().getToken();
    Map<String, dynamic> headers = {
      'Authorization': 'bearer' + ' ' + token.toString(),
    };

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
      context.read<SummaryBloc>().add(SummaryLoadedEvent(rootId: widget.rootId));
      setState(() {

      });
    } else {
      context.showSnackBar(
          const SnackBar(content: Text('opps something went worng')));
    }
    print('data');
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(

      length: 3,
      child: Scaffold(

          appBar: AppBar(
            leading: IconButton(onPressed: (){
                Navigator.pop(context, true);


            }, icon: Icon(Icons.arrow_back),),
              title: Text(widget.subCateTitle),
              actions: [

                IconButton(
                    onPressed: () {
/*
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return BlocProvider<CreateFlowBloc>.value(value: _flowBloc, child: FlowScreen(
                            rootId: widget.rootId!,
                          ));
                        },
                      ));
*/
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>PrimaryFlow(
                        categoryName: widget.subCateTitle,
                        CatId: widget.rootId.toString(),flowId: "0",)));

                    },
                    icon: Icon(Icons.play_circle)
                ),

              ]
          ),
          body:
          Column(
            children: [

              Container(
                height: 50,
                color: Color(0xffFF8080),
                child: TabBar(
                  labelColor: Colors.blueAccent,
                  unselectedLabelColor: Colors.white,
                  indicatorColor: Colors.red,
                  indicatorWeight: 4,
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 16),
                  labelPadding: EdgeInsets.zero,
                  automaticIndicatorColorAdjustment: true,
                  tabs: [
                    Text("Subcategory"),
                    Text("Resource"),
                    Text("Flows"),

                  ],
                ),
              ),
              Expanded(child: TabBarView(
                children: <Widget> [
                  Column(
                    children: [
                      SizedBox(
                        width: context.screenWidth,
                        height: context.screenHeight * 0.08,
                        child: BlocBuilder<SubCategory1Bloc, SubCategory1State>(
                          builder: (context, state) {
                            if (state is SubCategoryLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            else if (state is SubCategory1Loaded) {
                              List<Map<String, dynamic>> searchList = state.cateList.map((
                                  item) {
                                return {
                                  'title': item.name.toString(),
                                  'sId': item.sId.toString(),
                                  'keywords': item.keywords.toString(),
                                };
                              }).toList();
                              print("-=-=-===-==$searchList");
                              return Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                          child: GestureDetector(

                                            onTap: () async {
                                              await showSearch(
                                                context: context,
                                                delegate: CustomSubCatSearchDelegate(
                                                    rootId: widget.rootId.toString()),
                                              );
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(left: 15),
                                              height: context.screenHeight * 0.058,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(10)
                                              ),

                                              child: Padding(
                                                padding: EdgeInsets.only(left: 20,bottom: 10, top: 10),
                                                child: Text('Search..', style: TextStyle(
                                                    color: Colors.black.withOpacity(0.5)
                                                ),),
                                              ),
                                            ),
                                          )
                                      ),
                                    ),

                                  ],
                                ),
                              );
                            }

                            return SizedBox();
                          },

                        ),
                      ),
                      Expanded(
                          child: Column(
                            children: [

                              // SizedBox(
                              //   height: 1,
                              //   child: BlocBuilder<SummaryBloc, SummaryState>(builder: (context, state){
                              //     if(state is SummaryLoading){
                              //       return SizedBox();
                              //       //   Center(
                              //       //   child: Container(
                              //       //     height: 50,
                              //       //     width: 50,
                              //       //     child: CircularProgressIndicator(),
                              //       //   ),
                              //       // );
                              //     }
                              //     if(state is SummaryLoadedState){
                              //
                              //
                              //       return  CustomScrollView(
                              //
                              //         slivers: [
                              //
                              //
                              //                                                    SliverList(
                              //                                                       delegate
                              //                                                           : SliverChildBuilderDelegate(
                              //                                                             (BuildContext context, int index) {
                              //                                                           return Container(
                              //                                                             padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              //                                                             margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                              //                                                             decoration: BoxDecoration(
                              //                                                               color: Colors.white70,
                              //                                                               borderRadius: BorderRadius.circular(5),
                              //                                                               border: Border.all(width: 0.2, color: Colors.black87),
                              //                                                             ),
                              //                                                             child: Text(
                              //                                                               state.sumaryList[0].summary[index], // Use i instead of index
                              //                                                               style: TextStyle(
                              //                                                                 fontWeight: FontWeight.w100,
                              //                                                                 color: Colors.black87,
                              //                                                                 fontSize: 13,
                              //                                                                 letterSpacing: 1,
                              //                                                                 decorationThickness: 0.5,
                              //                                                                 wordSpacing: 1,
                              //                                                                 height: 1.2,
                              //                                                               ),
                              //                                                             ),
                              //                                                           );
                              //                                                         },
                              //                                                         childCount: state.sumaryList[0].summary.length,
                              //                                                       ),
                              //                                                     ),
                              //
                              //         ],
                              //       );
                              //
                              //
                              //
                              //     }
                              //
                              //     return Center(child: Text("Something wents wrong"),);
                              //
                              //   }),
                              // ),
                              Expanded(
                                child: SubCategory1Widget(color: widget.color,categoryName: widget.subCateTitle, level: 2,rootId: widget.rootId,)
                              ),
                            ],
                          ),

                        // SubCategoryWidget(color: widget.color,categoryName: widget.subCateTitle,rootId: widget.rootId,level: 2,)
                      ),
                    ],
                  ),
                  // resource column is this
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey.shade300,width: 1.5),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child:             Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              controller: _resourceSearchController,
                              onChanged: (value) {
                                print("Text changed: $value");
                                context.read<ResourcesBloc>().add(
                                    LoadResourcesEvent(rootId: widget.rootId.toString(), mediaType: "",resourcQueary: value)
                                );



                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search resource...',
                              ),
                            )
                        ),

                      ),
                      Expanded(
                        child: MaincategoryResourcesList(rootId: widget.rootId!,
                            level: "Level 1",
                            mediaType: '',
                            title: widget.subCateTitle!),
                      )

                    ],
                  ),

                  // Flows column is that
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey.shade300,width: 1.5),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child:  Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              controller: _flowSearchController,
                              onChanged: (value) {
                                print("Text changed: $value");
                                context.read<CreateFlowBloc>().add(LoadAllFlowEvent(catID: widget.rootId!,keyword: value));

                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search flow...',
                              ),
                            )
                        ),
                      ),

                      Expanded(
                        child: FlowScreen(
                          rootId: widget.rootId!,
                          categoryname: widget.subCateTitle??"",
                        ),
                      ),
                    ],
                  )


                ],
              ))


            ],
          ),


      ),
    );
  }
}
