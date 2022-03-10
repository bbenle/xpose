import 'package:flutter_test/flutter_test.dart';
import 'package:x_ray_simulator/screens/Login/validate.dart';

void main() {

  //Tests to check login error messages
  group('Validate - Login error messages', () {
    testLoginEmpty();

    test("if email doesn't contain curtin.edu.au", () {
      String? result = loginErrMsgs("email", "password");
      expect(result, 'Email format is incorrect', reason: 'Fault: Wrong output');
    });

    test("if email and password don't match", () {
      String? result = loginErrMsgs("email@student.curtin.edu.au", "password");
      expect(result, 'Email or Password is incorrect', reason: 'Fault: Wrong output');
    });
  });

  //Tests to check register error messages
  group('Validate - Register error messages', () {
    testRegisterEmpty();

    test("if email doesn't contain curtin.edu.au", () {
      String? result = registerErrMsgs("email", "password", "password", "aksdjl");
      expect(result, 'Email format is incorrect', reason: 'Fault: Wrong output');
    });

    test("if passwords do not match", () {
      String? result = registerErrMsgs("email@student.curtin.edu.au", "passwordA", "passwordB", "aksdjl");
      expect(result, 'Passwords do not match', reason: 'Fault: Wrong output');
    });

    test("if password length is less than 6", () {
      String? result = registerErrMsgs("email@student.curtin.edu.au", "one", "one", "aksdjl");
      expect(result, 'Password is too short. Minimum 6 characters', reason: 'Fault: Wrong output');
    });

    test("if activation code is wrong", () {
      String? result = registerErrMsgs("email@student.curtin.edu.au", "PasswordOne", "PasswordOne", "aksdjl");
      expect(result, 'Activation code doesn\'t match', reason: 'Fault: Wrong output');
    });
    
  });

  //tests to check email error messages
  group('Validate - Reset email error messages', (){
    test("if email is empty", () {
      String? result = resetErrMsgs("");
      expect(result, 'Email field is empty', reason: 'Fault: Wrong output');
    });

    test("if email has curtin.edu.au", () {
      String? result = resetErrMsgs("email");
      expect(result, 'Not a valid email', reason: 'Fault: Wrong output');
    });

  });

  //tests to check email error messages
  group('Validate - Register email validation', (){
    test("if passwords do not match", () {
      int result = registerEmailValidation("password1", "password2","email@curtin.edu.au","bcdj");
      expect(result, 0, reason: 'Fault: Wrong output');
    });

    test("if email is invalid", () {
      int result = registerEmailValidation("password1", "password1","email","bcdj");
      expect(result, 0, reason: 'Fault: Wrong output');
    });

    test("if activation code is invalid", () {
      int result = registerEmailValidation("password1", "password1","email@curtin.edu.au","sadasd");
      expect(result, 0, reason: 'Fault: Wrong output');
    });

    test("everything is valid", () {
      int result = registerEmailValidation("password1", "password1","email@curtin.edu.au","bcdj");
      expect(result, 1, reason: 'Fault: Wrong output');
    });



  });
}

//tests to check if strings are empty
void testLoginEmpty() {
  test('if both strings are empty', () {
    String? result = loginErrMsgs("", "");
    expect(result, 'Please fill out the form', reason: 'Fault: Wrong output');
  }); //test 1

  test('if email string is empty', () {
    String? result = loginErrMsgs("", "password");
    expect(result, 'Please fill out the form', reason: 'Fault: Wrong output');
  }); //test 2

  test('if password string is empty', () {
    String? result = loginErrMsgs("email", "");
    expect(result, 'Please fill out the form', reason: 'Fault: Wrong output');
  }); //test 3
}

void testRegisterEmpty()
{
  String text = "random text";
  test('if all strings are empty', () {
    String? result = registerErrMsgs("", "", "", "");
    expect(result, 'Please fill in the form', reason: 'Fault: Wrong output');
  }); //test 1

  test('if email string is empty', () {
    String? result = registerErrMsgs("", text, text, text);
    expect(result, 'Please fill in the form', reason: 'Fault: Wrong output');
  }); //test 2

  test('if passwordOne string is empty', () {
    String? result = registerErrMsgs(text, "", text, text);
    expect(result, 'Please fill in the form', reason: 'Fault: Wrong output');
  }); //test 3

  test('if passwordTwo string is empty', () {
    String? result = registerErrMsgs(text, text, "", text);
    expect(result, 'Please fill in the form', reason: 'Fault: Wrong output');
  }); //test 4

  test('if activationCode string is empty', () {
    String? result = registerErrMsgs(text, text, text, "");
    expect(result, 'Please fill in the form', reason: 'Fault: Wrong output');
  }); //test 5

}