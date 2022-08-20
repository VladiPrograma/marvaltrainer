import 'package:flutter/material.dart';
import 'package:marvaltrainer/modules/home/profile/see_form_screen.dart';

import '../core/login/login_screen.dart';
import '../modules/settings/labels/activate_users_screen.dart';
import '../modules/settings/labels/change_email_screen.dart';
import '../modules/settings/labels/change_password_screen.dart';
import '../modules/settings/settings_screen.dart';
import '../modules/alta/add_users_screen.dart';
import '../modules/chat/chat_global_screen.dart';
import '../modules/chat/chat_user_screen.dart';
import '../modules/home/home_screen.dart';
import '../modules/home/profile/profile_screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName : (context) =>  LoginScreen(),
  HomeScreen.routeName : (context) =>  HomeScreen(),
  AddUserScreen.routeName : (context) =>  AddUserScreen(),
  ChatGlobalScreen.routeName : (context) =>  ChatGlobalScreen(),
  ChatScreen.routeName : (context) =>  ChatScreen(),
  SettingScreen.routeName : (context) =>  SettingScreen(),
  ResetPasswordScreen.routeName : (context) =>  ResetPasswordScreen(),
  ResetEmailScreen.routeName : (context) =>  ResetEmailScreen(),
  ActivateUserScreen.routeName : (context) =>  ActivateUserScreen(),
  ProfileScreen.routeName : (context) =>  ProfileScreen(),
  SeeFormScreen.routeName : (context) =>  SeeFormScreen(),
};