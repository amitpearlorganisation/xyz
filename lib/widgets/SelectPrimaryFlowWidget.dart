import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../features/create_flow/flow_screen.dart';

class SelectPrimaryFlow extends StatefulWidget {
  String categoryId;
  String CategoryName;
   SelectPrimaryFlow({required this.categoryId, required this.CategoryName});

  @override
  State<SelectPrimaryFlow> createState() => _SelectPrimaryFlowState();
}

class _SelectPrimaryFlowState extends State<SelectPrimaryFlow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Primary flow"),
      ),
      body: FlowScreen(rootId: widget.categoryId!,categoryname: widget.CategoryName!,),
    );
  }
}
