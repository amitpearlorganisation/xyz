import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:self_learning_app/features/add_media/bloc/add_media_bloc.dart';
import 'package:self_learning_app/features/add_promts/bloc/add_prompts_bloc.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/utilities/image_picker_helper.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../utilities/colors.dart';

class AddPromptsScreen extends StatefulWidget {
  final String resourceId;
  final String categoryId;
  const AddPromptsScreen({required this.resourceId, required this.categoryId, Key? key})
      : super(key: key);

  @override
  State<AddPromptsScreen> createState() => _AddPromptsScreenState();
}

List<String> mediaType = ['Audio', 'Text', 'Video', 'Image'];

class _AddPromptsScreenState extends State<AddPromptsScreen> {
  final AddPromptsBloc addPromptsBloc = AddPromptsBloc();

  TextEditingController title_Controller = TextEditingController();
  TextEditingController side1_Controller = TextEditingController();
  TextEditingController side2_Controller = TextEditingController();
  GlobalKey<FormState> _titleformKey = GlobalKey<FormState>();
  GlobalKey<FormState> _side1TextformKey = GlobalKey<FormState>();
  GlobalKey<FormState> _side2TextformKey = GlobalKey<FormState>();
  FocusNode _questionFocusNode = FocusNode();
  FocusNode _answerFocusNode = FocusNode();

  bool _isRecording1 = false;
  final recorder1 = Record();
  bool _isRecording2 = false;
  final recorder2 = Record();
  bool titleIsEmty = false;



  Future initRecorder() async {
    final status = await Permission. microphone. request ();
    if (status != PermissionStatus. granted) {
      throw 'Microphone permission not granted';
    }

  }
  @override
  void initState() {
    // side2_Controller.text='';
    // side1_Controller.text='';
    // addPromptsBloc.add(LoadPrompts());

    print('Res: ${widget.resourceId} Cat: ${widget.categoryId}');
    initRecorder();
    super.initState();
  }

