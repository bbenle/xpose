import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:x_ray_simulator/screens/Login/Widgets/custom_snack_bar.dart';
import 'package:x_ray_simulator/screens/Login/validate.dart';
import '../../style.dart';
import 'Widgets/adjusting_padding.dart';
import 'Widgets/form_button.dart';
import 'Widgets/input_form.dart';
import 'auth.dart';
import '../../main.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Login extends StatelessWidget {
  final Auth authHandler;
  final bool isPhone;

  Login({required this.authHandler, required this.isPhone});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // when tapping outside of the textfield, the keyboard goes back down
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        // This is to stop the keyboard from overflowing
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Stack(
            children: [
              OrientationBuilder(
                builder: (BuildContext context, Orientation orientation) {
                  return AdjustingPadding(
                    max: 30,
                    min: 0,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Title(),
                    ),
                  );
                },
              ),
              OrientationBuilder(
                builder: (BuildContext context, Orientation orientation) {
                  return Padding(
                    padding: EdgeInsets.only(top: 550.h),
                    child: AlternateOptions(),
                  );
                },
              ),
              Column(
                children: [
                  AdjustingPadding(max: 160, min: 160),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            LoginForm(
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
      ),
    );
  }
}

class Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NeumorphicText('Xpose',
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

class LoginForm extends StatelessWidget {
  static final Key emailTextFieldKey = Key('EmailTextField');
  static final Key passwordTextFieldKey = Key('PasswordTextField');
  static final Key loginButtonKey = Key('LoginButton');
  static final Key popupKey = Key('Popup');

  final logFormKey = GlobalKey<FormState>();
  final emailLogController = TextEditingController();
  final passwordLogController = TextEditingController();
  final Auth authHandler;
  final bool isPhone;

  String errMsg = "";

  LoginForm({required this.authHandler, required this.isPhone});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: logFormKey,
      child: Column(
        children: <Widget>[
          // Email TextBox
          InputForm(
            key: LoginForm.emailTextFieldKey,
            isPhone: isPhone,
            controller: emailLogController,
            obscureText: false,
            hintText: "Email",
          ),
          Padding(padding: EdgeInsets.only(top: 10.h)),

          InputForm(
            key: LoginForm.passwordTextFieldKey,
            isPhone: isPhone,
            controller: passwordLogController,
            obscureText: true,
            hintText: "Password",
          ),
          // Password TextBox
          Padding(padding: EdgeInsets.only(top: 10.h)),

          FormButton(
              key: LoginForm.loginButtonKey,
              callback: submitLogin,
              text: 'Login'),
        ],
      ),
    );
  }

  void submitLogin(BuildContext context) {
    if (((emailLogController.text.compareTo('admin')) == 0) &&
        (passwordLogController.text.compareTo('password')) == 0) {
      Navigator.pushNamed(context, AdminPageRoute);
    } else {
      // trim() cuts out any spaces
      authHandler.SignInWithEmailNPassword(
              emailLogController.text.trim(), passwordLogController.text.trim())
          .then((bool success) {
        if (success) {
          Navigator.of(context).pushReplacementNamed(
              MainMenuRoute); //Pops the current screen and replaces with next screen
        } else {
          errMsg = loginErrMsgs(
              emailLogController.text, passwordLogController.text)!;

          final snackBar =
              CustomSnackBar(key: LoginForm.popupKey, text: errMsg);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }).catchError((e) {
        print(e);
      });
    }
  }
}

class AlternateOptions extends StatelessWidget {
  static final Key registerButtonKey = Key('RegisterButton');
  static final Key resetButtonKey = Key('ResetButton');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                key: AlternateOptions.registerButtonKey,
                onPressed: () {
                  Navigator.pushNamed(context, RegisterRoute);
                },
                child: Text('Register An Account', style: textStyle)),
            TextButton(
                key: AlternateOptions.resetButtonKey,
                onPressed: () {
                  Navigator.pushNamed(context, ResetRoute);
                },
                child: Text('Forgot Password', style: textStyle)),
          ],
        ),
      ],
    );
  }
}
