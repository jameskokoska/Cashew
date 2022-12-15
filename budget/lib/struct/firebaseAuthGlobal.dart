import 'package:budget/widgets/accountAndBackup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_core/firebase_core.dart';

OAuthCredential? _credential;

// returns null if authentication unsuccessful
Future<FirebaseFirestore?> firebaseGetDBInstance() async {
  if (_credential != null) {
    try {
      await FirebaseAuth.instance.signInWithCredential(_credential!);

      return FirebaseFirestore.instance;
    } catch (e) {
      print("There was an error with firebase login");
      print(e.toString());
      return null;
    }
  } else {
    try {
      if (user == null) {
        signInGoogle();
      }
      GoogleSignInAccount? googleUser = user;

      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      _credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(_credential!);

      return FirebaseFirestore.instance;
    } catch (e) {
      print("There was an error with firebase login");
      print(e.toString());
      return null;
    }
  }
}
