

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:self_learning_app/features/subcate1.2/update_subcate1.2.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

import '../../utilities/colors.dart';
import '../../widgets/add_resources_screen.dart';
import '../create_flow/bloc/create_flow_screen_bloc.dart';
import '../create_flow/create_flow_screen.dart';
import '../create_flow/flow_screen.dart';
import '../resources/bloc/resources_bloc.dart';
import '../resources/subcategory2_resources_screen.dart';
import '../resources/subcategory_resources_screen.dart';
import '../subcategory/primaryflow/primaryflow.dart';
import 'CreateFlowWidget.dart';

class FinalResourceScreen extends StatefulWidget {
  final String categoryName;
  final List<String> keyWords;
  final String rootId;
  final Color? color;
  const FinalResourceScreen({super.key, required this.categoryName,
  required this.rootId,
  this.color, required this.keyWords,});

  @override
  State<FinalResourceScreen> createState() => _FinalResourceScreenState();
}

class _FinalResourceScreenState extends State<FinalResourceScreen> {

  CreateFlowBloc _flowBloc = CreateFlowBloc();
  String ?title;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _flowBloc.add(LoadAllFlowEvent(catID: widget.rootId));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: SizedBox(height: context.screenHeight*0.1,
        child: FittedBox(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) =>
                    SubcategoryResourcesList(rootId: widget.rootId,
                        mediaType: '',
                        title: widget.categoryName),)).then((value) {
                context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: '')

                );


              });

            },
            child: Row(
              children: [
                Text(
                  'View All',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9),),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
          leading: IconButton(onPressed: (){
            Navigator.pop(context, true);
          }, icon: Icon(Icons.arrow_back)),
          title: Text(title?.isEmpty ?? true ? widget.categoryName : title!),

          elevation: 0,
          automaticallyImplyLeading: true,
          actions: [
/*
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider<CreateFlowBloc>.value(value: _flowBloc, child: CreateFlowScreen(rootId: widget.rootId!)),));
              },),
*/
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PrimaryFlow(CatId: widget.rootId.toString(),flowId: "0",categoryName: widget.categoryName,)));
                },
                icon: Icon(Icons.play_circle)
            ),

            PopupMenuButton(
              icon: Icon(Icons.more_vert,color: Colors.white,),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                      value: 'viewResources',
                      child: InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.add_circle_rounded, color: primaryColor,),
                              SizedBox(width: 8.0,),
                              Text("View Resources"),
                            ],
                          ))
                  ),
                  const PopupMenuItem(
                      value: 'createFlow',
                      child: InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.add_circle_rounded, color: primaryColor,),
                              SizedBox(width: 8.0,),
                              Text("Create New Flow"),
                            ],
                          ))
                  ),

                  const PopupMenuItem(
                      value: 'edit',
                      child: InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.edit, color: primaryColor,),
                              SizedBox(width: 8.0,),
                              Text("Edit Category"),
                            ],
                          ))
                  )
                ];
              },
              onSelected: (String value) {
                switch(value){
                  case 'viewResources':
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>
                          SubcategoryResourcesList(rootId: widget.rootId,
                              mediaType: '',
                              title: widget.categoryName),)).then((value) {
                      context.read<ResourcesBloc>().add(LoadResourcesEvent(rootId: widget.rootId, mediaType: '')

                      );


                    });
                    break;
                  case 'edit':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return UpdateSubCate2Screen(
                              rootId: widget.rootId,
                              selectedColor: widget.color!,
                              categoryTitle: title?.isEmpty ?? true ? widget.categoryName : title!,
                              keyWords: widget.keyWords,);
                          },)).then((value) {

                      if (value != null && value is Map && value.containsKey('categoryName')) {
                        setState(() {
                          title = value['categoryName'];
                        });
                      }
                    });
                    break;
                  case 'schedule':

                    break;
                  case 'createFlow':
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return CreateFlowScreen(
                              rootId: widget.rootId!,
                            categoryName: widget.categoryName,
                          );
                        }));
                    break;
                }
              },
            ),
          ]

      ),
      body: AddResourceScreen(rootId: widget.rootId??'',whichResources: 1, categoryName: widget.categoryName??"Subcategory"),
    );
  }
}
