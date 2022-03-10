import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:x_ray_simulator/screens/Login/Widgets/adjusting_padding.dart';
import 'package:x_ray_simulator/screens/Login/Widgets/back_button.dart' as back;
import 'package:x_ray_simulator/screens/Login/validate.dart';
import 'package:x_ray_simulator/screens/Login/auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Widgets/custom_snack_bar.dart';
import 'Widgets/form_button.dart';
import 'Widgets/input_form.dart';

class Reset extends StatelessWidget {
  final Auth authHandler;
  final bool isPhone;

  Reset({required this.authHandler, required this.isPhone});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // when tapping outside of the textfield, the keyboard goes back down
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SafeArea(
              child: Stack(
                children: [
                  AdjustingPadding(
                    max: 30,
                    min: 0,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Title(),
                    ),
                  ),
                  Column(
                    children: [
                      AdjustingPadding(max: 265, min: 160),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ResetForm(
                                  authHandler: authHandler,
                                  isPhone: isPhone,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            back.BackButton(isPhone: isPhone),
          ],
        ),
      ),
    );
  }
}

class Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NeumorphicText('Forgot Password',
            style:
                NeumorphicStyle(color: Colors.black, depth: 2, intensity: 10),
            textStyle: NeumorphicTextStyle(
                fontSize: 50.sp, fontWeight: FontWeight.w300)),
        AdjustingPadding(max: 20, min: 0),
        Neumorphic(
            style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(), intensity: 1),
            child: Image.asset('assets/logos/logo.png',
                height: 100.h, width: 100.w)),
      ],
    );
  }
}

class ResetForm extends StatelessWidget {
  static final Key emailTextFieldKey = Key('EmailTextField');
  static final Key resetButtonKey = Key('ResetButton');
  static final Key validPopupKey = Key('ValidPopup');
  static final Key errorPopupKey = Key('ErrorPopup');
  final resetFormKey = GlobalKey<FormState>();
  final emailRegController = TextEditingController();
  final Auth authHandler;
  final bool isPhone;

  String errMsg = "";

  ResetForm({required this.authHandler, required this.isPhone});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: resetFormKey,
      child: Column(
        children: <Widget>[
          InputForm(
            key: ResetForm.emailTextFieldKey,
            isPhone: isPhone,
            controller: emailRegController,
            obscureText: false,
            hintText: "Please enter your email",
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 10.h, 0, 0)),
          FormButton(
              key: ResetForm.resetButtonKey,
              callback: submitReset,
              text: 'Reset'),
          AdjustingPadding(max: 100, min: 0),
        ],
      ),
    );
  }

  void submitReset(BuildContext context) {
    if (emailRegController.text.contains("@curtin.edu.au")) {
      authHandler.sendPasswordResetEmail(emailRegController.text.trim());
      final snackBar = CustomSnackBar(
          key: ResetForm.validPopupKey,
          text: "A reset password email has been sent");
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      errMsg = resetErrMsgs(emailRegController.text);

      final snackBar =
          CustomSnackBar(key: ResetForm.errorPopupKey, text: errMsg);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
