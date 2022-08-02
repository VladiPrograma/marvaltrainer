import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/routes.dart';
import 'config/firebase_options.dart';
import 'constants/global_variables.dart';
import 'core/login/login_screen.dart';
import 'modules/home/home_screen.dart';
import 'utils/firebase/auth.dart';
import 'utils/marval_arq.dart';

///* @TODO Config Splash Loading Screen for Android and IOS
///* @TODO Config Image Picker for IOS
///* @TODO Open Home Screen when already logged

void main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   authUser = getCurrUser();
   await handler.getFromDB();
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




