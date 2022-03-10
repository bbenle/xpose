/*
  main_menu.dart: Displays menu for body part selection
  AUTHOR: David Vasilevski
  DATE CREATED: 4 August 2021
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:x_ray_simulator/Models/XRayScans.dart';
import 'package:x_ray_simulator/main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainMenu extends StatefulWidget {
  final List<XRayScans> scansList;
  final bool isPhone;
  static const TITLE_MESSAGE = 'Select a body part to image';
  static const EMPTY_SCANS_MESSAGE = 'No body part available!';
  static const goButtonKey = Key('GoButton');
  static const baseXRayScanTileKey = 'XRayScanTile_';

  MainMenu({required this.scansList, required this.isPhone});

  @override
  _MainMenuState createState() => _MainMenuState(scans: scansList);
}

class _MainMenuState extends State<MainMenu> {
  final List<XRayScans> scans;
  XRayScans? selectedScans;
  bool isPlay = false;

  _MainMenuState({required this.scans});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return Stack(
            children: [
              Column(
                children: [
                  Padding(padding: EdgeInsets.fromLTRB(0, 80.h, 0, 0)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 15.h),
                    child: NeumorphicText(MainMenu.TITLE_MESSAGE,
                        style: NeumorphicStyle(
                            color: Colors.black, depth: 2, intensity: 10),
                        textStyle: NeumorphicTextStyle(
                            fontSize: 30.sp, fontWeight: FontWeight.w300)),
                  ),
                  Expanded(
                    child: scans.isNotEmpty
                        ? _BuildXRayScansTiles(context, scans)
                        : Center(
                            child: Text(MainMenu.EMPTY_SCANS_MESSAGE),
                          ),
                  ),
                ],
              ),
              GoButton(
                key: MainMenu.goButtonKey,
                scans: selectedScans,
                isPhone: widget.isPhone,
              ),
            ],
          );
        },
      ),
    );
  }

  ListView _BuildXRayScansTiles(
      BuildContext context, List<XRayScans> xRayScans) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: xRayScans.length * 2,
      itemBuilder: (context, index) {
        int trueIndex = index ~/ 2;
        if (index.isOdd) {
          return Padding(padding: EdgeInsets.fromLTRB(40, 40, 0, 0));
        } else {
          return XRayScansTile(
              key: Key(MainMenu.baseXRayScanTileKey + trueIndex.toString()),
              xRayScans: xRayScans[trueIndex],
              selectedScans: selectedScans,
              selection: selection);
        }
      },
    );
  }

  // void buttonSounds() {
  //   if (isPlay) {
  //     player.stop();
  //     isPlay = false;
  //   }
  //   audioCache.play('click.mp3', mode: PlayerMode.LOW_LATENCY);
  //   isPlay = true;
  // }

  void selection(XRayScans xRayScans) {
    setState(() {
      if (selectedScans == xRayScans) {
        selectedScans = null;
      } else {
        selectedScans = xRayScans;
      }
    });
  }
}

class XRayScansTile extends StatelessWidget {
  final XRayScans xRayScans;
  final XRayScans? selectedScans;
  final Function selection;
  late final Color color;

  XRayScansTile(
      {required Key key,
      required this.xRayScans,
      required this.selectedScans,
      required this.selection})
      : super(key: key) {
    color = (xRayScans == selectedScans) ? Color(0xffcfdce6) : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    double height = 150.h;
    double width = 205.w;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      height = 150.h;
      width = 125.w;
    }

    return Align(
        alignment: Alignment.center,
        child: Container(
          //height of button
          height: height,
          width: width,
          child: NeumorphicButton(
            style: NeumorphicStyle(
                color: color, shape: NeumorphicShape.convex, depth: 15),
            onPressed: () => selection(xRayScans),
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: TextStyle(
                    fontSize: 14.0.sp,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: 'PROJECTION: ',
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: xRayScans.description.viewType +
                            ' ' +
                            xRayScans.bodyPart),
                    TextSpan(
                        text: '\n\nAGE: ',
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: xRayScans.description.age.toString()),
                    TextSpan(
                        text: '\nSID: ',
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: xRayScans.description.SID),
                    TextSpan(
                        text: '\nGRID: ',
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: xRayScans.description.grid),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class GoButton extends StatelessWidget {
  final XRayScans? scans;
  final bool isPhone;

  GoButton(
      {required Key key,
      required this.scans,
      required this.isPhone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double bottom = 30;
    double rightOnScreen = 45;
    double rightOffScreen = -85;
    double containerHeight = 130;
    double? iconSize = 50;

    if (isPhone) {
      bottom = 20;
      rightOnScreen = 15;
      rightOffScreen = -65;
      containerHeight = 60;
      iconSize = null;
    }

    return AnimatedPositioned(
      duration: Duration(milliseconds: 120),
      bottom: bottom,
      right: scans != null ? rightOnScreen : rightOffScreen,
      child: Container(
        height: containerHeight,
        child: NeumorphicButton(
          style: NeumorphicStyle(
              color: Color(0xffcfdce6), boxShape: NeumorphicBoxShape.circle()),
          onPressed: () {
            //check if actual XRaysScans is selected
            if (scans != null) {
              Navigator.pushNamed(
                context,
                ControlPanelRoute,
                arguments: {SCANS: scans!},
              );
            }
          },
          child: Icon(Icons.keyboard_arrow_right_sharp, size: iconSize),
        ),
      ),
    );
  }
}
