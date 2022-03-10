import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:x_ray_simulator/screens/Login/Widgets/back_button.dart' as back;
import 'package:x_ray_simulator/screens/Login/Widgets/input_form.dart';
import 'package:x_ray_simulator/style.dart';
import 'dart:math';
import 'dart:convert';
import 'google_auth_api.dart';

class AdminPage extends StatelessWidget {
  final bool isPhone;

  AdminPage({required this.isPhone});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // when tapping outside of the textfield, the keyboard goes back down
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Column(
              children: [
                // Expanded is needed to accommodate different screen sizes
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Title(),
                        GenerateCode(isPhone: isPhone,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            back.BackButton(isPhone: isPhone)
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
        NeumorphicText('Admin Page',
            style:
                NeumorphicStyle(color: Colors.black, depth: 2, intensity: 10),
            textStyle: NeumorphicTextStyle(
                fontSize: 50.sp, fontWeight: FontWeight.w300)),
        Padding(padding: EdgeInsets.only(top: 20.h)),
        Neumorphic(
            style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(), intensity: 1),
            child: Image.asset('assets/logos/logo.png', width: 100.w)),
      ],
    );
  }
}

class GenerateCode extends StatelessWidget {
  final usersEmailCon = TextEditingController();
  final bool isPhone;

  GenerateCode({required this.isPhone});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: <Widget>[
          InputForm(
              key: Key("admin input form"),
              isPhone: isPhone,
              controller: usersEmailCon,
              obscureText: false,
              hintText: "Enter user's email"),
          Padding(padding: EdgeInsets.only(top: 10.h)),
          // Send Request Button
          NeumorphicButton(
            onPressed: () {
              sendEmail(usersEmailCon.text);
            },
            style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                color: NeumorphicColors.embossMaxWhiteColor),
            child: Text('Generate', style: textStyle),
          ),
          Padding(padding: EdgeInsets.only(top: 100.h))
        ],
      ),
    );
  }
}

// Generates a string that has 8 characters
String genRanStr() {
  // Creates a cryptographically secure random number generator.
  Random random = Random.secure();
  var values = List<int>.generate(4, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

/*
    If you are unable to send an activation email to the user , you need to sign out of
    google and then sign back in.

    Alternatively, uncomment the code below

    GoogleAuthApi.signOut();
    return;

    Click generate, Hot reload, comment out the 2 lines of code, click generate
    and then you will get asked to sign into google.

    To know if an email has been successfully sent, you will get something like this
    in console.

    flutter: Message sent: Message successfully sent.
    Connection was opened at: 2021-10-05 11:22:20.138583.
    Sending the message started at: 2021-10-05 11:22:21.935953 and finished at: 2021-10-05 11:22:23.812579.
   */
Future sendEmail(String destinationEmail) async {
  //GoogleAuthApi.signOut();
  //return;

  final randomString = genRanStr();

  final user = await GoogleAuthApi.signIn();
  if (user == null) return;

  final email = user.email;
  final auth = await user.authentication;
  final token = auth.accessToken;

  final smtpServer = gmailSaslXoauth2(email, token!);

  final message = Message()
    ..from = Address(email, 'Xpose Team')
    ..recipients = [destinationEmail]
    ..subject = 'Activation Code For Registration'
    ..text = 'Hi, \n\n Your activation code is: ' +
        randomString +
        '\n\n Kind regards, \nXpose Team';

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}
