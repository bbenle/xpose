import 'package:google_sign_in/google_sign_in.dart';

/*
  As of 05/10/2021, this is for only admins to send an activation code to
  user's email account via the team gmail account.
 */
class GoogleAuthApi {
  static final googleSignIn = GoogleSignIn(scopes: ['https://mail.google.com/']);

  static Future<GoogleSignInAccount?> signIn() async {

    if (await googleSignIn.isSignedIn()) {
      return googleSignIn.currentUser;
    }else {
      return await googleSignIn.signIn();
    }
  }

  static Future signOut() => googleSignIn.signOut();
}
