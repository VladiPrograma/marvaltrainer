import 'package:flutter/material.dart';

import '../core/login/login_screen.dart';
import '../modules/ajustes/labels/activate_users_screen.dart';
import '../modules/ajustes/labels/change_email_screen.dart';
import '../modules/ajustes/labels/change_password_screen.dart';
import '../modules/ajustes/settings_screen.dart';
import '../modules/alta/add_users_screen.dart';
import '../modules/chat/chat_global_screen.dart';
import '../modules/chat/chat_user_screen.dart';
import '../modules/home/home_screen.dart';

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
};