  @override
  void dispose() {
    side2_Controller.dispose();
    side1_Controller.dispose();
    addPromptsBloc.close();
    if(EasyLoading.isShow){
      EasyLoading.dismiss();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => addPromptsBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Prompt', style: TextStyle(fontSize: 17)),
          // backgroundColor: Colors.yellow,
        ),
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: SingleChildScrollView(
              child: Container(
                  width: context.screenWidth,
                  //color: Colors.white,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: BlocConsumer<AddPromptsBloc, AddPromptsInitial>(
                    buildWhen: (previous, current) => current != previous,
                    listener: (BuildContext context, Object? state) {
                      if (state is AddPromptsInitial) {
                        if (state.uploadStatus == UploadStatus.uploaded) {
                          addPromptsBloc.add(ResetFileUploadStatus());

                          context.showSnackBar(SnackBar(content: Text("Resource uploaded..")));
                          Future.delayed(Duration(seconds: 2), () {
                            EasyLoading.dismiss();
                            context.pop();
                          },);
                        }
                        if (state.uploadStatus == UploadStatus.resourceAdded) {
                          EasyLoading.dismiss();

                          addPromptsBloc.add(ResetFileUploadStatus());
                          context.showSnackBar(SnackBar(content: Text("Resource added..")));
                        }

                        if(state.resource1status == Resource1Status.selected){

                          saveResource1(state);
                        }

                        if(state.resource2status == Resource2Status.selected){
                          saveResource2(state);
                        }

                      }

                    },
                    builder: (context, state) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Form(
                              key: _titleformKey,
                              child: TextFormField(
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty || value == '') {
                                    return "Field required";
                                  }
                                  return null;
                                },
                                controller: title_Controller,
                                onChanged: (value) {
                                  setState(() {
                                    // Check if the title is not empty to show the card
                                    titleIsEmty = value.isNotEmpty;
                                    titleIsEmty =false;
                                  });
                                },
                                onTap: () {
                                  ////// .........................................>---->
                                  if(side1_Controller.text.isNotEmpty ){
                                    print("Condition first is run");
                                    saveResource1(state);
                                  }
                                  if(side2_Controller.text.isNotEmpty){
                                    print("condition 2 is run");
                                    saveResource2(state);
                                  }
                                  if( side1_Controller.text.isNotEmpty || side1_Controller.text.isNotEmpty){
                                    print("------->---< or condition3");
                                    saveResource1(state);
                                    saveResource2(state);
                                  }

                                },
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0, letterSpacing: 1),
                                decoration: InputDecoration(
                                    hintText: 'Add Title',
                                  hintStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0, letterSpacing: 1),
                                ),
                              ),
                            ),
                          ),

                          Visibility(
                              visible: titleIsEmty,
                              child: Text("Please Enter the title first", style: TextStyle(color: Colors.red, fontSize: 10),)),
                          SizedBox(height: 12.0,),
                          Stack(
                            children: [
                              Column(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    //color: Colors.blue,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 10, left: 10, right: 10, top: 10),
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text.rich(
                                                TextSpan(
                                                    children: [
                                                      TextSpan(text: 'Side 1/ '),
                                                      TextSpan(text: 'Question', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    ]
                                                )
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Resources Type'),
                                                Container(
                                                  padding: EdgeInsets.only(left: 10),
                                                  decoration: BoxDecoration(
                                                      color: primaryColor,
                                                      borderRadius:
                                                      BorderRadius.circular(10)),
                                                  margin: EdgeInsets.only(top: 10),
                                                  height: 40,
                                                  //width: context.screenWidth / 2,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                          state.side1selectedMediaType == 'Video'
                                                              ? Icons.videocam_outlined
                                                              : state.side1selectedMediaType == 'Image'
                                                              ? Icons.image
                                                              : state.side1selectedMediaType == 'Audio'
                                                              ? Icons.music_note
                                                              : Icons.text_format,
                                                          color: Colors.white),
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                      DropdownButton(
                                                        dropdownColor: Colors.redAccent,
                                                        iconEnabledColor: Colors.white,

                                                        style: TextStyle(
                                                            color: Colors.white),

                                                        // Initial Value
                                                        value: state.side1selectedMediaType ?? mediaType.first,

                                                        // Down Arrow Icon
                                                        icon: const Icon(
                                                            Icons.keyboard_arrow_down),

                                                        // Array list of items
                                                        items: mediaType
                                                            .map((String items) {
                                                          return DropdownMenuItem(
                                                            value: items,
                                                            child: Text(items,
                                                                style: TextStyle(
                                                                    color:
                                                                    Colors.white)),
                                                          );
                                                        }).toList(),
                                                        onChanged: (Object? value) {
                                                          print(value);
                                                          addPromptsBloc.add(
                                                              ChangeMediaType(
                                                                  whichSide: 0,
                                                                  MediaType: value
                                                                      .toString()));
                                                        },
                                                        // After selecting the desired option,it will
                                                        // change button value to selected value
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            state.side1selectedMediaType == 'Text'
                                                ? Container(
                                              margin: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black.withOpacity(
                                                      0.5), // Set border color to red
                                                  width: 2, // Set border width
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(10),
                                                color: Colors.grey.shade200,
                                              ),
                                              padding: EdgeInsets.all(10),
                                              child: Form(
                                                key: _side1TextformKey,
                                                child: TextFormField(
                                                  focusNode: _questionFocusNode,
                                                  controller: side1_Controller,
                                                  onTap: () {

                                                  },
                                                  onTapOutside: (event) {
                                                    if(_questionFocusNode.hasFocus){
                                                      _questionFocusNode.unfocus();
                                                      if(side1_Controller.text != ''){

                                                        saveResource1(state);
                                                      }
                                                    }
                                                  },
                                                  onFieldSubmitted: (value) {
                                                    if(value != ''){
                                                      saveResource1(state);
                                                    }
                                                  },
                                                  validator: (value) => value == null || value.isEmpty
                                                      ? 'Field required!'
                                                      : null,
                                                  decoration: InputDecoration.collapsed(
                                                      hintText: 'Add Questions',
                                                      hintStyle: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                              ),
                                            )
                                                : state.side1selectedMediaType == 'Video'
                                                ? Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                (state.side1ResourceUrl == '')
                                                    ? Container(
                                                    alignment: Alignment.center,
                                                    height: MediaQuery.of(context).size.height * 0.2,
                                                    width: MediaQuery.of(context).size.height * 0.2,
                                                    child: Icon(Icons.videocam_outlined))
                                                    : FutureBuilder<Uint8List?>(
                                                  future: loadVideoThumbnail(File(state.side1ResourceUrl!).path),
                                                  builder: (context, snapshot) {
                                                    if(snapshot.hasData){
                                                      if(snapshot.data != null){
                                                        return Container(
                                                            alignment: Alignment.center,
                                                            color: Colors.black,
                                                            height: MediaQuery.of(context).size.height * 0.2,
                                                            width: MediaQuery.of(context).size.height * 0.2,
                                                            child: Image.memory(snapshot.data!, fit: BoxFit.fitHeight,));
                                                      }
                                                    }else if(snapshot.hasError){
                                                      return Flexible(child: Text('Please choose file again!', style: TextStyle(color: Colors.red),),);
                                                    }
                                                    return Center(child: CircularProgressIndicator(),);
                                                  },
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return SafeArea(
                                                            child: Container(
                                                              child: Wrap(
                                                                children: <Widget>[
                                                                  ListTile(
                                                                    leading: Icon(Icons.photo_library),
                                                                    title: Text('Photo Library'),
                                                                    onTap: () {
                                                                      ImagePickerHelper.pickVideo(imageSource: ImageSource.gallery).then((value) async {
                                                                        if(value != null) {
                                                                          final file = File(value.path);
                                                                          final fileSize = await file.length();
                                                                          if (fileSize > 50 * 1024 * 1024 ) { // 5 MB in bytes
                                                                            EasyLoading.dismiss();
                                                                            EasyLoading.showInfo('Upload Video should be less than 50 MB');
                                                                          }
                                                                          else{

                                                                            addPromptsBloc.add(
                                                                                PickResource(
                                                                                    mediaUrl: value!.path,
                                                                                    whichSide: 0));
                                                                          }

                                                                        }
                                                                      });
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                  ListTile(
                                                                    leading: Icon(Icons.camera_alt),
                                                                    title: Text('Camera'),
                                                                    onTap: () {
                                                                      ImagePickerHelper.pickVideo(imageSource: ImageSource.camera).then((value) async {
                                                                        if(value != null) {
                                                                          final file = File(value.path);
                                                                          final fileSize = await file.length();
                                                                          if (fileSize > 50 * 1024 * 1024 ) { // 5 MB in bytes
                                                                            EasyLoading.dismiss();
                                                                            EasyLoading.showInfo('Upload Video should be less than 50 MB');
                                                                          }
                                                                          else{

                                                                            addPromptsBloc.add(
                                                                                PickResource(
                                                                                    mediaUrl: value!.path,
                                                                                    whichSide: 0));
                                                                          }

                                                                        }
                                                                      });
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text('Choose File')
                                                ),
                                              ],
                                            )
                                                : state.side1selectedMediaType == 'Image'
                                                ? Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                (state.side1ResourceUrl == '')
                                                    ? Container(
                                                    alignment: Alignment.center,
                                                    height: MediaQuery.of(context).size.height * 0.2,
                                                    width: MediaQuery.of(context).size.height * 0.2,
                                                    child: Icon(Icons.image))
                                                    : SizedBox(
                                                    height: MediaQuery.of(context).size.height * 0.2,
                                                    child: Image.file(
                                                      File(state.side1ResourceUrl!),
                                                      errorBuilder: (context, error, stackTrace) => Flexible(child: Text('Please choose file again!', style: TextStyle(color: Colors.red),),),
                                                      fit: BoxFit.fitHeight,)),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return SafeArea(
                                                            child: Container(
                                                              child: Wrap(
                                                                children: <Widget>[
                                                                  ListTile(
                                                                    leading: Icon(Icons.photo_library),
                                                                    title: Text('Photo Library'),
                                                                    onTap: () {
                                                                      ImagePickerHelper.pickImage(
                                                                          imageSource: ImageSource.gallery)
                                                                          .then((value) {
                                                                        if(value != null) {
                                                                          addPromptsBloc.add(
                                                                              PickResource(
                                                                                  mediaUrl: value!
                                                                                      .path,
                                                                                  whichSide: 0));
                                                                        }
                                                                      });
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                  ListTile(
                                                                    leading: Icon(Icons.camera_alt),
                                                                    title: Text('Camera'),
                                                                    onTap: () {
                                                                      ImagePickerHelper.pickImage(
                                                                          imageSource: ImageSource.camera)
                                                                          .then((value) {
                                                                        if(value != null) {
                                                                          addPromptsBloc.add(
                                                                              PickResource(
                                                                                  mediaUrl: value!
                                                                                      .path,
                                                                                  whichSide: 0));
                                                                        }
                                                                      });
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text('Choose File')
                                                ),
                                              ],
                                            )
                                                : Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                    alignment: Alignment.center,
                                                    height: MediaQuery.of(context).size.height * 0.2,
                                                    width: MediaQuery.of(context).size.height * 0.2,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        _isRecording1==true
                                                            ?FloatingActionButton(onPressed: () {stopRecording(1);},child: Icon(Icons.stop))
                                                            :FloatingActionButton(onPressed: () {startRecording(1);},child: Icon(Icons.mic)),
                                                        SizedBox(height: 8.0,),
                                                        Text(_isRecording1?'Stop Recording':'Start Recording'),
                                                      ],
                                                    )
                                                ),
                                                Text('OR'),

                                                ElevatedButton(
                                                    onPressed: () {
                                                      ImagePickerHelper.pickFile()
                                                          .then((value) {
                                                        if(value != null) {
                                                          addPromptsBloc.add(
                                                              PickResource(
                                                                  mediaUrl: value,
                                                                  whichSide: 0));
                                                        }
                                                      });
                                                    },
                                                    child: Text('Choose File')
                                                ),
                                              ],
                                            ),


                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    //color: Colors.green,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 10, left: 10, right: 10, top: 10),
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text.rich(
                                                TextSpan(
                                                    children: [
                                                      TextSpan(text: 'Side 2/ '),
                                                      TextSpan(text: 'Answer', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    ]
                                                )
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Resources Type'),
                                                Container(
                                                  padding: EdgeInsets.only(left: 10),
                                                  decoration: BoxDecoration(
                                                      color: primaryColor,
                                                      borderRadius: BorderRadius.circular(10)),
                                                  margin: EdgeInsets.only(top: 10),
                                                  height: 40,
                                                  //width: context.screenWidth / 2,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                          state.side2selectedMediaType == 'Video'
                                                              ? Icons.videocam_outlined
                                                              : state.side2selectedMediaType == 'Image'
                                                              ? Icons.image
                                                              : state.side2selectedMediaType == 'Audio'
                                                              ? Icons.music_note
                                                              : Icons.text_format,
                                                          color: Colors.white),
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      DropdownButton(
                                                        dropdownColor: Colors.redAccent,
                                                        iconEnabledColor: Colors.white,

                                                        style: const TextStyle(color: Colors.white),

                                                        // Initial Value
                                                        value: state.side2selectedMediaType ?? mediaType.first,

                                                        // Down Arrow Icon
                                                        icon: const Icon(
                                                            Icons.keyboard_arrow_down),

                                                        // Array list of items
                                                        items: mediaType
                                                            .map((String items) {
                                                          return DropdownMenuItem(
                                                            value: items,
                                                            child: Text(items,
                                                                style: TextStyle(
                                                                    color:
                                                                    Colors.white)),
                                                          );
                                                        }).toList(),
                                                        onChanged: (Object? value) {
                                                          print(value);
                                                          addPromptsBloc.add(
                                                              ChangeMediaType(
                                                                  whichSide: 1,
                                                                  MediaType: value
                                                                      .toString()));
                                                        },
                                                        // After selecting the desired option,it will
                                                        // change button value to selected value
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            state.side2selectedMediaType == 'Text'
                                                ? Container(
                                              margin: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black.withOpacity(
                                                      0.5), // Set border color to red
                                                  width: 2, // Set border width
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(10),
                                                color: Colors.grey.shade200,
                                              ),
                                              padding: EdgeInsets.all(10),
                                              child: Form(
                                                key: _side2TextformKey,
                                                child: TextFormField(
                                                  controller: side2_Controller,
                                                  focusNode: _answerFocusNode,
                                                  onTap: () {
                                                    if(state.resource1status == Resource1Status.selected && side1_Controller.text!=""){
                                                saveResource1(state);
                                              }else if(side1_Controller.text != '' && state.side1Id == ''){
                                                saveResource1(state);
                                              }else{
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Resource 1 is not saved!')));
                                              }


                                                  },
                                                  onTapOutside: (event) {
                                                    if(_answerFocusNode.hasFocus){
                                                      _answerFocusNode.unfocus();
                                                      if(side2_Controller.text != ''){
                                                        saveResource2(state);
                                                      }
                                                    }
                                                  },
                                                  onFieldSubmitted: (value) {
                                                    if(value != ''){
                                                      saveResource2(state);
                                                    }
                                                  },
                                                  decoration:
                                                  InputDecoration.collapsed(
                                                      hintText: 'Add Answer',
                                                      hintStyle: TextStyle(
                                                          fontSize: 12)),
                                                ),
                                              ),
                                            )
                                                : state.side2selectedMediaType == 'Video'
                                                ? Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                (state.side2ResourceUrl == '')
                                                    ? Container(
                                                    alignment: Alignment.center,
                                                    height: MediaQuery.of(context).size.height * 0.2,
                                                    width: MediaQuery.of(context).size.height * 0.2,
                                                    child: Icon(Icons.videocam_outlined))
                                                    : FutureBuilder<Uint8List?>(
                                                  future: loadVideoThumbnail(File(state.side2ResourceUrl!).path),
                                                  builder: (context, snapshot) {
                                                    if(snapshot.hasData){
                                                      if(snapshot.data != null){
                                                        return Container(
                                                            alignment: Alignment.center,
                                                            color: Colors.black,
                                                            height: MediaQuery.of(context).size.height * 0.2,
                                                            width: MediaQuery.of(context).size.height * 0.2,
                                                            child: Image.memory(snapshot.data!, fit: BoxFit.fitHeight,));
                                                      }
                                                    }else if(snapshot.hasError){
                                                      return Flexible(child: Text('Please choose file again!', style: TextStyle(color: Colors.red),),);
                                                    }
                                                    return Center(child: CircularProgressIndicator(),);
                                                  },
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return SafeArea(
                                                            child: Container(
                                                              child: Wrap(
                                                                children: <Widget>[
                                                                  ListTile(
                                                                    leading: Icon(Icons.photo_library),
                                                                    title: Text('Photo Library'),
                                                                    onTap: () {
                                                                      ImagePickerHelper.pickVideo(imageSource: ImageSource.gallery).then((value) async {
                                                                        if(value != null) {
                                                                          final file = File(value.path);
                                                                          final fileSize = await file.length();
                                                                          print("file size = ${fileSize}");
                                                                          if (fileSize > 50 * 1024 * 1024) { // 5 MB in bytes
                                                                            EasyLoading.dismiss();
                                                                            print("video is support");
                                                                            EasyLoading.showInfo('Upload Video should be less than 50 MB');
                                                                          }
                                                                          else{

                                                                            addPromptsBloc.add(
                                                                                PickResource(
                                                                                    mediaUrl: value!.path,
                                                                                    whichSide: 1));

                                                                          }

                                                                        }                                                                      });
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                  ListTile(
                                                                    leading: Icon(Icons.camera_alt),
                                                                    title: Text('Camera'),
                                                                    onTap: () {
                                                                      ImagePickerHelper.pickVideo(imageSource: ImageSource.camera).then((value) async {
                                                                        if(value != null) {
                                                                          final file = File(value.path);
                                                                          final fileSize = await file.length();
                                                                          print("file size = ${fileSize}");
                                                                          if (fileSize > 50 * 1024 * 1024) { // 5 MB in bytes
                                                                            EasyLoading.dismiss();
                                                                            EasyLoading.showInfo('Upload Video should be less than 50 MB');
                                                                          }
                                                                          else{
                                                                            addPromptsBloc.add(
                                                                                PickResource(
                                                                                    mediaUrl: value!.path,
                                                                                    whichSide: 1));
                                                                          }

                                                                        }
                                                                      });
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text('Choose File')
                                                ),
                                              ],
                                            )
                                                : state.side2selectedMediaType == 'Image'
                                                ? Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                (state.side2ResourceUrl == '')
                                                    ? Container(
                                                    alignment: Alignment.center,
                                                    height: MediaQuery.of(context).size.height * 0.2,
                                                    width: MediaQuery.of(context).size.height * 0.2,
                                                    child: Icon(Icons.image))
                                                    : SizedBox(height: MediaQuery.of(context).size.height * 0.2,
                                                    child: Image.file(
                                                      File(state.side2ResourceUrl!),
                                                      errorBuilder: (context, error, stackTrace) => Flexible(child: Text('Please choose file again!', style: TextStyle(color: Colors.red),),),
                                                      fit: BoxFit.fitHeight,)),
                                                ElevatedButton(
                                                    onPressed: () {


                                                      showModalBottomSheet(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return SafeArea(
                                                            child: Container(
                                                              child: Wrap(
                                                                children: <Widget>[
                                                                  ListTile(
                                                                    leading: Icon(Icons.photo_library),
                                                                    title: Text('Photo Library'),
                                                                    onTap: () {
                                                                      ImagePickerHelper.pickImage(
                                                                          imageSource: ImageSource.gallery)
                                                                          .then((value) {
                                                                        if(value != null) {
                                                                          addPromptsBloc.add(
                                                                              PickResource(
                                                                                  mediaUrl: value
                                                                                      .path,
                                                                                  whichSide: 1));
                                                                        }
                                                                      });
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                  ListTile(
                                                                    leading: Icon(Icons.camera_alt),
                                                                    title: Text('Camera'),
                                                                    onTap: () {
                                                                      ImagePickerHelper.pickImage(
                                                                          imageSource: ImageSource.camera)
                                                                          .then((value) {
                                                                        if(value != null) {
                                                                          addPromptsBloc.add(
                                                                              PickResource(
                                                                                  mediaUrl: value
                                                                                      .path,
                                                                                  whichSide: 1));
                                                                        }
                                                                      });
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },);
                                                    },
                                                    child: Text('Choose File')
                                                ),
                                              ],
                                            )
                                                : Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                    alignment: Alignment.center,
                                                    height: MediaQuery.of(context).size.height * 0.2,
                                                    width: MediaQuery.of(context).size.height * 0.2,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        _isRecording2==true
                                                            ?FloatingActionButton(onPressed: () {stopRecording(2);},child: Icon(Icons.stop))
                                                            :FloatingActionButton(onPressed: () {startRecording(2);},child: Icon(Icons.mic)),
                                                        SizedBox(height: 8.0,),
                                                        Text(_isRecording2?'Stop Recording':'Start Recording'),
                                                      ],
                                                    )
                                                ),
                                                Text('OR'),

                                                ElevatedButton(
                                                    onPressed: () {
                                                      ImagePickerHelper.pickFile()
                                                          .then((value) {
                                                        if(value != null) {
                                                          addPromptsBloc.add(
                                                              PickResource(
                                                                  mediaUrl: value,
                                                                  whichSide: 1));
                                                        }
                                                      });
                                                    },
                                                    child: Text('Choose File')
                                                ),
                                              ],
                                            ),
                                            /*Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Colors.red)),
                                        onPressed: () {
                                          // print(state.side2ResourceUrl);


                                        },
                                        child: Text('     Save    '))
                                  ],
                                )*/
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if(title_Controller.text.isEmpty)GestureDetector(
                                onTap: (){
                                  if(_titleformKey.currentState!.validate()){
                                    print("chekValidation");
                                  }
                                },
                                child: Container(
                                  height: 500,
                                  width: double.infinity,
                                  color: Colors.transparent,

                                ),
                              )
                            ],
                          ),





                          GestureDetector(

                            onTap: () async {
                              print(state.side2Id!);
                              onAddPromptPressed(state, context);

                              // if(state.side1Id!.isEmpty && state.side2Id!.isEmpty){
                              //  print("field is empty");
                              // }
                              // else if(side2_Controller.text.isNotEmpty) {
                              //   saveResource2(state);
                              //   if(state.side2Id!.isNotEmpty || state.side2Id != ""){
                              //   onAddPromptPressed(state, context);
                              //   }
                              // }

                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 20),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: state.side1Id!.isEmpty || state.side2Id!.isEmpty?Colors.grey:primaryColor,
                                  borderRadius: BorderRadius.circular(10)),
                              width: 100,
                              height: 40,
                              child: const Center(
                                child: Text(
                                  'Add Prompt',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ))),
        ),
      ),
    );
  }

  Future<void> onAddPromptPressed(AddPromptsInitial state, BuildContext context) async{
    if (!_titleformKey.currentState!.validate()) {
      context.showSnackBar(SnackBar(content: Text("Title Required..")));
      return;
    }else if(state.side1Id != '' && state.side2Id != ''){

      print("Tapped");
      print(state.side1Id);
      print(state.side2Id);
      print(widget.resourceId!);
      /*BlocProvider.of<AddPromptsBloc>(context).add(
        AddPromptEvent(
            resourceId: widget.resourceId!,
            name: title_Controller.text),
      );*/
      EasyLoading.show();
      context.read<AddPromptsBloc>().add(
        AddPromptEvent(
            resourceId: widget.resourceId!,
            categoryId: widget.categoryId!,
            name: title_Controller.text),
      );

    }else{
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.side1Id ==''? 'Save resource1 first!' : 'Save resource2 first!')));
    }
  }

  Future<void> saveResource1(AddPromptsInitial state) async {

    if(state.side1selectedMediaType == 'Text') {
      if(_side1TextformKey.currentState!.validate()){
        EasyLoading.show();
        addPromptsBloc.add(
          AddResource(
              mediaUrl: 0,
              whichSide: 0,
              name: 'Unitited 1',
              resourceId: widget.resourceId,
              content: side1_Controller.text
          ),
        );
      }else{
        print('Hii');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill details correctly!')));
      }

    }else {
      print('Hii1');
      EasyLoading.show();
      addPromptsBloc.add(
        AddResource(
          mediaUrl:
          // state.side1ResourceUrl,
          state.side1selectedMediaType == 'Text'
              ? 0
              : state.side1selectedMediaType == 'Image'
              ? 1
              : state.side1selectedMediaType == 'Video'
              ? 3
              : state.side1selectedMediaType == 'Audio'
              ? 2
              : -1,
          whichSide: 0,
          name: 'Unitited 1',
          resourceId: widget.resourceId,
          content:
          // side1_Controller.text
          state.side1selectedMediaType == 'Image'
              ? state.side1ResourceUrl
              : state.side1selectedMediaType == 'Text'
              ? side1_Controller.text
              : state.side1ResourceUrl,
        ),
      );
    }
  }
  Future<void> saveResource2(AddPromptsInitial state) async {

    if(state.side2selectedMediaType == 'Text') {
      if(_side2TextformKey.currentState!.validate()){
        EasyLoading.show();
        addPromptsBloc.add(
          AddResource(
              mediaUrl: 0,
              whichSide: 1,
              name: 'United 2',
              resourceId: widget.resourceId,
              content: side2_Controller.text
          ),
        );
      }else{
        print('Hii3');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill details correctly!')));
      }

    }else{
      print('Hii4');
      EasyLoading.show();
      addPromptsBloc.add(
        AddResource(
          mediaUrl:
          // state.side1ResourceUrl,
          state.side2selectedMediaType ==
              'Text'
              ? 0
              : state.side2selectedMediaType ==
              'Image'
              ? 1
              : state.side2selectedMediaType ==
              'Video'
              ? 3
              : state.side2selectedMediaType ==
              'Audio'
              ? 2
              : -1,
          whichSide: 1,
          name: 'United 2',
          resourceId: widget.resourceId,
          content:
          // side2_Controller.text,
          state.side2selectedMediaType ==
              'Text'
              ? side2_Controller
              .text
              : state
              .side2ResourceUrl,
        ),
      );
    }

  }

  Future<Uint8List?> loadVideoThumbnail(String path) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    return uint8list;
  }

  Future<void> startRecording(int recorderValue) async {
    print('start');
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.audio.request();
    await Permission.accessMediaLocation.request();
    await Permission.manageExternalStorage.request();
    String downloadPath;

    if (Platform.isIOS) {
      var directory = await getApplicationDocumentsDirectory();
      downloadPath = directory.path + '/';
    } else {
      downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    }

    print(downloadPath);

    if(recorderValue == 1){

      setState(() {
        _isRecording1 = true;
      });
      await recorder1.start(
        path: '$downloadPath/myFile.m4a',
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 128000, // by default
        samplingRate: 44100, // by default
      );
    }else{

      setState(() {
        _isRecording2 = true;
      });
      await recorder2.start(
        path: '$downloadPath/myFile.m4a',
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 128000, // by default
        samplingRate: 44100, // by default
      );
    }
  }


  Future<void> stopRecording(int recorderValue) async {
    if(recorderValue == 1){
      setState(() {
        _isRecording1 = false;
      });

      final path = await recorder1.stop();
      //addMediaBloc.add(AudioPickEvent(audio: path));
      print(path);
      addPromptsBloc.add(
          PickResource(
              mediaUrl: path,
              whichSide: 0));

      //_togglePlayPause(path!);
      final audioFile = File(path!);
      print ('Recorded audio: $audioFile');
    }else{
      setState(() {
        _isRecording2 = false;
      });

      final path = await recorder2.stop();
      //addMediaBloc.add(AudioPickEvent(audio: path));
      print(path);
      addPromptsBloc.add(
          PickResource(
              mediaUrl: path,
              whichSide: 1));

      //_togglePlayPause(path!);
      final audioFile = File(path!);
      print ('Recorded audio: $audioFile');
    }
  }

}

String getFileType(String format) {
  List<String> photoFormats = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];
  List<String> videoFormats = ['.mp4', '.mov', '.avi', '.mkv'];
  List<String> audioFormats = ['.mp3', '.wav', '.ogg', '.m4a'];

  String lowerFormat = format.toLowerCase();

  for (String photoFormat in photoFormats) {
    if (lowerFormat.contains(photoFormat)) {
      return 'Photo';
    }
  }

  for (String videoFormat in videoFormats) {
    if (lowerFormat.contains(videoFormat)) {
      return 'Video';
    }
  }

  for (String audioFormat in audioFormats) {
    if (lowerFormat.contains(audioFormat)) {
      return 'Audio';
    }
  }

  return 'Unknown'; // Return 'Unknown' if no matching format is found.





}



