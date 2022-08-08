
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../constants/string.dart';
import '../../widgets/marval_snackbar.dart';

void ResetPassword(BuildContext context, String email){
  FirebaseAuth.instance.sendPasswordResetEmail(email: email)
      .then((value) {
    MarvalSnackBar(context, SNACKTYPE.success, title: kResetPasswordSuccesTitle, subtitle: kResetPasswordSucessSubtitle);
  }).catchError((error){
    MarvalSnackBar(context, SNACKTYPE.alert, title: kResetPasswordErrorTitle, subtitle: kResetPasswordErrorSubtitle);
  });
}

Future<String?> SignIn(String email, String password) async{
  try {
    final credential = await FirebaseAuth.instance.
    signInWithEmailAndPassword(
        email: email,
        password: password
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') { return kInputErrorEmail; }
    else if (e.code == 'wrong-password') { return kInputErrorPassword; }
  }
  return null;
}


bool LogOut() {
  bool success = false;
   FirebaseAuth.instance.signOut()
      .whenComplete(() => success =  true)
      .onError((error, stackTrace) => success = false);
  return success;
}

User? getCurrUser(){  return FirebaseAuth.instance.currentUser; }

/// Only MarvalTrainer
///@TODO Try to change this method with one more logical and clean
Future<String?> SignUp(String email, String password) async{
  FirebaseApp app = await Firebase.initializeApp(
      name: 'Secondary', options: Firebase.app().options);
  try {
    UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
        .createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user!.uid;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {

      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }

  }
  await app.delete();
}