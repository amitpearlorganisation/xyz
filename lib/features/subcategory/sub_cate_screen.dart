import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mime/mime.dart';
import 'package:photo_view/photo_view.dart';
import 'package:self_learning_app/features/category/bloc/category_state.dart';
import 'package:self_learning_app/features/create_flow/bloc/create_flow_screen_bloc.dart';
import 'package:self_learning_app/features/dashboard/dashboard_screen.dart';
import 'package:self_learning_app/features/flow_screen/start_flow_screen.dart';
import 'package:self_learning_app/features/subcategory/SummaryBloc/summary_bloc.dart';
import 'package:self_learning_app/features/subcategory/create_subcate_screen.dart';
import 'package:self_learning_app/features/subcategory/primaryflow/data/repo/primaryflowRepo.dart';
import 'package:self_learning_app/features/subcategory/primaryflow/primaryflow.dart';
import 'package:self_learning_app/utilities/colors.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';
import 'package:self_learning_app/widgets/add_resources_screen.dart';
import 'package:video_player/video_player.dart';

import '../../widgets/SubCategoryWidget.dart';
import '../add_promts/add_promts_screen.dart';
import '../category/bloc/category_bloc.dart';
import '../create_flow/create_flow_screen.dart';
import '../create_flow/flow_screen.dart';
import '../promt/promts_screen.dart';
import '../resources/bloc/resources_bloc.dart';
import '../resources/maincategory_resources_screen.dart';
import '../resources/subcategory_resources_screen.dart';
import '../search_category/cate_search_delegate.dart';
import '../search_subcategory/search_sub_cat.dart';
import '../subcate1.1/sub_category_1.1_screen.dart';
import '../update_category/update_cate_screen.dart';
import 'bloc/sub_cate_bloc.dart';
import 'bloc/sub_cate_event.dart';
import 'bloc/sub_cate_state.dart';

class SubCategoryScreen extends StatefulWidget {
  final List<String>? tags;
  final Color? color;
  final String? categoryName;
  final String? rootId;

  const SubCategoryScreen({
    Key? key,
    this.categoryName,
    this.rootId,
    this.color,
    this.tags,
  }) : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _flowSearchController = TextEditingController();
  final TextEditingController _resourceSearchController = TextEditingController();
  TextEditingController summaryController = TextEditingController();

  final ResourcesBloc resourcesBloc = ResourcesBloc();



  String? videoContent;
  @override
  void initState() {
    context.read<SummaryBloc>().add(
        SummaryLoadedEvent(rootId: widget.rootId));

    context.read<SubCategoryBloc>().add(
        SubCategoryLoadEvent(rootId: widget.rootId));
    context.read<CreateFlowBloc>().add(LoadAllFlowEvent(catID: widget.rootId!));
    super.initState();
    _searchController.addListener(() {
      // Filter the category list based on the search query.

      // Update the state to re-render the list view.
      setState(() {});
    });
  }

  int _tabIndex = 0;

  Future<void> savecatid() async {
    SharedPref().savesubcateId(widget.rootId!);
  }

  static const TextStyle optionStyle = TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold);
  List<String> searchList = []; // Define searchList at the top of your widget
  List<String> resultList = []; // Results of the search
  List<String> summary = [];
  addCategory({required String summary}) async {
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
  bool _validateTags(String value) {
    // Check if there is more than one space character after a tag
    if (value.contains("  ")) { // Two consecutive spaces
      int index = value.lastIndexOf("  ");
      // Check if the last two spaces are not at the end
      if (index != value.length - 2) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    print("rooooooooot iddddd ${widget.rootId}");
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            centerTitle: false,
            title: Text(widget.categoryName ?? "Subcategory",
              overflow: TextOverflow.ellipsis,),
            actions: [
              IconButton(
                  onPressed: () {

                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            PrimaryFlow(
                              CatId: widget.rootId.toString(), flowId: "1",
                            categoryName: widget.categoryName??"",
                            )));
                    // AddPromptsToPrimaryFlowRepo.getData(mainCatId: widget.rootId.toString());

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
                    SizedBox(height: 5,),
                    SizedBox(
                      width: context.screenWidth,
                      height: context.screenHeight * 0.05,
                      child: BlocBuilder<SubCategoryBloc, SubCategoryState>(
                        builder: (context, state) {
                          if (state is SubCategoryLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          else if (state is SubCategoryLoaded) {
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

                  Expanded(
                child: SubCategoryWidget(color: widget.color,categoryName: widget.categoryName,rootId: widget.rootId,level: 1,)

                  ),
              ],
            ),
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
                          title: widget.categoryName!),
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
            child:

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _flowSearchController,
                onChanged: (value) {
                  print("Text changed: $value");
                  bool isValid = _validateTags(value);
                  if (!isValid) {
                    // Show warning or handle invalid input
                    print("Please enter the tag");
                  } else {
                    context.read<CreateFlowBloc>().add(LoadAllFlowEvent(catID: widget.rootId!, keyword: value));
                  }
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search flow...',
                ),
              ),
            ),

            ),

            Expanded(
              child: FlowScreen(
                rootId: widget.rootId!,
                categoryname: widget.categoryName??"",
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



