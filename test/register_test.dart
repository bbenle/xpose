import 'package:flutter/material.dart' as Material;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:x_ray_simulator/screens/Login/Widgets/back_button.dart';
import 'package:x_ray_simulator/screens/Login/auth.dart';
import 'package:x_ray_simulator/screens/Login/register.dart';
import 'login_test.mocks.dart';

@GenerateMocks([Auth])
void main() {
  MockAuth mockAuth = MockAuth();
  bool isPhone = true;

  Register register = Register(
    authHandler: mockAuth,
    isPhone: isPhone,
  );

  final app = ScreenUtilInit(
    designSize: ScreenUtil.defaultSize,
    builder: () => Material.MaterialApp(
      home: register,
    ),
  );

  /*****************************************************************
   ************             Tests start here             ***********
   *****************************************************************/

  group('Register - credentials', () {
    testWidgets(
      'Valid credentials',
      (WidgetTester tester) async {
        final testEmail = 'test@student.curtin.edu.au';
        final testPasswordOne = 'password';
        final testPasswordTwo = 'password';
        final testActivationCode = 'bcdj';

        when(mockAuth.RegisterNewAccount(testEmail, testPasswordOne))
            .thenAnswer((_) async => true);

        await tester.pumpWidget(app);

        await tester.enterText(
            find.byKey(RegisterForm.emailTextFieldKey), testEmail);
        await tester.enterText(
            find.byKey(RegisterForm.passwordOneTextFieldKey), testPasswordOne);
        await tester.enterText(
            find.byKey(RegisterForm.passwordTwoTextFieldKey), testPasswordTwo);
        await tester.enterText(
            find.byKey(RegisterForm.activationCodeTextFieldKey),
            testActivationCode);
        await tester.tap(find.byKey(RegisterForm.registerButtonKey));

        await tester.pumpAndSettle();

        expect(find.byKey(RegisterForm.validPopupKey),
            findsOneWidget);
      },
    );

    testWidgets('Invalid credentials', (WidgetTester tester) async {
      final testEmail = 'test@email.com';
      final testPasswordOne = 'passwordOne';
      final testPasswordTwo = 'passwordTwo';
      final testActivationCode = 'activationCode';
      when(mockAuth.RegisterNewAccount(testEmail, testPasswordOne))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(app);

      await tester.enterText(
          find.byKey(RegisterForm.emailTextFieldKey), testEmail);
      await tester.enterText(
          find.byKey(RegisterForm.passwordOneTextFieldKey), testPasswordOne);
      await tester.enterText(
          find.byKey(RegisterForm.passwordTwoTextFieldKey), testPasswordTwo);
      await tester.enterText(
          find.byKey(RegisterForm.activationCodeTextFieldKey),
          testActivationCode);

      await tester.tap(find.byKey(RegisterForm.registerButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(RegisterForm.popupKey),
          findsOneWidget); //Should have popup
    });

    testWidgets('No credentials', (WidgetTester tester) async {
      final testEmail = '';
      final testPasswordOne = '';
      final testPasswordTwo = '';
      final testActivationCode = '';
      when(mockAuth.RegisterNewAccount(testEmail, testPasswordOne))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(app);

      await tester.enterText(
          find.byKey(RegisterForm.emailTextFieldKey), testEmail);
      await tester.enterText(
          find.byKey(RegisterForm.passwordOneTextFieldKey), testPasswordOne);
      await tester.enterText(
          find.byKey(RegisterForm.passwordTwoTextFieldKey), testPasswordTwo);
      await tester.enterText(
          find.byKey(RegisterForm.activationCodeTextFieldKey),
          testActivationCode);

      await tester.tap(find.byKey(RegisterForm.registerButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(RegisterForm.popupKey),
          findsOneWidget); //Should have popup
    });
  });

  group(
    'Register - testing back button',
    () {
      testWidgets('Should not be register screen', (WidgetTester tester) async {
        await tester.pumpWidget(app);

        await tester.tap(find.byKey(BackButton.backButtonKey));
        await tester.pumpAndSettle();

        expect(find.byType(Register), findsNothing); //Should not be register
      });
    },
  );
}
