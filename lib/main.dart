import 'package:marvaltrainer/screens/home/home_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:creator/creator.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/routes.dart';
import 'config/firebase_options.dart';
import 'constants/global_variables.dart';
import 'screens/login/login_screen.dart';

///* @TODO Config Splash Loading Screen for Android and IOS
///* @TODO Config Image Picker for IOS
///* @TODO Normalize BoxShadows [ ]

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
   );
   runApp(CreatorGraph(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalMaterialLocalizations.delegate
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('es_ES')
            ],
            routes: routes,
            debugShowCheckedModeBanner: false,
            initialRoute:  authUserLogic.getCurrUser() == null ? LoginScreen.routeName : HomeScreen.routeName
          );
    });
  }
}




