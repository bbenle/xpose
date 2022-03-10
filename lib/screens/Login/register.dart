import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:x_ray_simulator/screens/Login/Widgets/back_button.dart' as back;
import 'package:x_ray_simulator/screens/Login/validate.dart';
import 'Widgets/adjusting_padding.dart';
import 'Widgets/custom_snack_bar.dart';
import 'Widgets/form_button.dart';
import 'Widgets/input_form.dart';
import 'auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Register extends StatelessWidget {
  final Auth authHandler;
  final bool isPhone;

  Register({required this.authHandler, required this.isPhone});

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
                      AdjustingPadding(max: 200, min: 160),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RegisterForm(
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
        NeumorphicText('Register',
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

class RegisterForm extends StatelessWidget {
  static final Key emailTextFieldKey = Key('EmailTextField');
  static final Key passwordOneTextFieldKey = Key('PasswordOneTextField');
  static final Key passwordTwoTextFieldKey = Key('PasswordTwoTextField');
  static final Key activationCodeTextFieldKey = Key('ActivationCodeTextField');
  static final Key registerButtonKey = Key('RegisterButton');
  static final Key validPopupKey = Key('ValidPopup');
  static final Key popupKey = Key('Popup');

  final registerFormKey = GlobalKey<FormState>();

  final emailRegController = TextEditingController();
  final firstPassController = TextEditingController();
  final secondPassController = TextEditingController();
  final activationCode = TextEditingController();
  final Auth authHandler;
  final bool isPhone;

  String errMsg = "";

  RegisterForm({required this.authHandler, required this.isPhone});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: registerFormKey,
      child: Column(
        children: <Widget>[
          InputForm(
            key: RegisterForm.emailTextFieldKey,
            isPhone: isPhone,
            controller: emailRegController,
            obscureText: false,
            hintText: "Email",
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 10.h, 0, 0)),
          InputForm(
            key: RegisterForm.passwordOneTextFieldKey,
            isPhone: isPhone,
            controller: firstPassController,
            obscureText: true,
            hintText: "Password",
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 10.h, 0, 0)),
          InputForm(
            key: RegisterForm.passwordTwoTextFieldKey,
            isPhone: isPhone,
            controller: secondPassController,
            obscureText: true,
            hintText: "Retype Password",
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 10.h, 0, 0)),
          InputForm(
            key: RegisterForm.activationCodeTextFieldKey,
            isPhone: isPhone,
            controller: activationCode,
            obscureText: false,
            hintText: "Account Activation Code",
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 10.h, 0, 0)),
          FormButton(
              key: RegisterForm.registerButtonKey,
              callback: submitRegister,
              text: 'Register'),
        ],
      ),
    );
  }

  void submitRegister(BuildContext context) {
    int answer = registerEmailValidation(
        firstPassController.text,
        secondPassController.text,
        emailRegController.text,
        activationCode.text);
    if (answer == 1) {
      authHandler.RegisterNewAccount(
              emailRegController.text.trim(), firstPassController.text.trim())
          .then((bool success) {
        if (success) {
          final snackBar = CustomSnackBar(
              key: RegisterForm.validPopupKey,
              text: "A verification email has been sent");
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }).catchError((e) {
        print(e);
      });
    } else {
      {
        errMsg = registerErrMsgs(
            emailRegController.text,
            firstPassController.text,
            secondPassController.text,
            activationCode.text)!;

        final snackBar =
            CustomSnackBar(key: RegisterForm.popupKey, text: errMsg);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
