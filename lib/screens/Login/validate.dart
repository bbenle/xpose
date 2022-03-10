String? loginErrMsgs(String email, String pass) {
  if (email.isEmpty || pass.isEmpty) {
    return 'Please fill out the form';
  }

  if (!(email.contains("curtin.edu.au"))) {
    return 'Email format is incorrect';
  }

  return 'Email or Password is incorrect';
}

String? registerErrMsgs(
    String email, String passOne, String passTwo, String activationCode) {
  if (email.isEmpty ||
      passOne.isEmpty ||
      passTwo.isEmpty ||
      activationCode.isEmpty) {
    return 'Please fill in the form';
  }

  if (!(email.contains("curtin.edu.au"))) {
    return 'Email format is incorrect';
  }

  if (passOne != passTwo) {
    return 'Passwords do not match';
  }

  if (passOne.length < 6) {
    return 'Password is too short. Minimum 6 characters';
  }

  if (passTwo.length < 6) {
    return 'Password is too short. Minimum 6 characters';
  }

  if (activationCode != 'bcdj') {
    return "Activation code doesn't match";
  }
}

int registerEmailValidation(String firstPass, String secondPass,
    String emailReg, String activationCode) {
  if ((firstPass == secondPass) &&
      (emailReg.contains("curtin.edu.au")) &&
      (activationCode == 'bcdj') &&
      (firstPass.length >= 6) &&
      (secondPass.length >= 6))
    return 1;
  else
    return 0;
}

String resetErrMsgs(String email) {
  if (email.isEmpty) return 'Email field is empty';

  if (!(email.contains("curtin.edu.au"))) {
    return 'Not a valid email';
  }
  return '';
}
