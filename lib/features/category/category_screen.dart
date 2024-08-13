import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:self_learning_app/features/category/bloc/category_bloc.dart';
import 'package:self_learning_app/features/category/bloc/category_state.dart';
import 'package:self_learning_app/utilities/colors.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/widgets/add_resources_screen.dart';
import '../../schedule/notificationflowmodel.dart';
import '../../utilities/notificationmangae.dart';
import '../../utilities/reqNotification.dart';
import '../add_Dailog/bloc/get_dailog_bloc/get_dailog_bloc.dart';
import '../add_Dailog/create_dailog_screen.dart';
import '../create_flow/data/model/flow_model.dart';
import '../create_flow/slide_show_screen.dart';
import '../dailog_category/dailog_cate_screen.dart';
import '../maincatbottomSheet/mainCategoryBottomSheet.dart';
import '../quick_add/quick_add_screen.dart';
import '../search_category/cate_search_delegate.dart';
import '../update_category/update_cate_screen.dart';

 @pragma("vm:entry-point")

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  print("Handling background in category message: ${message.data["id"]}");

  // Do something with the notification
}


class AllCateScreen extends StatefulWidget {
  const AllCateScreen({Key? key}) : super(key: key);

  @override
  State<AllCateScreen> createState() => _AllCateScreenState();
}

class _AllCateScreenState extends State<AllCateScreen> {


  int selectedIndex = 0;
  List<String> titles = ['All Categories', 'Dialogs','QuickAdd List ', 'Create Folder'];
  TextEditingController controller = TextEditingController(text: "  Search");
  TextEditingController quickaddcontroller = TextEditingController();
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool isLoading = true;


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

  bool showCatOrDialog = false;


  @override
  // late StreamSubscription _intentSub;
  void initState() {
    notificationManage.setnotiValue = true;

    updatefirstValue();
    context.read<CategoryBloc>().add(CategoryLoadEvent());
    methodcheck();

    super.initState();
    // _showFCMTokenDialog(context);


  }
  @override


  List<FlowModel> flowList = [];

  Future<void> fetchNotificationFlow({ required RemoteMessage message}) async {
    if (!mounted) return; // Check if the widget is still mounted
    var flowId = message.data["id"];
     if(flowId.isNotEmpty){
       EasyLoading.show(status: "loading");
       NotificationFlow notificationFlow = NotificationFlow();
       flowList = await notificationFlow.getFlow(flowId: flowId);

       _handleNotificationClick(message: message, flowList: flowList);
       EasyLoading.dismiss();

     }else{
       EasyLoading.showToast("flow id is null");
       print("flow id is empty");
     }

     // Check if the widget is still mounted

    EasyLoading.dismiss();

    // Optionally, you can print or process the flowList here
    print("This is inside the notification flow ${flowList}");
  }
  NotificationManage notificationManage = NotificationManage();
  void updateNotificationValue() {

    Timer(Duration(seconds: 30), () {
      print("Notification value updated to true after 30 seconds - ${notificationManage.getnotiValue}");
    });
  }
  void updatefirstValue() {

    Timer(Duration(milliseconds: 2), () {
      notificationManage.setnotiValue = true;
      print("Notification value updated to true after 30 seconds - ${notificationManage.getnotiValue}");
    });
  }

