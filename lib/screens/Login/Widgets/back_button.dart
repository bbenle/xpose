import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class BackButton extends StatelessWidget {
  static final Key backButtonKey = Key('BackButton');
  final bool isPhone;

  BackButton({required this.isPhone});

  @override
  Widget build(BuildContext context) {
    double bottom = 30;
    double left = 45;
    double height = 130;
    double? size = 50;

    if (isPhone) {
      bottom = 20;
      left = 15;
      height = 60;
      size = null;
    }

    return KeyboardVisibilityBuilder(
      builder: (BuildContext context, bool isKeyboardVisible) {
        if (isKeyboardVisible) {
          return Text(''); //Show nothing
        }

        return Positioned(
          bottom: bottom,
          left: left,
          child: Container(
            height: height,
            child: NeumorphicButton(
              key: BackButton.backButtonKey,
              onPressed: () {
                Navigator.pop(context);
              },
              style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                  shape: NeumorphicShape.flat,
                  color: Colors.white),
              child: Icon(
                Icons.keyboard_arrow_left_sharp,
                size: size,
              ),
            ),
          ),
        );
      },
    );
  }
}