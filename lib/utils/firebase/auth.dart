
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/log_msg.dart';

import '../../constants/string.dart';
import '../../widgets/marval_snackbar.dart';

void resetPassword(BuildContext context, String email){
  FirebaseAuth.instance.sendPasswordResetEmail(email: email)
      .then((value) {
   // MarvalSnackBar(context, SNACKTYPE.success, title: kResetPasswordSuccesTitle, subtitle: kResetPasswordSucessSubtitle);
  }).catchError((error){
    //MarvalSnackBar(context, SNACKTYPE.alert, title: kResetPasswordErrorTitle, subtitle: kResetPasswordErrorSubtitle);
  });
}

Future<String?> signIn(String email, String password) async{
  try {
    final credential = await FirebaseAuth.instance.
    signInWithEmailAndPassword(
        email: email,
        password: password
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') { return kEmail; }
    else if (e.code == 'wrong-password') { return kPassword; }
  }
  return null;
}


bool logOut() {
  bool success = false;
  FirebaseAuth.instance.signOut()
      .whenComplete(() => success =  true)
      .onError((error, stackTrace) => success = false);
  return success;
}

User? getCurrUser(){  return FirebaseAuth.instance.currentUser; }

/// Only MarvalTrainer
///@TODO Try to change this method with one more logical and clean
Future<String?> signUp(String email, String password) async{
  FirebaseApp app = await Firebase.initializeApp(
      name: 'Secondary', options: Firebase.app().options);
  try {
    UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
        .createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user!.uid;
  } on FirebaseAuthException catch (e) {
     if (e.code == 'email-already-in-use') {
      logError('The account already exists for that email.');
      return kEmailExists;
    }else{
       return 'unexpected-error';
     }
  }
}