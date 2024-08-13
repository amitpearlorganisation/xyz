import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:self_learning_app/features/add_Dailog/repo/create_dailog_repo.dart';

import '../../dailog_category/bloc/add_prompt_res_cubit.dart';
import '../model/addDailog_model.dart';

class CreateDailogFlow extends StatefulWidget {
  String dailogId;
  String dailog_flow_name;
  List<RespromptModel> respromptlist;
  List<AddPromptListModel> promptList;
   CreateDailogFlow({super.key, required this.dailog_flow_name,required this.respromptlist, required this.promptList,
   required this.dailogId
   });

  @override
  State<CreateDailogFlow> createState() => _CreateDailogFlowState();
}
List<ResPromptcheckModel> _list =[];
List<SelectResPromptModel> selectedResPrompt =[];
List<checkModelforDefPrompt>_defPromptList = [];
List<String> selectedResourceIds =[];
List<QuickPromptModel> quickPromptList = [];

class _CreateDailogFlowState extends State<CreateDailogFlow> {
  void updateSelectedPromptIds(String resourceId, bool isChecked) {
    if (isChecked) {
      if (!selectedResourceIds.contains(resourceId)) {
        setState(() {
          selectedResourceIds.add(resourceId);
        });
      }
    } else {
      setState(() {
        selectedResourceIds.remove(resourceId);
      });
    }
  }
  Color lightenRandomColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1.0);
    final int red = (color.red + (255 - color.red) * factor).round();
    final int green = (color.green + (255 - color.green) * factor).round();
    final int blue = (color.blue + (255 - color.blue) * factor).round();
    return Color.fromARGB(255, red, green, blue);
  }
  Color generateRandomColor() {
    final Random random = Random();
    final int red = random.nextInt(256); // 0-255 for the red channel
    final int green = random.nextInt(256); // 0-255 for the green channel
    final int blue = random.nextInt(256); // 0-255 for the blue channel
    final originalColor = Color.fromARGB(255, red, green, blue);
    final pastelColor = lightenRandomColor(originalColor, 0.8); // 30% lighter

    return pastelColor;
  }

  late List<bool> isExpandableList;
  bool isExpandedefprompt= false;
  double ?container_height;
  void ContainerHeight(){
    if(widget.promptList.length>3){
      container_height = 150;
    }
    else{
      container_height =200;
    }
  }
  List<PromptSelectedModel> promptSelect = [];
  List<String> promptIds = [];
  final AddPromptResCubit cubitAddPromptRes = AddPromptResCubit();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isExpandableList = List.generate(widget.respromptlist.length, (index) => false);
    ContainerHeight();

  }
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => cubitAddPromptRes..getResPrompt(dailogId: widget.dailogId),
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
          appBar: AppBar(title: Text("Create Dailog flow"),
    bottom: TabBar(
    tabs: [
    Tab(text: 'Choose prompt'),
    Tab(text: 'Choose resource prompt'),
    ],),
          actions: [
            Container(
              padding: EdgeInsets.symmetric( horizontal: 10),
              alignment: Alignment.center,

              child: GestureDetector(
                onTap: () async {
                  print("dailog hit ${promptIds}");
                  print("dailogId ${widget.dailogId}");
                  print("dailogflowtitle ${widget.dailog_flow_name}");

                 DailogRepo.saveDailog(dailogId: widget.dailogId, title: widget.dailog_flow_name, promptId: promptIds, context: context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(90),
                    color: promptIds.length==0?Colors.grey:Colors.white,

                  ),
                    child: Row(
                      children: [
                        Text("Save elected",style: TextStyle(color: Colors.black),),

                        Text("(${count.toString()})",style: TextStyle(color: Colors.black),),
                      ],
                    )),
              ),
            )
          ],
          ),
          body:
                   TabBarView(
                     children:[
                       BlocBuilder<AddPromptResCubit, AddPromptResState>(
                         builder: (context, state) {
                           if(state is AddPromptResLoading){
                             return Center(
                               child: CircularProgressIndicator(),
                             );
                           }
                           if(state is GetResourcePromptDailog){
                             return CustomScrollView(
                               slivers: <Widget>[
                                 SliverGrid(
                                   gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                     maxCrossAxisExtent: 500.0,
                                     mainAxisSpacing: 5.0,
                                     crossAxisSpacing: 10.0,
                                     childAspectRatio: 5.0,
                                   ),
                                   delegate: SliverChildBuilderDelegate(
                                         (BuildContext context, int index) {
                                       promptSelect.add(PromptSelectedModel(promptId: state.def_prompt_list[index].promptId, ischeck: false));
                                       return Card(
                                         color: Colors.teal[50],
                                         margin: EdgeInsets.only(left: 5,right: 5,top: 10),

                                         child: Container(
                                           alignment: Alignment.center,
                                           child: ListTile(
                                             title: Text(state.def_prompt_list[index].promptTitle),
                                             leading: Container(
                                               height: 40, width: 40,
                                               alignment: Alignment.center,
                                               decoration: BoxDecoration(
                                                 borderRadius: BorderRadius.circular(90),
                                                 color: Colors.pinkAccent,
                                                 border: Border.all(color: Colors.white, width: 2),
                                               ),
                                               child: Text(index.toString(),style: TextStyle(color: Colors.white),),
                                             ),
                                             trailing: promptSelect[index].ischeck?
                                             Container(
                                               padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                               decoration: BoxDecoration(
                                                 borderRadius: BorderRadius.circular(90),
                                                 color: Colors.white,
                                               ),
                                               child: Icon(Icons.check, color: Colors.lightGreen,),

                                             ):SizedBox(),
                                             onTap: (){
                                               if(promptSelect[index].ischeck==true){
                                                 promptSelect[index].ischeck=false;
                                                 promptIds.remove(state.def_prompt_list[index].promptId);
                                                 count = count-1;
                                                 print("promptIds remove $promptIds");
                                                 setState(() {

                                                 });
                                               }
                                               else if(promptSelect[index].ischeck==false){
                                                 promptSelect[index].ischeck=true;
                                                 count = count+1;
                                                 promptIds.add(state.def_prompt_list[index].promptId);
                                                 print("promptIds add $promptIds");

                                                 setState(() {

                                                 });
                                               }
                                               // promptSelect[index].ischeck=true;
                                               // setState(() {
                                               //
                                               // });
                                             },
                                           ),
                                         ),
                                       );
                                     },
                                     childCount: state.def_prompt_list.length,
                                   ),
                                 )
                               ],
                             );
                           }
                           return Text("Something wents wrong");
                         },
                       ),
                       widget.respromptlist.length==0?Container(
                         width: double.infinity,
                         height: MediaQuery.of(context).size.height*0.9,
                         child:Center(
                           child: Text("No resource is available"),
                         ),
                       ):CustomScrollView(
                         slivers: [
                           SliverList(
                             delegate: SliverChildBuilderDelegate(
                                   (BuildContext context, int index) {
                                 return
                                   Card(
                                     elevation: 4, // Customize the elevation
                                     margin: EdgeInsets.all(8),
                                     child: Theme(
                                       data:  Theme.of(context).copyWith(cardColor: generateRandomColor()),
                                       child:
                                       ExpansionPanelList(
                                         expandIconColor: Colors.blue,
                                         animationDuration: Duration(milliseconds:1000),
                                         dividerColor:Colors.red,
                                         elevation:1,
                                         children: [

                                           ExpansionPanel(

                                               body: Container(
                                                 padding: EdgeInsets.all(10),
                                                 child: Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment:CrossAxisAlignment.start,
                                                   children: <Widget>[

                                                     widget.respromptlist[index].promptList.length==0?Text("No prompt"):Container(
                                                       height: 300,
                                                       width: double.infinity,
                                                       child: ListView.builder(
                                                         itemCount: widget.respromptlist[index].promptList.length,
                                                         itemBuilder: (context, index) {



                                                           _list.add(ResPromptcheckModel(selectedResPrompt, false));

                                                           return
                                                             Container(
                                                                 margin: EdgeInsets.symmetric(vertical: 2),
                                                                 color: Colors.blue[50],
                                                                 child: CheckboxListTile(
                                                                   activeColor: Colors.red,
                                                                   checkColor: Colors.white,
                                                                   // value: _saved.contains(context), // changed
                                                                   value:_list[index].isCheck,
                                                                   onChanged: (val) {
                                                                     print("object  ${val}");
                                                                     setState(() {
                                                                       _list[index].isCheck = val!;
                                                                       if (val) {
                                                                         count=count+1;
                                                                         selectedResPrompt.add(SelectResPromptModel(resId: widget.respromptlist[index].resourceId, promptId: widget.respromptlist[index].promptList[index].promptId));
                                                                       } else {
                                                                         count=count-1;
                                                                         // If the checkbox is unchecked, remove the promptId from the list.
                                                                         selectedResPrompt.remove(SelectResPromptModel(resId: widget.respromptlist[index].resourceId, promptId: widget.respromptlist[index].promptList[index].promptId));
                                                                       }
                                                                     });
                                                                   },
                                                                   title: Text(widget.respromptlist[index].promptList![index].promptTitle.toString()),
                                                                 )
                                                             );
                                                         },
                                                       ),
                                                     ),




                                                   ],
                                                 ),
                                               ),
                                               headerBuilder: (BuildContext context, bool isExpanded) {
                                                 return Container(
                                                   padding: EdgeInsets.all(10),
                                                   child: Text(
                                                     "Select prompt from ${widget.respromptlist[index].resourceTitle}",
                                                     style: TextStyle(
                                                         color:Colors.black,
                                                         fontSize: 18,
                                                         fontWeight: FontWeight.w500
                                                     ),
                                                   ),
                                                 );
                                               },
                                               isExpanded: isExpandableList[index],
                                               canTapOnHeader: true
                                           ),

                                         ],
                                         expansionCallback: (int item, bool status) {
                                           setState(() {
                                             isExpandableList[index] = !isExpandableList[index];
                                           });
                                         },
                                       ),
                                     ),
                                   );

                               },
                               childCount: widget.respromptlist.length,
                             ),
                           ),
                         ],
                       )

                     ]
                   ),





          ),
        )
      );
  }
}
class ResPromptcheckModel{
  List<SelectResPromptModel> ids;
  bool isCheck;

  ResPromptcheckModel(this.ids, this.isCheck);

}
class SelectResPromptModel{
  String resId;
  String promptId;
  SelectResPromptModel({required this.resId, required this.promptId});

}
class checkModelforDefPrompt{
  String name;
  bool isCheck;

  checkModelforDefPrompt(this.name, this.isCheck);

}
class QuickPromptModel{
  String? PromptName;
  String? PromptId;

  QuickPromptModel({required this.PromptName, required this.PromptId});


}

class PromptSelectedModel{
  String promptId;
  bool ischeck;
  PromptSelectedModel({required this.promptId, required this.ischeck});
}