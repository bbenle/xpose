import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:x_ray_simulator/Models/Images.dart';
import 'package:x_ray_simulator/Models/XRayScans.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Models/Data.dart';
import '../../TooltipShapeBorder.dart';
import '../../main.dart';

class ControlPanel extends StatefulWidget {
  static const int KVP_MIN = 0;
  static const int KVP_MAX = 120;
  final XRayScans scans;
  final isPhone;

  ControlPanel({required this.scans, required this.isPhone});

  @override
  ControlPanelState createState() => ControlPanelState(scans: scans);
}

@visibleForTesting
class ControlPanelState extends State<ControlPanel> {
  //range of kVp: 0 to 120 (inclusive)
  int kvpValue = ControlPanel.KVP_MIN;
  //range of mAs: 1 to 100 (inclusive)
  final List<num> masValues = Data().masValues;
  final AudioPlayer player = new AudioPlayer();
  AudioCache audioCache = new AudioCache();
  bool exposureReady = false;
  int masIndex = 0;
  bool isPlay = false;
  StreamController<int> _controller = StreamController<int>.broadcast();

  XRayScans scans;
  String? filePath;
  Images? image;

  ControlPanelState({required this.scans}) {
    audioCache = new AudioCache(fixedPlayer: player);
    audioCache.load('beep.mp3');
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (widget.isPhone) {
      return phone(isLandscape);
    }
    return tablet(isLandscape);
  }

  Widget tablet(bool isLandscape) {
    return Scaffold(
      body: TabletHandleOrientation(
        logo: ExposureLogo(
          exposureReady: exposureReady,
        ),
        image: XrayImage(
          filePath: filePath,
        ),
        title: NeumorphicText(
          scans.description.viewType + ' ' + scans.bodyPart,
          style: NeumorphicStyle(color: Colors.black, depth: 2, intensity: 10),
          textStyle:
              NeumorphicTextStyle(fontSize: 30, fontWeight: FontWeight.w300),
        ),
        controls: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Kvp(
                      kvpValue: kvpValue,
                      kvpUp: kvpUp,
                      kvpDown: kvpDown,
                      isPhone: widget.isPhone,
                      isLandscape: isLandscape,
                    ),
                    Mas(
                      masValue: masValues[masIndex],
                      masUp: masUp,
                      masDown: masDown,
                      isPhone: widget.isPhone,
                      isLandscape: isLandscape,
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 50)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ExposeButton(
                      expose: exposeTablet,
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 60))
              ],
            ),
            BackButton(
              isPhone: widget.isPhone,
            ),
            InformationButtonMobile(
                scans: scans,
                image: image,
                isPhone: widget.isPhone,
                stream: _controller.stream),
          ],
        ),
      ),
    );
  }

  Widget phone(isLandscape) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 20.h,
                  right: 25.w,
                  child: ExposureLogo(
                    exposureReady: exposureReady,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 50.h,
                      width: 200.w,
                      child: Center(
                        child: NeumorphicText(
                          scans.description.viewType + " " + scans.bodyPart,
                          style: NeumorphicStyle(
                              color: Colors.black, depth: 2, intensity: 10),
                          textStyle: NeumorphicTextStyle(
                              fontSize: 30, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(padding: EdgeInsets.only(top: 25.h)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Kvp(
                          kvpValue: kvpValue,
                          kvpUp: kvpUp,
                          kvpDown: kvpDown,
                          isPhone: widget.isPhone,
                          isLandscape: isLandscape,
                        ),
                        Mas(
                            masValue: masValues[masIndex],
                            masUp: masUp,
                            masDown: masDown,
                            isPhone: widget.isPhone,
                            isLandscape: isLandscape),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ExposeButton(
                          expose: exposePhone,
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 1.h)),
                  ],
                ),
              ],
            ),
          ),
          BackButton(
            isPhone: widget.isPhone,
          ),
          InformationButton(
            scans: scans,
            image: image,
            isPhone: widget.isPhone,
          ),
        ],
      ),
    );
  }

  void buttonSound() {
    if (isPlay) {
      player.stop();
      isPlay = false;
    }
    audioCache.play('beep.mp3', mode: PlayerMode.LOW_LATENCY);
    isPlay = true;

    setState(() {
      exposureReady = false;
    });
  }

  void clickSound() {
    if (isPlay) {
      player.stop();
      isPlay = false;
    }
    audioCache.play('click.mp3', mode: PlayerMode.LOW_LATENCY);
    isPlay = true;
  }

  void exposeSound() {
    audioCache.play('expose.mp3', mode: PlayerMode.LOW_LATENCY);
  }

  void kvpUp() {
    setState(() {
      if (kvpValue < ControlPanel.KVP_MAX) {
        kvpValue += 1;
      }
    });
    HapticFeedback.lightImpact();
    buttonSound();
  }

  void kvpDown() {
    setState(() {
      if (kvpValue > ControlPanel.KVP_MIN) {
        kvpValue -= 1;
      }
    });
    HapticFeedback.lightImpact();

    buttonSound();
  }

  void masUp() {
    setState(() {
      if (masIndex < masValues.length - 1) {
        masIndex++;
      }
    });
    HapticFeedback.lightImpact();
    buttonSound();
  }

  void masDown() {
    setState(() {
      if (masIndex > 0) {
        masIndex--;
      }
    });
    HapticFeedback.lightImpact();
    buttonSound();
  }

  void exposeTablet() {
    Images retrievedImage = scans.getImage(kvpValue, masValues[masIndex]);
    // bring up the image accordingly
    setState(() {
      image = retrievedImage;
      filePath = image!.filePath;
      exposureReady = true;
    });
    _controller.add(1);

    exposeSound();
  }

  void exposePhone() {
    Images image = scans.getImage(kvpValue, masValues[masIndex]);
    Navigator.pushNamed(context, ControlPanelMobileRoute, arguments: {
      IMAGE: image,
      SCANS: scans,
      KVP: kvpValue,
      MAS: masValues[masIndex]
    });
    exposeSound();
  }
}

