import 'package:marvaltrainer/constants/alerts/snack_errors.dart';
import 'package:marvaltrainer/constants/firebase_constants.dart';
import 'package:marvaltrainer/firebase/authentication/model/auth_user_model.dart';
import 'package:marvaltrainer/firebase/authentication/repository/auth_user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthUserLogic{
  AuthUserRepository repo = AuthUserRepository();
  User? getCurrUser(){  return repo.get(); }

  Future<bool?> resetPassword(BuildContext context, String password, bool showSnackBar) async{
    return await repo.resetPassword(password)
           .then((value) { showSnackBar ? ThrowSnackbar.resetPaswordSuccess(context) : null ;
    }).catchError((error){ showSnackBar ? ThrowSnackbar.resetPasswordError(context)  : null ;});
  }
  Future<bool?> resetEmail(BuildContext context, String email, bool showSnackBar) async{
    return await repo.resetEmail(email)
      .then((value) {      showSnackBar ? ThrowSnackbar.resetEmailSuccess(context) : null ;
    }).catchError((error){ showSnackBar ? ThrowSnackbar.resetEmailError(context)  : null;});
  }
  Future<String?> signIn(BuildContext context, AuthUser user) async{
    return await repo.signIn(user);
  }
  bool logOut() {
    bool success = false;
    FirebaseAuth.instance.signOut()
        .whenComplete(() => success =  true)
        .onError((error, stackTrace) => success = false);
    return success;
  }

  Future<String> signUp(BuildContext context, String email, bool showSnackBar) async{
    AuthUser user = AuthUser(email: email, password: 'temporal1');
    String? response = await repo.signUp(user);
    if(showSnackBar){
    } if(response ==  firebase_auth_code['email-exists']) {
        ThrowSnackbar.signUpAlreadyLoggedError(context);
      }else if( response == firebase_auth_code['unexpected']){
        ThrowSnackbar.signUpError(context);
      } else {
        ThrowSnackbar.signUpSuccess(context);
      }
    return response;
  }
}