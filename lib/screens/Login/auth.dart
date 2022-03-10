import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Login screen
  Future<bool> SignInWithEmailNPassword(String email, String password) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      final User? user = result.user;

      if (user!.emailVerified) {
        return true;
      }
    } on FirebaseAuthException catch (_) {}

    return false;
  }

  // Register An Account screen
  Future<bool> RegisterNewAccount(email, password) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = result.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
    } on FirebaseAuthException catch (_) {}

    return false;
  }

  // Forgot Password screen
  Future<void> sendPasswordResetEmail(String email) async {
    auth.sendPasswordResetEmail(email: email);
  }
}

