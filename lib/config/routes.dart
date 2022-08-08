import 'package:flutter/material.dart';
import 'package:marvaltrainer/modules/chat/chat_global_screen.dart';

import '../core/login/login_screen.dart';
import '../modules/alta/add_users_screen.dart';
import '../modules/chat/chat_user_screen.dart';
import '../modules/home/home_screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName : (context) =>  LoginScreen(),
  HomeScreen.routeName : (context) =>  HomeScreen(),
  AddUserScreen.routeName : (context) =>  AddUserScreen(),
  ChatGlobalScreen.routeName : (context) =>  ChatGlobalScreen(),
  ChatScreen.routeName : (context) =>  ChatScreen(),
};