import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/core/login/login_screen.dart';
import 'package:marvaltrainer/modules/home/home_screen.dart';
import 'package:marvaltrainer/utils/firebase/auth.dart';
import 'package:marvaltrainer/utils/marval_arq.dart';
import 'package:marvaltrainer/utils/objects/user_handler.dart';
import 'package:sizer/sizer.dart';
import 'config/firebase_options.dart';
import 'config/routes.dart';

///* @TODO Config Splash Loading Screen for Android and IOS
///* @TODO Config Image Picker for IOS
///* @TODO Open Home Screen when already logged

void main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   authUser = getCurrUser();
   runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            routes: routes,
            initialRoute: isNull(authUser) ? LoginScreen.routeName : HomeScreen.routeName,
          );
        }
    );
  }
}




