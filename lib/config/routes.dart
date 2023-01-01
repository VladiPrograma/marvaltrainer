import 'package:flutter/material.dart';
import 'package:marvaltrainer/screens/exercise/add/add_exercise_screen.dart';
import 'package:marvaltrainer/screens/exercise/add/add_image_screen.dart';
import 'package:marvaltrainer/screens/exercise/edit/edit_exercise_screen.dart';
import 'package:marvaltrainer/screens/exercise/edit/edit_image_screen.dart';
import 'package:marvaltrainer/screens/exercise/exercise_home_screen.dart';
import 'package:marvaltrainer/screens/exercise/exercise_screen.dart';
import 'package:marvaltrainer/screens/habits/add/add_habit_screen.dart';
import 'package:marvaltrainer/screens/habits/habit_screen.dart';
import 'package:marvaltrainer/screens/home/profile/profile_screen.dart';
import 'package:marvaltrainer/screens/workouts/add/add_workouts_to_train.dart';
import 'package:marvaltrainer/screens/workouts/add/edit_training_screen.dart';
import 'package:marvaltrainer/screens/workouts/training_screen.dart';

import '../screens/habits/new_habit_screen.dart';
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
  // HOME & USERS
  HomeScreen.routeName : (context) =>  const HomeScreen(),
  AddUserScreen.routeName : (context) =>  const AddUserScreen(),
  ProfileScreen.routeName : (context) =>  const ProfileScreen(),
  SeeFormScreen.routeName : (context) =>  const SeeFormScreen(),
  // CHAT
  ChatGlobalScreen.routeName : (context) =>  const ChatGlobalScreen(),
  ChatScreen.routeName : (context) =>  const ChatScreen(),
  // SETTINGS
  SettingScreen.routeName : (context) =>  const SettingScreen(),
  ResetPasswordScreen.routeName : (context) =>  const ResetPasswordScreen(),
  ResetEmailScreen.routeName : (context) =>  const ResetEmailScreen(),
  ActivateUserScreen.routeName : (context) =>  const ActivateUserScreen(),
  // HABITS
  HabitsScreen.routeName : (context) =>  const HabitsScreen(),
  AddHabitScreen.routeName : (context) =>  AddHabitScreen(),
  // EXERCISES
  NewExerciseScreen.routeName : (context) =>  NewExerciseScreen(),
  AddImageToExerciseScreen.routeName : (context) => const AddImageToExerciseScreen(),
  EditExerciseScreen.routeName : (context) =>  EditExerciseScreen(),
  EditImageToExerciseScreen.routeName : (context) => const EditImageToExerciseScreen(),
  ExerciseHomeScreen.routeName : (context) =>  const ExerciseHomeScreen(),
  ExerciseScreen.routeName : (context) => const ExerciseScreen(),
  // WORKOUTS
  AddWorkoutToTrain.routeName : (context) => const AddWorkoutToTrain(),
  TrainingScreen.routeName : (context) => const TrainingScreen(),
  EditTrainingScreen.routeName : (context) =>  EditTrainingScreen(),
};

