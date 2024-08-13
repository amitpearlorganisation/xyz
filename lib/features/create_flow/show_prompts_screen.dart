import 'dart:math';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:self_learning_app/features/create_flow/slide_show_screen.dart';
import 'package:self_learning_app/features/promt/data/model/promt_model.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

import '../add_Dailog/dailogPrompt/dailog_prompt.dart';
import '../flow_screen/start_flow_screen.dart';
import 'data/model/flow_model.dart';

class ShowPromtsScreen extends StatefulWidget {
  final List<FlowDataModel> flowList;
  final String flowName;
  const ShowPromtsScreen({Key? key, required this.flowList, required this.flowName}) : super(key: key);

  @override
  State<ShowPromtsScreen> createState() => _ShowPromtsScreenState();
}

class _ShowPromtsScreenState extends State<ShowPromtsScreen> {
  int _currentPage = 0;
  int _promtModelLength = 0;

  late final ColorScheme colorScheme;




  Widget buildSliderIndicator(int index) {
    return Container(
      width: 10,
      height: 10,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == _currentPage ? Colors.blue : Colors.grey,
      ),
    );
  }

  bool isLastPage() {
    return _currentPage == _promtModelLength - 1;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Prompts'),
        backgroundColor: Colors.blue,

      ),
      body: Scaffold(
        floatingActionButton: SizedBox(
          height: context.screenHeight * 0.1,
          child: FittedBox(
            child: ElevatedButton(

              onPressed: () {
                Navigator.push(context, MaterialPageRoute( builder: (context) {
                  return SlideShowScreen(
                  flowList: widget.flowList, flowName: widget.flowName,
                );},));
              },
              child: const Row(

                children: [
                  Text(
                    'Start Flow',
                    style: TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: ReorderableListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  children: <Widget>[
                    for (int index = 0;
                    index < widget.flowList.length;
                    index += 1)
                      ListTile(
                        leading: CircleAvatar(
                          maxRadius: 17, backgroundColor: generateRandomColor(),
                          foregroundColor: Colors.white,
                          child: Text(
                            extractFirstLetter(widget.flowList[index].promptName),
                            style: TextStyle(fontWeight: FontWeight.bold),)
                          ,),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            IconButton(onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>SlideShowScreen2(
                                flowName: widget.flowName,
                                side1type: widget.flowList[index].side1Type,
                                side2type: widget.flowList[index].side2Type,
                                side2contentTitle: widget.flowList[index].side1Content,
                                side1contentTitle: widget.flowList[index].side2Content,
                                promptTitle: widget.flowList[index].promptName,
                              )));
                            }, icon: Icon(Icons.play_arrow, color: Colors.green,)),
                          ],
                        ),
                        key: Key('$index'),
                        tileColor: index.isOdd ? oddItemColor : evenItemColor,
                        title: Row(
                          children: [
                            Text('${widget.flowList[index].promptName}')
                          ],
                        ),
                      ),
                  ],
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      //print(state.addFlowModel)
                      FlowDataModel item = widget.flowList.removeAt(oldIndex);
                      widget.flowList.insert(newIndex, item);
/*
                      PromtModel model = state.promtModel!.removeAt(oldIndex);
                      state.promtModel!.insert(newIndex, model);*/
                    });
                  },
                )),
          ],
        ),
      ),
    );
  }

//   ChewieController _createChewieController(String videoUrl) {
//     final videoPlayerController = VideoPlayerController.network(videoUrl);
//     _chewieController = ChewieController(
//       videoPlayerController: videoPlayerController,
//       autoInitialize: true,
//       autoPlay: true,
//       looping: false,
//       errorBuilder: (context, errorMessage) {
//         return Center(
//           child: Text(
//             errorMessage,
//             style: const TextStyle(color: Colors.white),
//           ),
//         );
//       },
//     );
//     return _chewieController!;
//   }
// }
//
// class PromtMediaPlayScreen extends StatefulWidget {
//   const PromtMediaPlayScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PromtMediaPlayScreen> createState() => _PromtMediaPlayScreenState();
// }
//
// class _PromtMediaPlayScreenState extends State<PromtMediaPlayScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }



  Color generateRandomColor() {
    final Random random = Random();
    Color color;

    do {
      color = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    } while (_isBright(color) || color == Colors.white);

    return color;
  }

  bool _isBright(Color color) {
    // Calculate the luminance of the color using the formula
    // Luminance = 0.299 * Red + 0.587 * Green + 0.114 * Blue
    double luminance = 0.299 * color.red + 0.587 * color.green + 0.114 * color.blue;

    // Return true if the luminance is greater than a threshold (adjust as needed)
    return luminance > 180;
  }

  String extractFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text.substring(0,1).toUpperCase();
  }

}
