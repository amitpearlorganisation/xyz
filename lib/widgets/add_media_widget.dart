// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:self_learning_app/utilities/extenstion.dart';
//
// class MediaWidget extends StatelessWidget {
//   final int ?MediaOption;
//   final String? screenTitle;
//   final TextField? textField;
//   final Widget? mediaIcon;
//   final String? btnText;
//   final VoidCallback onPressed;
//
//   const MediaWidget(
//       {Key? key,
//       this.textField,
//       this.btnText,
//       this.mediaIcon,
//       this.screenTitle,
//       required this.onPressed, this.MediaOption})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(screenTitle!),
//         textField!,
//         Container(
//           height: context.screenHeight * 0.01,
//           width: context.screenWidth,
//           child: Center(child: mediaIcon),
//         ),
//         ElevatedButton(onPressed: onPressed, child: Text(btnText!))
//       ],
//     );
//   }
// }
