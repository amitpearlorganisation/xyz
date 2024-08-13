import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../features/create_flow/flow_screen.dart';

class ViewFlow extends StatelessWidget {
  final String rootId;
  final String categoryname;
  const ViewFlow({required this.rootId, required this.categoryname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View flow"),),
      body: FlowScreen(
        rootId: rootId,
        categoryname: categoryname,
      )
    );
  }
}
