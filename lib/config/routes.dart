import 'package:flutter/material.dart';
import 'package:marvaltrainer/screens/home/profile/profile_screen.dart';

import '../screens/habits/habit_screen.dart';
import '../screens/habits/new_habit_screen.dart';
import '../screens/habits/habits_screen_global.dart';
import '../screens/home/alta/add_users_screen.dart';
import '../screens/settings/labels/activate_users_screen.dart';
import '../screens/settings/labels/change_password_screen.dart';
import '../screens/settings/labels/change_email_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/home/profile/journal/see_form_screen.dart';
import '../screens/chat/chat_global_screen.dart';
import '../screens/chat/chat_user_screen.dart';
import '../screens/home/home_screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName : (context) =>  const LoginScreen(),
  HomeScreen.routeName : (context) =>  const HomeScreen(),
  ProfileScreen.routeName : (context) =>  const ProfileScreen(),
  AddUserScreen.routeName : (context) =>  const AddUserScreen(),
  ChatGlobalScreen.routeName : (context) =>  const ChatGlobalScreen(),
  ChatScreen.routeName : (context) =>  const ChatScreen(),
  SettingScreen.routeName : (context) =>  const SettingScreen(),
  ResetPasswordScreen.routeName : (context) =>  const ResetPasswordScreen(),
  ResetEmailScreen.routeName : (context) =>  const ResetEmailScreen(),
  ActivateUserScreen.routeName : (context) =>  const ActivateUserScreen(),
  SeeFormScreen.routeName : (context) =>  const SeeFormScreen(),
  HabitsScreenGlobal.routeName : (context) =>  const HabitsScreenGlobal(),
  NewHabitScreen.routeName : (context) =>  NewHabitScreen(),
  HabitScreen.routeName : (context) =>  HabitScreen(),
};