class ControlPanelMobile extends StatelessWidget {
  final Images image;
  final player = AudioCache();
  final XRayScans scans;
  final int kvp;
  final num mas;
  StreamController<int> _controller = StreamController<int>();

  //constructor
  ControlPanelMobile(
      {required this.image,
      required this.scans,
      required this.kvp,
      required this.mas});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                    top: 20.h,
                    right: 25.w,
                    child: ExposureLogo(exposureReady: true)),
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 50.h,
                      width: 200.w,
                      child: Center(
                        child: NeumorphicText(
                          scans.description.viewType + ' ' + scans.bodyPart,
                          style: NeumorphicStyle(
                              color: Colors.black, depth: 2, intensity: 10),
                          textStyle: NeumorphicTextStyle(
                              fontSize: 30, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: height,
                    child: FractionallySizedBox(
                      heightFactor: 0.9,
                      widthFactor: 0.9,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(padding: EdgeInsets.only(top: 45.h)),
                          Padding(
                            padding: EdgeInsets.all(8.0.h),
                            child: Center(
                              child: XrayImageMobile(
                                filePath: image.filePath,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0.h),
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                  boxShape: NeumorphicBoxShape.rect(),
                                  shape: NeumorphicShape.convex,
                                  depth: 5,
                                  color: NeumorphicColors.darkBackground),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          'kVp',
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              color: Colors.white),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(top: 20)),
                                        Text(
                                          kvp.toString(),
                                          style: TextStyle(
                                              fontFamily: 'Calculator',
                                              fontSize: 50.sp,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "mAs",
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              color: Colors.white),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(top: 20)),
                                        Text(mas.toString(),
                                            style: TextStyle(
                                                fontFamily: 'Calculator',
                                                fontSize: 50.sp,
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 45.h))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          BackButton(
            isPhone: true,
          ),
          InformationButtonMobile(
            scans: scans,
            image: image,
            isPhone: true,
            stream: _controller.stream,
          ),
        ],
      ),
    );
  }

  void clickSound() {
    player.play('click.mp3');
  }
}

class TabletHandleOrientation extends StatelessWidget {
  final Widget logo;
  final Widget image;
  final Widget controls;
  final Widget title;

