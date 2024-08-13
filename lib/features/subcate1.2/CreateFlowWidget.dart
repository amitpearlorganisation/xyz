import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../create_flow/flow_screen.dart';

class CreateStartFlow extends StatefulWidget {
  String CatId;
  String CatName;
   CreateStartFlow({required this.CatName, required this.CatId});

  @override
  State<CreateStartFlow> createState() => _CreateStartFlowState();
}

class _CreateStartFlowState extends State<CreateStartFlow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: FlowScreen(
        rootId: widget.CatId!,
        categoryname: widget.CatName,
      ),
    );
  }
}
