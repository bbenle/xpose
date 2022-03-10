import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:x_ray_simulator/screens/Control Panel/control_panel.dart';
import 'package:x_ray_simulator/screens/Login/admin_page.dart';
import 'package:x_ray_simulator/screens/Login/auth.dart';
import 'package:x_ray_simulator/screens/Login/register.dart';
import 'package:x_ray_simulator/screens/Login/reset.dart';
import 'package:x_ray_simulator/screens/Main Menu/main_menu.dart';
import 'package:flutter/services.dart';
import 'Models/Data.dart';
import 'screens/Login/login.dart';

/*...              '/' will be first screen  ...*/
const LoginRoute = '/';
const AdminPageRoute = '/admin_page';
const RegisterRoute = '/register';
const ResetRoute = '/reset';
const MainMenuRoute = '/main_menu';
const ControlPanelRoute = '/control_panel';
const ControlPanelMobileRoute = '/control_panel_mobile';

const SCANS = 'scans';
const IMAGE = 'image';

const KVP = 'kvp';
const MAS = 'mas';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Future<void> orientationFuture = empty(), overlaysFuture = empty();
  if (Device.get().isPhone) {
    orientationFuture =
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  if (Device.get().isAndroid) {
    overlaysFuture = SystemChrome.setEnabledSystemUIOverlays(
        []); //Empty so no overlays displayed(top or bottom)
  }
  runApp(App(
      firebaseApp: Firebase.initializeApp(),
      isPhone: Device.get().isPhone,
      systemFutures: Future.wait([orientationFuture, overlaysFuture])));
}

Future<void> empty() async {}

class App extends StatelessWidget {
  final Data data = Data();
  final Future<FirebaseApp> firebaseApp;
  final bool isPhone;
  final Future<List<dynamic>> systemFutures;

  App({required this.firebaseApp, required this.isPhone, required this.systemFutures});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: ScreenUtil.defaultSize,
      builder: () => MaterialApp(
        onGenerateRoute: _routeFactory(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  RouteFactory _routeFactory() {
    return (settings) {
      final Map<String, dynamic>? arguments =
          settings.arguments as Map<String, dynamic>?;
      Widget screen;
      switch (settings.name) {
        case LoginRoute:
          screen = FutureBuilder(
            future: Future.wait([firebaseApp, systemFutures]),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                return Login(
                  authHandler: Auth(),
                  isPhone: isPhone,
                );
              } else {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          );
          break;
        case AdminPageRoute:
          screen = AdminPage(isPhone: isPhone,);
          break;
        case RegisterRoute:
          screen = Register(
            authHandler: Auth(),
            isPhone: isPhone,
          );
          break;
        case ResetRoute:
          screen = Reset(
            authHandler: Auth(),
            isPhone: isPhone,
          );
          break;
        case MainMenuRoute:
          screen = MainMenu(
            scansList: data.listOfScans,
            isPhone: isPhone,
          );
          break;
        case ControlPanelRoute:
          screen = ControlPanel(
            scans: arguments?[SCANS],
            isPhone: isPhone,
          );
          break;
        case ControlPanelMobileRoute:
          // returning PageTransition rather than MaterialPageRoute
          return PageTransition(
              type: PageTransitionType.fade,
              child: ControlPanelMobile(
                  image: arguments?[IMAGE], scans: arguments?[SCANS], kvp: arguments?[KVP], mas: arguments?[MAS]));
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }
}