  TabletHandleOrientation({
    required this.logo,
    required this.image,
    required this.title,
    required this.controls,
  });

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        if (isPortrait) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: title,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 25, 45, 0),
                        child: logo,
                      )
                    ],
                  ),
                ],
              ),
              Expanded(child: image),
              controls,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: title,
                    )
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 25, 40, 0),
                    child: logo,
                  )
                ])
              ],
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(flex: 4, child: controls),
                  Flexible(flex: 4, child: image),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class Kvp extends StatelessWidget {
  static final Key upButtonKey = Key('KvpUpButton');
  static final Key downButtonKey = Key('KvpDownButton');
  final int kvpValue;
  final Function kvpUp, kvpDown;
  final bool isPhone;
  final bool isLandscape;

  Kvp(
      {required this.kvpValue,
      required this.kvpUp,
      required this.kvpDown,
      required this.isPhone,
      required this.isLandscape});

  @override
  Widget build(BuildContext context) {
    double labelSize = 20.sp;
    double size = 60.sp;

    if (isPhone) {
      labelSize = 22.sp;
      size = 70.sp;
    } else {
      if (isLandscape) {
        labelSize = 27.sp;
        size = 80.sp;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'kVp',
            style: TextStyle(fontSize: labelSize),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          Text(
            kvpValue.toString(),
            style: TextStyle(fontFamily: 'Calculator', fontSize: size),
          ),
          Hold(
              key: Kvp.upButtonKey,
              callbackFunc: kvpUp,
              icon: Icon(Icons.arrow_drop_up, size: size),
              colour: Colors.white,
              shape: null,
              speed: 90,
              surfaceIntensity: 0.25,
              tapEnabled: true),
          Padding(padding: EdgeInsets.only(top: 25)),
          Hold(
              key: Kvp.downButtonKey,
              callbackFunc: kvpDown,
              icon: Icon(Icons.arrow_drop_down, size: size),
              colour: Colors.white,
              shape: null,
              speed: 90,
              surfaceIntensity: 0.25,
              tapEnabled: true),
        ],
      ),
    );
  }
}

class Mas extends StatelessWidget {
  static final Key upButtonKey = Key('MasUpButton');
  static final Key downButtonKey = Key('MasDownButton');
  final num masValue;
  final Function masUp, masDown;
  final bool isPhone;
  final bool isLandscape;

  Mas(
      {required this.masValue,
      required this.masUp,
      required this.masDown,
      required this.isPhone,
      required this.isLandscape});

  @override
  Widget build(BuildContext context) {
    double labelSize = 20.sp;
    double size = 60.sp;

    if (isPhone) {
      labelSize = 22.sp;
      size = 70.sp;
    } else {
      if (isLandscape) {
        labelSize = 27.sp;
        size = 80.sp;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "mAs",
            style: TextStyle(fontSize: labelSize),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          Text(masValue.toString(),
              style: TextStyle(fontFamily: 'Calculator', fontSize: size)),
          Hold(
              key: Mas.upButtonKey,
              callbackFunc: masUp,
              icon: Icon(Icons.arrow_drop_up, size: size),
              colour: Colors.white,
              shape: null,
              speed: 100,
              surfaceIntensity: 0.25,
              tapEnabled: true),
          Padding(padding: EdgeInsets.only(top: 25)),
          Hold(
            key: Mas.downButtonKey,
            callbackFunc: masDown,
            icon: Icon(Icons.arrow_drop_down, size: size),
            colour: Colors.white,
            shape: null,
            speed: 100,
            surfaceIntensity: 0.25,
            tapEnabled: true,
          ),
        ],
      ),
    );
  }
}

class ExposeButton extends StatelessWidget {
  final Function expose;

  ExposeButton({required this.expose});

  @override
  Widget build(BuildContext context) {
    return Hold(
      key: Key('ExposeButton'),
      callbackFunc: expose,
      icon: Icon(
        FontAwesome5.radiation,
        size: 160,
      ),
      colour: Color(0xffFFEA08),
      shape: NeumorphicBoxShape.circle(),
      speed: 200,
      surfaceIntensity: 0.9,
      tapEnabled: false,
    );
  }
}

class BackButton extends StatelessWidget {
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

    return Positioned(
      bottom: bottom,
      left: left,
      child: Container(
        height: height,
        child: NeumorphicButton(
            style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(),
                shape: NeumorphicShape.flat,
                color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.keyboard_arrow_left_sharp, size: size)),
      ),
    );
  }
}

class InformationButtonMobile extends StatefulWidget {
  final XRayScans scans;
  final Images? image;
  final bool isPhone;
  final Stream<int> stream;

  InformationButtonMobile(
      {required this.scans,
      required this.image,
      required this.isPhone,
      required this.stream});

  @override
  _InformationButtonMobileState createState() => _InformationButtonMobileState(
        scans: scans,
        isPhone: isPhone,
      );
}

class _InformationButtonMobileState extends State<InformationButtonMobile> {
  final XRayScans scans;
  final bool isPhone;

