import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_ray_simulator/Models/Data.dart';
import 'package:x_ray_simulator/Models/XRayScans.dart';
import 'package:x_ray_simulator/main.dart';
import 'package:x_ray_simulator/screens/Control%20Panel/control_panel.dart';
import 'package:x_ray_simulator/screens/Main%20Menu/main_menu.dart';

void main() {
  XRayScans scans = Data().listOfScans[0];
  bool isPhone = true;
  ControlPanel controlPanel = ControlPanel(scans: scans, isPhone: isPhone,);

  RouteFactory _routeFactory() {
    return (settings) {
      final Map<String, dynamic>? arguments =
          settings.arguments as Map<String, dynamic>?;
      Widget screen;
      switch (settings.name) {
        case MainMenuRoute:
          screen = MainMenu(scansList: Data().listOfScans, isPhone: isPhone,);
          break;
        case ControlPanelRoute:
          screen = ControlPanel(scans: arguments?[SCANS], isPhone: isPhone,);
          break;
        case ControlPanelMobileRoute:
          screen = ControlPanelMobile(
              image: arguments?[IMAGE], scans: arguments?[SCANS], kvp: arguments?[KVP], mas: arguments?[MAS]);
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
      home: controlPanel,
      onGenerateRoute: _routeFactory(),
    ),
  );

  /*****************************************************************
   ************             Tests start here             ***********
   *****************************************************************/

  group('Control Panel - kVp', () {
    testWidgets('kVp buttons modify kVp value', (WidgetTester tester) async {
      await tester.pumpWidget(app);

      final ControlPanelState state = tester.state(find.byType(ControlPanel));
      int startKvp = state.kvpValue;

      await tester.tap(find.byKey(Kvp.upButtonKey));
      await tester.pumpAndSettle();

      int currentKvp = state.kvpValue;
      expect(currentKvp, startKvp + 1); //Should be 1 higher than start value

      await tester.tap(find.byKey(Kvp.downButtonKey));
      await tester.pumpAndSettle();

      currentKvp = state.kvpValue;
      expect(currentKvp, startKvp); //Should now be the same value
    });

    testWidgets('kVp shouldn\'t go below min or above max',
        (WidgetTester tester) async {
      await tester.pumpWidget(app);

      final ControlPanelState state = tester.state(find.byType(ControlPanel));
      int currentKvp = state.kvpValue;

      //Lower kVp to min
      for (int i = currentKvp; i > ControlPanel.KVP_MIN; i--) {
        await tester.tap(find.byKey(Kvp.downButtonKey));
        await tester.pumpAndSettle();
      }

      currentKvp = state.kvpValue;
      expect(currentKvp, ControlPanel.KVP_MIN); //Should be at min

      await tester.tap(find.byKey(Kvp.downButtonKey));
      await tester.pumpAndSettle();

      currentKvp = state.kvpValue;
      expect(currentKvp, ControlPanel.KVP_MIN); //should still be min

      //Increase kVp to max
      for (int i = currentKvp; i < ControlPanel.KVP_MAX; i++) {
        await tester.tap(find.byKey(Kvp.upButtonKey));
        await tester.pumpAndSettle();
      }

      currentKvp = state.kvpValue;
      expect(currentKvp, ControlPanel.KVP_MAX); //Should be at max

      await tester.tap(find.byKey(Kvp.upButtonKey));
      await tester.pumpAndSettle();

      currentKvp = state.kvpValue;
      expect(currentKvp, ControlPanel.KVP_MAX); //Should still be max
    });
  });

  group('Control Panel - mAs', () {
    testWidgets('mAs buttons modify mAs value', (WidgetTester tester) async {
      await tester.pumpWidget(app);

      final ControlPanelState state = tester.state(find.byType(ControlPanel));
      num startMas = state.masValues[state.masIndex];

      await tester.tap(find.byKey(Mas.upButtonKey));
      await tester.pumpAndSettle();

      num currentMas = state.masValues[state.masIndex];
      expect(currentMas != startMas, true); //Should not be the same

      await tester.tap(find.byKey(Mas.downButtonKey));
      await tester.pumpAndSettle();

      currentMas = state.masValues[state.masIndex];
      expect(currentMas, startMas); //Should now be the same value
    });

    testWidgets('mAs shouldn\'t go below min or above max',
        (WidgetTester tester) async {
      await tester.pumpWidget(app);

      final ControlPanelState state = tester.state(find.byType(ControlPanel));
      int masIndex = state.masIndex;

      //Lower mAs to min
      for (int i = masIndex; i > 0; i--) {
        await tester.tap(find.byKey(Mas.downButtonKey));
        await tester.pumpAndSettle();
      }

      masIndex = state.masIndex;
      expect(masIndex, 0); //Should be first element of array
      expect(state.masValues[masIndex], 0.0); //Should be at min value

      await tester.tap(find.byKey(Mas.downButtonKey));
      await tester.pumpAndSettle();

      masIndex = state.masIndex;
      expect(masIndex, 0); //should still be first element of array
      expect(state.masValues[masIndex], 0.0); //Should still be min value

      final int maxMasIndex = state.masValues.length - 1;

      //Increase mAs to max
      for (int i = masIndex; i < maxMasIndex; i++) {
        await tester.tap(find.byKey(Mas.upButtonKey));
        await tester.pumpAndSettle();
      }

      masIndex = state.masIndex;
      expect(masIndex, maxMasIndex); //Should be at max index
      expect(state.masValues[masIndex], 200); //Should be at max value

      await tester.tap(find.byKey(Mas.upButtonKey));
      await tester.pumpAndSettle();

      masIndex = state.masIndex;
      expect(masIndex, maxMasIndex); //Should still be max index
      expect(state.masValues[masIndex], 200); //Should still be max value
    });
  });
}
