import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:self_learning_app/features/add_media/bloc/add_media_bloc.dart';
import 'package:self_learning_app/features/add_promts/add_promts_screen.dart';
import 'package:self_learning_app/features/dashboard/dashboard_screen.dart';
import 'package:self_learning_app/features/flow_screen/start_flow_screen.dart';
import 'package:self_learning_app/features/resources/bloc/resources_bloc.dart';
import 'package:self_learning_app/features/resources/subcategory2_resources_screen.dart';
import 'package:self_learning_app/features/subcategory/model/resources_model.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:mime/mime.dart';
import '../../utilities/colors.dart';
import '../../utilities/shared_pref.dart';
import '../../widgets/add_resources_screen.dart';
import '../../widgets/play_music.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../../widgets/view_resource.dart';
import '../promt/promts_screen.dart';
import '../quick_import/repo/quick_add_repo.dart';
import '../subcate1.1/bloc/sub_cate1_bloc.dart';
import '../subcate1.1/bloc/sub_cate1_state.dart';
import 'maincategory_resources_screen.dart';

class SubcategoryResourcesList extends StatefulWidget {
  final String rootId;
  final String mediaType;
  final String title;

  const SubcategoryResourcesList(
      {Key? key, required this.rootId, required this.mediaType, required this.title})
      : super(key: key);

  @override
  State<SubcategoryResourcesList> createState() => _SubcategoryResourcesListState();
}

class _SubcategoryResourcesListState extends State<SubcategoryResourcesList> {
  final ResourcesBloc resourcesBloc = ResourcesBloc();
  TextEditingController textEditingController = TextEditingController();
  bool _resourcesVisible = true;
  final TextEditingController _resourceSearchController = TextEditingController();

  @override
  void initState() {
    resourcesBloc.add(LoadResourcesEvent(rootId: widget.rootId, mediaType: widget.mediaType));
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => resourcesBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        appBar: AppBar(
          title: Text('${widget.title} Resources'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: _resourceSearchController,
                  onChanged: (value) {
                    print("Text changed: $value");
                    resourcesBloc.add(LoadResourcesEvent(rootId: widget.rootId.toString(), mediaType: "", resourcQueary: value));
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search resource...',
                  ),
                ),
              ),
            ),
            Expanded(
              child: MaincategoryResourcesList(
                  rootId: widget.rootId!,
                  level: "Level 4",
                  mediaType: '',
                  title: widget.title!
            ),
            )
          ],
        ),
      ),
    );
  }
}

String getMediaType(String filePath) {
  final mimeType = lookupMimeType(filePath);

  if (mimeType != null) {
    if (mimeType.startsWith('image/')) {
      return 'image';
    } else if (mimeType.startsWith('audio/')) {
      return 'audio';
    } else if (mimeType.startsWith('video/')) {
      return 'video';
    }
  }

  return 'unknown';
}
