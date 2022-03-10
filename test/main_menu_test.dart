import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_ray_simulator/Models/Data.dart';
import 'package:x_ray_simulator/Models/XRayScans.dart';
import 'package:x_ray_simulator/main.dart';
import 'package:x_ray_simulator/screens/Control Panel/control_panel.dart';
import 'package:x_ray_simulator/screens/Main Menu/main_menu.dart';

void main() {
  List<XRayScans> scansList = Data().listOfScans;
  bool isPhone = true;
  MainMenu menu = MainMenu(
    scansList: scansList,
    isPhone: isPhone,
  );

  RouteFactory _routeFactory() {
    return (settings) {
      final Map<String, dynamic>? arguments =
          settings.arguments as Map<String, dynamic>?;
      Widget screen;
      switch (settings.name) {
        case ControlPanelRoute:
          screen = ControlPanel(
            scans: arguments?[SCANS],
            isPhone: isPhone,
          );
          break;
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }

  final app = ScreenUtilInit(
    designSize: ScreenUtil.defaultSize,
    builder: () => MaterialApp(
      home: menu,
      onGenerateRoute: _routeFactory(),
    ),
  );

  /*****************************************************************
   ************             Tests start here             ***********
   *****************************************************************/

  group('Main menu - different sized lists of scans', () {
    testWidgets('Standard Data', (WidgetTester tester) async {
      await tester.pumpWidget(app);

      expect(find.text(MainMenu.TITLE_MESSAGE), findsOneWidget);
      scansList.forEach((scans) {
        expect(
            find.text('TYPE: ' +
                scans.description.viewType +
                ' ' +
                scans.bodyPart.toLowerCase() +
                '\nAGE: ' +
                scans.description.age.toString() +
                '\nSID: ' +
                scans.description.SID.toString()),
            findsOneWidget);
      });
      expect(find.byType(XRayScansTile), findsNWidgets(scansList.length));
      expect(find.text(MainMenu.EMPTY_SCANS_MESSAGE), findsNothing);
    });

    testWidgets('Empty list', (WidgetTester tester) async {
      List<XRayScans> scansList = [];
      MainMenu menu = MainMenu(
        scansList: scansList,
        isPhone: isPhone,
      );
      await tester.pumpWidget(MaterialApp(home: menu));
      expect(find.text(MainMenu.TITLE_MESSAGE), findsOneWidget);
      expect(find.text(MainMenu.EMPTY_SCANS_MESSAGE), findsOneWidget);
    });
  }, skip: true);

  group('Main menu - selecting body parts', () {
    testWidgets('selecting/unselecting body part', (WidgetTester tester) async {
      await tester.pumpWidget(app);

      GoButton goButton = getGoButton(tester);
      expect(goButton.scans == null, true); //starts off null

      await tester.tap(find.byKey(
          Key(MainMenu.baseXRayScanTileKey + '0'))); //selected first body part
      await tester.pumpAndSettle();

      goButton = getGoButton(tester);
      expect(goButton.scans != null, true); //expect goButton to have some scans

      await tester.tap(find.byKey(
          Key(MainMenu.baseXRayScanTileKey + '0'))); //unselect same body part
      await tester.pumpAndSettle();

      goButton = getGoButton(tester);
      expect(goButton.scans == null, true); //reverts back to null
    });

    testWidgets('selecting body part and then another',
        (WidgetTester tester) async {
      await tester.pumpWidget(app);

      GoButton goButton = getGoButton(tester);
      expect(goButton.scans == null, true); //starts off null

      await tester.tap(find.byKey(
          Key(MainMenu.baseXRayScanTileKey + '0'))); //selected first body part
      await tester.pumpAndSettle();

      goButton = getGoButton(tester);
      expect(goButton.scans != null, true); //expect goButton to have some scans
      XRayScans? first = goButton.scans;

      await tester.tap(find.byKey(
          Key(MainMenu.baseXRayScanTileKey + '1'))); //select second body part
      await tester.pumpAndSettle();

      goButton = getGoButton(tester);
      expect(goButton.scans != first,
          true); //expect goButton to have second scans, not first
    });
  });

  group('Main menu - navigating to Control Panel', () {
    testWidgets('tapping GoButton with no selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(app);

      await tester.tap(find.byKey(MainMenu.goButtonKey), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(ControlPanel),
          findsNothing); //Should not be at ControlPanel
    });

    Data().listOfScans.asMap().forEach((index, scans) {
      testWidgets('selecting scans $index then tapping GoButton',
          (WidgetTester tester) async {
        await tester.pumpWidget(app);

        await tester.tap(find.byKey(Key(MainMenu.baseXRayScanTileKey +
            index.toString()))); //select scans at index
        await tester.pumpAndSettle();

        GoButton goButton = getGoButton(tester);
        XRayScans? selectedScans = goButton.scans;

        await tester.tap(find.byKey(MainMenu.goButtonKey));
        await tester.pumpAndSettle();

        expect(find.byType(ControlPanel),
            findsOneWidget); //Should be at ControlPanel

        expect(getControlPanel(tester).scans,
            selectedScans); //confirm scans are sent as arguments
      });
    });
  });

  group('Main Menu - highlight selected body part', () {
    testWidgets('selecting/unselecting body part', (WidgetTester tester) async {
      await tester.pumpWidget(app);

      XRayScansTile xRayScansTile = getXRayScanTile(tester, 0);
      expect(xRayScansTile.color, Colors.white); //starts off white

      await tester.tap(find.byKey(
          Key(MainMenu.baseXRayScanTileKey + '0'))); //selected first body part
      await tester.pumpAndSettle();

      xRayScansTile = getXRayScanTile(tester, 0);
      expect(xRayScansTile.color, Color(0xffcfdce6)); //change color

      await tester.tap(find.byKey(
          Key(MainMenu.baseXRayScanTileKey + '0'))); //unselect same body part
      await tester.pumpAndSettle();

      xRayScansTile = getXRayScanTile(tester, 0);
      expect(xRayScansTile.color, Colors.white); //back to white
    });

    testWidgets('selecting body part and then another',
        (WidgetTester tester) async {
      await tester.pumpWidget(app);

      XRayScansTile xRayScansTile = getXRayScanTile(tester, 0);
      expect(xRayScansTile.color, Colors.white); //starts off white

      await tester.tap(find.byKey(
          Key(MainMenu.baseXRayScanTileKey + '0'))); //selected first body part
      await tester.pumpAndSettle();

      xRayScansTile = getXRayScanTile(tester, 0);
      expect(xRayScansTile.color, Color(0xffcfdce6)); //change color

      await tester.tap(find.byKey(
          Key(MainMenu.baseXRayScanTileKey + '1'))); //select second body part
      await tester.pumpAndSettle();

      xRayScansTile = getXRayScanTile(tester, 0);
      expect(xRayScansTile.color, Colors.white); //back to white
    });
  });
}

GoButton getGoButton(WidgetTester tester) {
  return tester.widget(find.byType(GoButton));
}

ControlPanel getControlPanel(WidgetTester tester) {
  return tester.widget(find.byType(ControlPanel));
}

XRayScansTile getXRayScanTile(WidgetTester tester, int index) {
  return tester
      .widget(find.byKey(Key(MainMenu.baseXRayScanTileKey + index.toString())));
}
