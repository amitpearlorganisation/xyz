import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../utilities/colors.dart';

class AuthButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color? btnColor;
  const AuthButton({Key? key, required this.title, required this.onPressed, this.btnColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return SizedBox(
      height: h*0.05,
      width: w/2,
      child: PlatformElevatedButton(
        color: btnColor,
          cupertino: (context, platform) {
            return CupertinoElevatedButtonData();
          },
          material: (context, platform) {
            return MaterialElevatedButtonData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                backgroundColor: btnColor,
              ),
            );
          },
          onPressed: onPressed,
          child: Text(
            title,
            style: const TextStyle(fontSize: 17),
          ))
    );
  }
}
