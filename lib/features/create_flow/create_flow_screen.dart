

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:self_learning_app/features/create_flow/bloc/create_flow_screen_bloc.dart';
import 'package:self_learning_app/utilities/colors.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../add_promts/add_promts_screen.dart';
import '../add_promts_to_flow/add_promts_to_flow_screen.dart';
import '../promt/promts_screen.dart';
import '../resources/bloc/resources_bloc.dart';
import '../resources/maincategory_resources_screen.dart';
import 'flow_screen.dart';

class CreateFlowScreen extends StatefulWidget {
  final String rootId;
  final String categoryName;
  const CreateFlowScreen({super.key, required this.rootId, required this.categoryName});

  @override
  State<CreateFlowScreen> createState() => _CreateFlowScreenState();
}

class _CreateFlowScreenState extends State<CreateFlowScreen> {
  final TextEditingController _flowSearchController = TextEditingController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final createflowbloc = BlocProvider.of<CreateFlowBloc>(context);
    createflowbloc.add(LoadAllFlowEvent(catID: widget.rootId));
  }

  @override
  Widget build(BuildContext context) {
    print("create flow root id ---${widget.rootId}");
    return Scaffold(
      appBar: AppBar(
        title: Text('Create flow for ${widget.categoryName}'),
      ),
      body:   Column(
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
              categoryname: widget.categoryName??"",
            ),
          ),
        ],
      )

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
