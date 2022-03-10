import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:x_ray_simulator/style.dart';

class InputForm extends StatelessWidget {
  final Key key;
  final bool isPhone;
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;

  InputForm(
      {required this.key, required this.isPhone, required this.controller, required this.obscureText, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: textFormStyle,
      child: Align(
        alignment: Alignment.centerLeft,
        heightFactor: isPhone ? 0.90 : 1.7,
        widthFactor: 0.85,
        child: TextFormField(
          key: key,
          autocorrect: false,
          enableSuggestions: false,
          controller: controller,
          style: TextStyle(fontSize: 15.sp),
          obscureText: obscureText,
          decoration: InputDecoration(
              hintStyle: TextStyle(fontSize: 15.sp),
              border: InputBorder.none,
              hintText: hintText,
              contentPadding: EdgeInsets.only(left: 10.0.w)),
        ),
      ),
    );
  }
}
