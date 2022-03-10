import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:x_ray_simulator/Models/Data.dart';
import 'package:x_ray_simulator/main.dart';
import 'package:x_ray_simulator/screens/Login/auth.dart';
import 'package:x_ray_simulator/screens/Login/login.dart';
import 'package:x_ray_simulator/screens/Login/register.dart';
import 'package:x_ray_simulator/screens/Login/reset.dart';
import 'package:x_ray_simulator/screens/Main%20Menu/main_menu.dart';

import 'login_test.mocks.dart';

@GenerateMocks([Auth])
void main() {
  MockAuth mockAuth = MockAuth();
  bool isPhone = true;

  Login login = Login(
    authHandler: mockAuth,
    isPhone: isPhone,
  );

  RouteFactory _routeFactory() {
    return (settings) {
      Widget screen;
      switch (settings.name) {
        case RegisterRoute:
          screen = Register(
            authHandler: mockAuth,
            isPhone: isPhone,
          );
          break;
        case ResetRoute:
          screen = Reset(
            authHandler: mockAuth,
            isPhone: isPhone,
          );
          break;
        case MainMenuRoute:
          screen = MainMenu(scansList: Data().listOfScans, isPhone: isPhone,);
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
          home: login,
          onGenerateRoute: _routeFactory(),
        ),
      );

  /*****************************************************************
   ************             Tests start here             ***********
   *****************************************************************/

  group('Login - credentials', () {
    testWidgets('Valid credentials', (WidgetTester tester) async {
      final testEmail = 'test@email.com';
      final testPassword = 'password';
      when(mockAuth.SignInWithEmailNPassword(testEmail, testPassword)).thenAnswer((_) async => true);

      await tester.pumpWidget(app);

      await tester.enterText(find.byKey(LoginForm.emailTextFieldKey), testEmail);
      await tester.enterText(find.byKey(LoginForm.passwordTextFieldKey), testPassword);

      await tester.tap(find.byKey(LoginForm.loginButtonKey));
      await tester.pumpAndSettle();

      expect(
          find.byType(MainMenu), findsOneWidget); //Should be at MainMenu screen
    });

    testWidgets('Invalid credentials', (WidgetTester tester) async {
      final testEmail = 'test@email.com';
      final testPassword = 'password';
      when(mockAuth.SignInWithEmailNPassword(testEmail, testPassword)).thenAnswer((_) async => false);

      await tester.pumpWidget(app);

      await tester.enterText(find.byKey(LoginForm.emailTextFieldKey), testEmail);
      await tester.enterText(find.byKey(LoginForm.passwordTextFieldKey), testPassword);


      await tester.tap(find.byKey(LoginForm.loginButtonKey));
      await tester.pumpAndSettle();

      expect(
          find.byKey(LoginForm.popupKey), findsOneWidget); //Should have popup
    });

    testWidgets('No credentials', (WidgetTester tester) async {
      final testEmail = '';
      final testPassword = '';
      when(mockAuth.SignInWithEmailNPassword(testEmail, testPassword)).thenAnswer((_) async => false);

      await tester.pumpWidget(app);

      await tester.tap(find.byKey(LoginForm.loginButtonKey));
      await tester.pumpAndSettle();

      expect(
          find.byKey(LoginForm.popupKey), findsOneWidget); //Should have popup
    });
  });

  group('Login - Navigate to other Login screens', () {
    testWidgets('Should navigate to Register', (WidgetTester tester) async {
      await tester.pumpWidget(app);

      await tester.tap(find.byKey(AlternateOptions.registerButtonKey));
      await tester.pumpAndSettle();

      expect(
          find.byType(Register), findsOneWidget); //Should be at Register screen
    });

    testWidgets('Should navigate to Reset', (WidgetTester tester) async {
      await tester.pumpWidget(app);

      await tester.tap(find.byKey(AlternateOptions.resetButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(Reset), findsOneWidget); //Should be at Reset screen
    });
  });
}