  static final _infoTooltip = new GlobalKey();

  _InformationButtonMobileState({
    required this.scans,
    required this.isPhone,
  });

  @override
  void initState() {
    super.initState();
    if (isPhone) {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        final dynamic tooltip = _infoTooltip.currentState;
        // Flutter get callback here when screen initialized.
        tooltip.ensureTooltipVisible();

        Timer(Duration(milliseconds: 1250), () {
          tooltip.deactivate();
        });
      });
    } else {
      widget.stream.listen((event) {
        Timer(Duration(milliseconds: 650), () {
          _updateTooltip();
        });
      });
    }
  }

  void _updateTooltip() {
    final dynamic tooltip = _infoTooltip.currentState;
    // Flutter get callback here when screen initialized.
    tooltip.ensureTooltipVisible();
    Timer(Duration(milliseconds: 1250), () {
      tooltip.deactivate();
    });
  }

  @override
  Widget build(BuildContext context) {
    double bottom = 30;
    double right = 45;
    double height = 130;
    double? size = 50;
    double arrowPos = -8;
    if (isPhone) {
      bottom = 20;
      right = 15;
      height = 60;
      size = null;
      arrowPos = 24;
    }

    return Positioned(
      bottom: bottom,
      right: right,
      child: Container(
        height: height,
        child: Tooltip(
          preferBelow: false,
          decoration: ShapeDecoration(
            color: NeumorphicColors.darkBackground,
            shape: TooltipShapeBorder(arrowArc: 0.5, arrowPos: arrowPos),
          ),
          key: _infoTooltip,
          message: "Check exposure",
          child: NeumorphicButton(
              style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  color: Colors.white,
                  boxShape: NeumorphicBoxShape.circle()),
              onPressed: () {
                _showMyDialog(context);
              },
              child: Icon(Octicons.info, size: size)),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        Widget message = RichText(
            text: new TextSpan(
              style: TextStyle(
                fontSize: 14.0.sp,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: 'TYPE: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                TextSpan(text: scans.description.viewType + ' ' + scans.bodyPart),
                TextSpan(
                    text: '\nAGE: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                TextSpan(
                    text: scans.description.age.toString() +
                        ' (' +
                        scans.description.ageRange +
                        ')'),
                TextSpan(
                    text: '\nSID: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                TextSpan(text: scans.description.SID),
              ],
            ));


        if (widget.image != null) {
          message = RichText(
              text: new TextSpan(
                style: TextStyle(
                  fontSize: 14.0.sp,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: 'TYPE: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  TextSpan(text: scans.description.viewType + ' ' + scans.bodyPart),
                  TextSpan(
                      text: '\nAGE: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  TextSpan(
                      text: scans.description.age.toString() +
                          ' (' +
                          scans.description.ageRange +
                          ')'),
                  TextSpan(
                      text: '\nSID: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  TextSpan(text: scans.description.SID),
                  TextSpan(text: '\n\nkVp: ',style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                  TextSpan(text: widget.image!.kvpRange),
                  TextSpan(text: '\nmAs: ',style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                  TextSpan(text: widget.image!.masRange),

                ],
              ));
        }

        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: AlertDialog(

            shape: RoundedRectangleBorder(
              side: BorderSide(color: NeumorphicColors.darkBackground, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
            title: Center(child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold),)),
            content: SingleChildScrollView(
              child: message,
            ),
          ),
        );
      },
    );
  }
}

class InformationButton extends StatelessWidget {
  final XRayScans scans;
  final Images? image;
  final bool isPhone;

  InformationButton(
      {required this.scans, required this.image, required this.isPhone});

  @override
  Widget build(BuildContext context) {
    double bottom = 30;
    double right = 45;
    double height = 130;
    double? size = 50;

    if (isPhone) {
      bottom = 20;
      right = 15;
      height = 60;
      size = null;
    }

    return Positioned(
      bottom: bottom,
      right: right,
      child: Container(
        height: height,
        child: NeumorphicButton(
            style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                color: Colors.white,
                boxShape: NeumorphicBoxShape.circle()),
            onPressed: () {
              _showMyDialog(context);
            },
            child: Icon(Octicons.info, size: size)),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        Widget message = RichText(
            text: new TextSpan(
              style: TextStyle(
                fontSize: 14.0.sp,
                color: Colors.black,
              ),
          children: <TextSpan>[
            TextSpan(
                text: 'TYPE: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            TextSpan(text: scans.description.viewType + ' ' + scans.bodyPart),
            TextSpan(
                text: '\nAGE: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            TextSpan(
                text: scans.description.age.toString() +
                    ' (' +
                    scans.description.ageRange +
                    ')'),
            TextSpan(
                text: '\nSID: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            TextSpan(text: scans.description.SID),
          ],
        ));

        if (image != null) {
          message = RichText(
              text: new TextSpan(
                style: TextStyle(
                  fontSize: 14.0.sp,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: 'TYPE: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  TextSpan(text: scans.description.viewType + ' ' + scans.bodyPart),
                  TextSpan(
                      text: '\nAGE: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  TextSpan(
                      text: scans.description.age.toString() +
                          ' (' +
                          scans.description.ageRange +
                          ')'),
                  TextSpan(
                      text: '\nSID: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  TextSpan(text: scans.description.SID),
                  TextSpan(text: '\nkVp: ',style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                  TextSpan(text: image!.kvpRange),
                  TextSpan(text: '\nmAs: ',style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                  TextSpan(text: image!.masRange),

                ],
              ));
        }

        // Text('kVp: ' + image!.kvpRange),
        // Text('mAs: ' + image!.masRange),

        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                side: BorderSide(color: NeumorphicColors.darkBackground, width: 3),
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            title: Center(child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold),)),            content: SingleChildScrollView(
              child: message,
            ),
          ),
        );
      },
    );
  }
}

class ExposureLogo extends StatelessWidget {
  late final Color color;

  ExposureLogo({required bool exposureReady}) {
    color = exposureReady
        ? Color(0xff0DE71A) // green
        : Color(0xffFE3206); // red
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicIcon(
      FontAwesome5.radiation,
      size: 40,
      style: NeumorphicStyle(
        color: color,
      ),
    );
  }
}

class XrayImage extends StatelessWidget {
  final String? filePath;

  XrayImage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        alignment: Alignment.center,
        heightFactor: 0.9,
        widthFactor: 0.9,
        child: Neumorphic(
            style: NeumorphicStyle(
                depth: 15,
                color: Colors.black,
                intensity: 1,
                shape: NeumorphicShape.flat),
            // color: Colors.black,
            child: Center(
                child: filePath != null ? Image.asset(filePath!) : Text(''))),
      ),
    );
  }
}

