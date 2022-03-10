import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as Material;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:x_ray_simulator/screens/Login/Widgets/back_button.dart';
import 'package:x_ray_simulator/screens/Login/auth.dart';
import 'package:x_ray_simulator/screens/Login/reset.dart';
import 'login_test.mocks.dart';

@GenerateMocks([Auth])
void main() {
  MockAuth mockAuth = MockAuth();
  bool isPhone = true;

  Reset reset = Reset(
    authHandler: mockAuth,
    isPhone: isPhone,
  );

  final app = ScreenUtilInit(
    designSize: Size(1284, 2778),
    builder: () => Material.MaterialApp(
      home: reset,
    ),
  );

  /*****************************************************************
   ************             Tests start here             ***********
   *****************************************************************/

  group('Reset - credentials', () {
    testWidgets(
      'Valid credentials',
          (WidgetTester tester) async {
        final testEmail = 'test@student.curtin.edu.au';

        when(mockAuth.sendPasswordResetEmail(testEmail))
            .thenAnswer((_) async {});

        await tester.pumpWidget(app);

        await tester.enterText(
            find.byKey(ResetForm.emailTextFieldKey), testEmail);

        await tester.tap(find.byKey(ResetForm.resetButtonKey));

        await tester.pumpAndSettle();

        expect(find.byKey(ResetForm.validPopupKey),
            findsOneWidget);
      },
    );

    testWidgets('Invalid credentials', (WidgetTester tester) async {
      final testEmail = 'test@email.com';
      when(mockAuth.sendPasswordResetEmail(testEmail))
          .thenAnswer((_) async {});

      await tester.pumpWidget(app);

      await tester.enterText(
          find.byKey(ResetForm.emailTextFieldKey), testEmail);

      await tester.tap(find.byKey(ResetForm.resetButtonKey));

      await tester.pumpAndSettle();

      expect(find.byKey(ResetForm.errorPopupKey),
          findsOneWidget);
    });

    testWidgets('No credentials', (WidgetTester tester) async {
      final testEmail = '';
      when(mockAuth.sendPasswordResetEmail(testEmail))
          .thenAnswer((_) async {});

      await tester.pumpWidget(app);

      await tester.enterText(
          find.byKey(ResetForm.emailTextFieldKey), testEmail);

      await tester.tap(find.byKey(ResetForm.resetButtonKey));

      await tester.pumpAndSettle();

      expect(find.byKey(ResetForm.errorPopupKey),
          findsOneWidget);
    });
  });

  group(
    'Reset - testing back button',
        () {
      testWidgets('Should not be reset screen', (WidgetTester tester) async {
        await tester.pumpWidget(app);

        await tester.tap(find.byKey(BackButton.backButtonKey));
        await tester.pumpAndSettle();

        expect(find.byType(Reset), findsNothing); //Should not be register
      });
    },
  );
}
