import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdjustingPadding extends StatelessWidget {
  final int max, min;
  final Widget? child;

  AdjustingPadding({required this.max, required this.min, this.child});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return KeyboardVisibilityBuilder(
          builder: (BuildContext context, bool isKeyboardVisible) {
            return Padding(
              padding: EdgeInsets.only(
                  top: orientation == Orientation.portrait && !isKeyboardVisible
                      ? max.h
                      : min.h),
              child: child,
            );
          },
        );
      },
    );
  }
}