class XrayImageMobile extends StatelessWidget {
  final String? filePath;

  XrayImageMobile({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Center(child: filePath != null ? Image.asset(filePath!) : Text(''));
  }
}

class Hold extends StatefulWidget {
  final Function callbackFunc;
  final Icon icon;
  final Color colour;
  final NeumorphicBoxShape? shape;
  final int speed;
  final double surfaceIntensity;
  final bool tapEnabled;

  //constructor
  Hold(
      {required Key key,
      required this.callbackFunc,
      required this.icon,
      required this.colour,
      required this.shape,
      required this.speed,
      required this.surfaceIntensity,
      required this.tapEnabled})
      : super(key: key);

  @override
  _HoldState createState() => _HoldState();
}

class _HoldState extends State<Hold> {
  double _depth = 5;

  int _loopCount = 0;
  bool _buttonPressed = false;
  bool _loopActive = false;

  void _increaseCounterWhilePressed() async {
    if (_loopActive) return; // check if loop is active

    _loopActive = true;
    while (_buttonPressed) {
      // do your thing
      if ((_loopCount == 0 && widget.tapEnabled) || _loopCount > 2) {
        setState(() {
          widget.callbackFunc();
          if (!widget.tapEnabled) {
            _buttonPressed = false;
            _loopCount = 0;
            _depth = 5;
          }
        });
      }
      _loopCount++;

      // wait a second
      await Future.delayed(Duration(milliseconds: widget.speed));
    }
    _loopActive = false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (details) {
          _buttonPressed = true;
          _increaseCounterWhilePressed();
          setState(() {
            _depth = 0;
          });
        },
        onPointerUp: (details) {
          _buttonPressed = false;
          _loopCount = 0;
          setState(() {
            _depth = 5;
          });
        },
        child: NeumorphicButton(
          onPressed: () {},
          style: NeumorphicStyle(
              color: widget.colour,
              boxShape: widget.shape,
              shape: NeumorphicShape.convex,
              intensity: 1,
              surfaceIntensity: widget.surfaceIntensity,
              depth: _depth),
          child: widget.icon,
        ));
  }
}
