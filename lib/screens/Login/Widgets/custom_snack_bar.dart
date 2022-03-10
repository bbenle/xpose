import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSnackBar extends SnackBar {
  final Key key;
  final String text;

  CustomSnackBar({required this.key, required this.text})
      : super(
          key: key,
          elevation: 10.h,
          margin: EdgeInsets.only(top: 80.h),
          behavior: SnackBarBehavior.floating,
          content: Text(
            text,
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 3),
        );
}
