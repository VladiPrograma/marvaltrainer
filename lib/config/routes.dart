import 'package:flutter/material.dart';

import '../core/login/login_screen.dart';
import '../modules/alta/add_users_screen.dart';
import '../modules/home/home_screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName : (context) =>  LoginScreen(),
  HomeScreen.routeName : (context) =>  HomeScreen(),
  AddUserScreen.routeName : (context) =>  AddUserScreen(),
};