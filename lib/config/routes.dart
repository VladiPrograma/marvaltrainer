import 'package:flutter/material.dart';
import '../screens/habits/habits_screen_global.dart';
import '../screens/home/profile/journal/see_form_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/settings/labels/activate_users_screen.dart';
import '../screens/settings/labels/change_email_screen.dart';
import '../screens/settings/labels/change_password_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/alta/add_users_screen.dart';
import '../screens/chat/chat_global_screen.dart';
import '../screens/chat/chat_user_screen.dart';
import '../screens/home/home_screen.dart';

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
  SeeFormScreen.routeName : (context) =>  SeeFormScreen(),
  HabitsScreenGlobal.routeName : (context) =>  HabitsScreenGlobal(),
};