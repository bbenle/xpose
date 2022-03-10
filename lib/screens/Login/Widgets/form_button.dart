import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormButton extends StatelessWidget {
  final Key key;
  final Function(BuildContext context) callback;
  final String text;

  FormButton({required this.key, required this.callback, required this.text});

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onPressed: () {
        callback(context);
      },
      style: NeumorphicStyle(
          shape: NeumorphicShape.flat, color: NeumorphicColors.embossMaxWhiteColor),
      child: Text(text, style: TextStyle(fontSize: 14.sp)),
    );
  }
}