  void _handleNotificationClick({required RemoteMessage message, required List<FlowModel> flowList}) {

       print("flow length and valuecheck ${flowList.length } + ${ notificationManage.getnotiValue}");

      // Handle other logic if needed
       if(flowList[0].flowList.isNotEmpty && notificationManage.getnotiValue==true){
         print("value is not empty");
         Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => SlideShowScreen(
               flowList: flowList[0].flowList,
               flowName: flowList[0].title,
             ),
           ),
         ).then((value) {
           if (!mounted) return; // Check if the widget is still mounted
           flowList.clear();
           setState(() {
             notificationManage.setnotiValue = false;
             print("setstate category - ${notificationManage.getnotiValue}");
             context.read<CategoryBloc>().add(CategoryLoadEvent());
           });
           updateNotificationValue();
         });
       }
       else{

         print("value is not true");
       }

  }
  firebaseFun() async {
    print("Initializing Firebase Messaging");

   await CheckRequestNotification().requestNotificationPermission();

    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    String? token = await _firebaseMessaging.getToken();
    print("FCM token is $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received message: ${message.notification?.body}");
      showSimpleNotification(
        Text(message.notification?.title ?? ""),
        subtitle: Text(message.notification?.body ?? ""),
        background: Colors.red.shade700,
        duration: Duration(seconds: 2),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null) {
        print("Received message: ${message.data["id"]}");
        String? flowId = message.data['id'];
        print("on open app message");
          print("notEmpty");
          fetchNotificationFlow(
               message: message);



      } else {
        print("Notification message is null");
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) async{
      print("Notification this is intital message 1");

      if (message?.notification != null) {
        print("Notification this is intital not null");

        print("Received message: ${message?.data["id"]}");
        String? flowId = message?.data['id'];
        print("on open app message");
        print("notEmpty");
        fetchNotificationFlow(
             message: message!);



      } else {
        print("Notification this is intital message is run is null");
      }
    });
  }


  void methodcheck() async {
    await firebaseFun();
  }
  void dispose() {
    // _intentSub.cancel();
    super.dispose();
  }

  AwesomeDialog showDeleteDailog(
      {required String dailogName,
        required String dailogId,
        required int index,
        required BuildContext context}) {
    return AwesomeDialog(
        context: context,
        animType: AnimType.BOTTOMSLIDE,
        dialogType: DialogType.QUESTION,
        body: Center(
          child: Text(
            'Are you sure\nYou want to delete\n$dailogName',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        title: 'This is Ignored',
        desc: 'This is also Ignored',
        btnOkOnPress: () {
          context.read<GetDailogBloc>().add(DeleteDailogEvent(
              dailogId: dailogId, index: index, dailogName: dailogName));
        },
        btnOkColor: Colors.red,
        closeIcon: Icon(Icons.close),
        btnCancelOnPress: () {},
        btnOkText: "Delete",
        btnOkIcon: Icons.delete)
      ..show();
  }
  AwesomeDialog showDeleteCategory({
    required String CategoryName,
    required String categoryId,
    required int index,
    required BuildContext context,
  }) {
    return AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      dialogType: DialogType.QUESTION,
      body: Center(
        child: Text(
          'Are you sure\nYou want to delete\n$CategoryName',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {
        context.read<CategoryBloc>().add(CategoryDeleteEvent(
          rootId: categoryId,
          context: context,
          catList: [],
          deleteIndex: index,
        ));
      },
      btnOkColor: Colors.red,
      closeIcon: Icon(Icons.close),
      btnCancelOnPress: () {},
      btnOkText: "Delete",
      btnOkIcon: Icons.delete,
    )..show();
  }
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  TextEditingController _fcmTextController = TextEditingController();
  void _showFCMTokenDialog(BuildContext context) {
    String token = '';

    _fcm.getToken().then((value) {
      token = value ?? 'No FCM token found';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('FCM Token'),
            content: TextFormField(
              controller: _fcmTextController..text = token,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'FCM Token',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Category Screen");
    return Scaffold(
/*
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>SlideShowScreen(
            flowList: flowList[0].flowList, flowName: flowList[0].title,
          )));
          // _showFCMTokenDialog(context);
        },
      ),
*/
      body: Column(
        children: [
        const SizedBox(
          height: 20,
        ),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                  child: GestureDetector(

                    onTap: () async{
                      await showSearch(
                        context: context,
                        delegate: CustomSearchDelegate(),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BlurryContainer(
                        elevation: 1,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        height:   context.screenHeight * 0.058,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Search..',style: TextStyle(
                                color: Colors.black
                            ),),
                            Icon(Icons.search)
                          ],
                        ),
                      ),
                    ),
                  )
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(8.0), //<-- SEE HERE
              ),
              child: IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return AddResourceScreen2(resourceId: '',whichResources: 0,number: true,);
                    },));
                    // _showCustomDialog();

                    //_displayTextInputDialog(context);
                  },
                  icon: const Icon(Icons.add)),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: context.screenHeight * 0.05,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: titles.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: (){
                    setState(() {
                      selectedIndex=index;
                      if(index ==0){
                        showCatOrDialog = false;
                      }
                      if(index == 1){
                        showCatOrDialog = true;
                     /*   Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const NewDialog();
                        },));*/
                      }
                      if(index==2) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const QuickTypeScreen();
                        },));
                      }
                      if(index == 3){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddDailogScreen()));

                      }
                    });
                  },
                  child: Text('${titles[index]}    ',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: index == selectedIndex
                              ? primaryColor
                              : Colors.grey)),
                );
              },
            ),
          ),
        ),
        showCatOrDialog?
        BlocProvider(
          create: (context) => GetDailogBloc()..add(HitGetDailogEvent()),
          child: BlocListener<GetDailogBloc, GetDailogState>(
            listener: (context, state) {
              if (state is DailogDeleteSuccessfully) {
                context.read<GetDailogBloc>().add(HitGetDailogEvent());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    /// need to set following properties for best effect of awesome_snackbar_content
                    elevation: 0,
                    duration: Duration(seconds: 5),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: state.dailogname,
                      message: 'Successfully deleted!',

                      /// change contentType to ContentType.success, ContentType.warning, or ContentType.help for variants
                      contentType: ContentType.success,
                    ),
                  ),
                );
              }

              // TODO: implement listener
            },
            child: BlocBuilder<GetDailogBloc,
                GetDailogState>(
              builder: (context, state) {
                print(state);

                print("Checking condion");
                if (state is GetDailogLoadingState) {
                  print("Checking condion 2");

                  return Container(
                    alignment: Alignment.center,

                    width: double.infinity,
                    height: MediaQuery.of(context).size.height*0.6,
                    child: Container(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                          color: Colors.black),
                    ),
                  );
                }
                if (state is GetDailogSuccessState) {
                  if (state.dailogList!.length == 0) {
                    print("Checking condion 3");

                    return Container(
                        height: MediaQuery.of(context)
                            .size
                            .height *
                            0.7,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          "Dailog is empty\nCreate Dailog",
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ));
                  } else {
                    print("Checking condion 4");

                    return Expanded(
                      child: CustomScrollView(
                        slivers : [
                          SliverToBoxAdapter(
                            child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context)
                                .size
                                .height *
                                0.8,
                            child: GridView.builder(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 2.0),
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                MediaQuery.of(context)
                                    .size
                                    .width <
                                    600
                                    ? 2
                                    : MediaQuery.of(context)
                                    .size
                                    .width <
                                    1200
                                    ? 3
                                    : 6,
                                childAspectRatio: 3 / 2,
                              ),
                              itemCount:
                              state.dailogList!.length,
                              itemBuilder: (context, index) {
                                double containerHeight =
                                MediaQuery.of(context)
                                    .size
                                    .width <
                                    600
                                    ? 140.0
                                    : MediaQuery.of(context)
                                    .size
                                    .width <
                                    1200
                                    ? 200.0
                                    : 300.0;
                                double containerWidth =
                                MediaQuery.of(context)
                                    .size
                                    .width <
                                    600
                                    ? 150.0
                                    : MediaQuery.of(context)
                                    .size
                                    .width <
                                    1200
                                    ? 300.0
                                    : 300.0;
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10),
                                  padding: EdgeInsets.zero,
                                  height: 200,
                                  width: 200,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DailogCategoryScreen(
                                                    promptList:
                                                    state
                                                        .promptList!,
                                                    resourceList:
                                                    state
                                                        .resourceList!,
                                                    dailoId: state
                                                        .dailogList![
                                                    index]
                                                        .dailogId,
                                                  )));
                                    },
                                    child: Card(
                                        elevation: 2.0,
                                        color:
                                        generateRandomColor(),
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Text(state
                                                  .dailogList![
                                              index]
                                                  .dailogName),
                                            ),
                                            Align(
                                              alignment:
                                              Alignment
                                                  .topRight,
                                              child:
                                              PopupMenuButton(
                                                icon: Icon(
                                                  Icons
                                                      .more_vert,
                                                  color: Colors
                                                      .red,
                                                ),
                                                itemBuilder:
                                                    (context) {
                                                  return [
                                                    const PopupMenuItem(
                                                        value:
                                                        'update',
                                                        child: InkWell(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.start,
                                                              children: [
                                                                Icon(
                                                                  Icons.update,
                                                                  color: primaryColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 8.0,
                                                                ),
                                                                Text("Update"),
                                                              ],
                                                            ))),
                                                    const PopupMenuItem(
                                                        value:
                                                        'delete',
                                                        child: InkWell(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.start,
                                                              children: [
                                                                Icon(
                                                                  Icons.delete,
                                                                  color: primaryColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 8.0,
                                                                ),
                                                                Text("Delete"),
                                                              ],
                                                            )))
                                                  ];
                                                },
                                                onSelected:
                                                    (String
                                                value) {
                                                  switch (
                                                  value) {
                                                    case 'update':
                                                    /*Navigator.push(context, MaterialPageRoute(
                                                            builder: (context) {
                                                              return UpdateCateScreen(
                                                                rootId: state.cateList[index].sId,
                                                                selectedColor: currentColor,
                                                                categoryTitle: state.cateList[index].name,
                                                                tags: state.cateList[index].keywords,
                                                              );
                                                            },
                                                          ));*/
                                                      break;
                                                    case 'delete':
                                                      showDeleteDailog(
                                                          dailogName: state
                                                              .dailogList![
                                                          index]
                                                              .dailogName,
                                                          index:
                                                          index,
                                                          dailogId: state
                                                              .dailogList![
                                                          index]
                                                              .dailogId,
                                                          context:
                                                          context);

                                                      break;
                                                  }
                                                },
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                );
                              },
                            ),
                        ),
                          ),

                          SliverToBoxAdapter(
                            child: SizedBox(height: 20,),
                          )
                ]
                      ),
                    );
                  }
                }

                if (state is GetDailogErrorState) {
                  print("Checking condion 5");

                  return Center(
                    child: Text("Something went wrong"),
                  );
                }
                print(state);
                print("Checking condion 6");

                return Center(
                  child: Text("Something went wrong"),
                );
              },
            ),
          ),
        ):
        BlocConsumer<CategoryBloc, CategoryState>(
  listener: (context, state) {
      if (state is CategoryDeleteSuccess){
        context.read<CategoryBloc>().add(CategoryLoadEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            /// need to set following properties for best effect of awesome_snackbar_content
            elevation: 0,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: "Category",
              message: 'Successfully deleted!',

              /// change contentType to ContentType.success, ContentType.warning, or ContentType.help for variants
              contentType: ContentType.success,
            ),
          ),
        );
      }
  },
  builder: (context, state) {
      return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CategoryLoaded) {
              if (state.cateList.isNotEmpty) {
                return Expanded(
                  child: Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: GridView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    // padding: EdgeInsets.all(15),
                    itemCount: state.cateList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: context.screenHeight * 0.15,
                        crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      Color currentColor = primaryColor;

                      if (state.cateList[index].styles!.isNotEmpty) {
                        if (state.cateList[index].styles![1].value!.length != 10) {
                          currentColor = primaryColor;
                        } else {
                          currentColor = Color(int.parse(
                              state.cateList[index].styles![1].value!))??primaryColor;
                        }
                      }

                      return GestureDetector(
                        child: Card(
                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(10.0), //<-- SEE HERE
                          ),
                          color: currentColor,
                          // generateRandomColor(),
                          //padding: const EdgeInsets.all(8),
                          // decoration: BoxDecoration(
                          //
                          //   borderRadius: BorderRadius.circular(10),
                          //   color: generateRandomColor(),
                          //   border: Border.all(color: currentColor, width: 3),
                          //
                          // ),
                          elevation: 2,
                          child: Stack(
                            children: [
                              Center(
                                child: Text(state.cateList[index].name.toString(),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style:  TextStyle(color: Colors.white, fontWeight: FontWeight.w500,letterSpacing: 1)),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child:
                                PopupMenuButton(

                                  icon: Icon(Icons.more_vert,color: Colors.red,),
                                  itemBuilder: (context) {
                                    return [

                                      const PopupMenuItem(
                                          value: 'update',
                                          child: InkWell(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.update, color: primaryColor,),
                                                  SizedBox(width: 8.0,),
                                                  Text("Update"),
                                                ],
                                              ))
                                      ),
                                      const PopupMenuItem(
                                          value: 'delete',
                                          child: InkWell(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.delete, color: primaryColor,),
                                                  SizedBox(width: 8.0,),
                                                  Text("Delete"),
                                                ],
                                              ))
                                      )
                                    ];
                                  },
                                  onSelected: (String value) {
                                    switch(value){
                                      case 'update':
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context) {
                                            return UpdateCateScreen(
                                              rootId: state.cateList[index].sId,
                                              selectedColor: currentColor,
                                              categoryTitle: state.cateList[index].name,
                                              tags: state.cateList[index].keywords,
                                            );
                                          },
                                        ));
                                        break;
                                      case 'delete':
                                        showDeleteCategory(
                                            CategoryName: state.cateList[index].name??'',
                                            categoryId: state.cateList[index].sId??'',
                                            index: index,
                                            context: context);
                                        // context.read<CategoryBloc>().add(CategoryDeleteEvent(
                                        //   rootId: state.cateList[index].sId??'',
                                        //   context: context,
                                        //   catList: state.cateList,
                                        //   deleteIndex: index,
                                        // ));
                                        break;
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        onTap: () {

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true, // Set to true for a full-height bottom sheet

                            builder: (BuildContext context) {
                              return Container(
                                height: MediaQuery.of(context).size.height*0.7,
                                child: MainCatBottomSheet(categoryName: state.cateList[index].name.toString(),
                                rootId: state.cateList[index].sId,
                                  color: Colors.red,
                                  tags: state.cateList[index].keywords,
                                ),
                              );

                                // MainCatBottomSheet();
                            },
                          );

/*
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return SubCategoryScreen(
                                tags: state.cateList[index].keywords,
                                color: Color(
                                  int.parse(
                                      state.cateList[index].styles![1].value!),
                                ),
                                rootId: state.cateList[index].sId,
                                categoryName: state.cateList[index].name,
                              );
                            },
                          ));
*/
                        },
                        onLongPress: () {

                        },
                      );
                    },
                  ),
                ),);
              } else {
                return SizedBox(height: context.screenHeight/2,child: const Center(child: Text('No Categories Found')),);
              }
            } else {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
          },
        );
  },
)
      ],),
    );
  }
}
