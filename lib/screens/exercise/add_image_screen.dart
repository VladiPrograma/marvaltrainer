import 'dart:collection';
import 'dart:math';

import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:marvaltrainer/config/custom_icons.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/config/screen_args_data.dart';
import 'package:marvaltrainer/constants/components.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/firebase/exercises/logic/exercise_logic.dart';
import 'package:marvaltrainer/firebase/exercises/model/exercise.dart';
import 'package:marvaltrainer/firebase/exercises/model/tags.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/utils/marval_arq.dart';
import 'package:marvaltrainer/widgets/inner_border.dart';
import 'package:sizer/sizer.dart';

import 'package:marvaltrainer/constants/string.dart';
import 'package:marvaltrainer/constants/colors.dart';
import 'package:marvaltrainer/constants/theme.dart';

import 'package:marvaltrainer/firebase/habits/model/habits.dart';

import 'package:marvaltrainer/widgets/marval_elevated_button.dart';
import 'package:marvaltrainer/widgets/marval_textfield.dart';
import 'package:marvaltrainer/widgets/marval_drawer.dart';


///@TODO Modify dialogs form admit very long descriptions without textoverflow.
class AddImageToExerciseScreen extends StatelessWidget {
  static String routeName = '/exercises/new/image';
  const AddImageToExerciseScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    Exercise exercise = args.exercise!;
    exercise.description = ' Las dominadas con agarre supino se realizan con las palmas de las manos mirando hacia uno mismo. Este tipo de variante es muy elegida por las personas que desean enfocarse en el entrenamiento de sus biceps';
    return Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        drawer: const MarvalDrawer(name: 'Ejercicios',),
        body: SizedBox( width: 100.w, height: 100.h,
          child: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                    children:<Widget> [
                      SizedBox(height: 1.h),
                      // Title
                      Row(
                          children: [
                            GestureDetector(
                                onTap: (){ Navigator.pop(context);},
                                child: SizedBox(width: 10.w,
                                    child: Icon(Icons.keyboard_arrow_left, color: kBlack, size: 9.w)
                                )),
                            Center(child: SizedBox(width: 80.w, child: const TextH2( "Añadir Imagen", textAlign: TextAlign.center,))),
                          ]),
                      SizedBox(height: 2.h),
                      //@TODO Sacarlo a un stful y permitir previsualizar la imagen en cuestion.
                      Container(width: 70.w, height: 50.h,
                        decoration: BoxDecoration(
                          color: kBlack,
                          borderRadius: BorderRadius.circular(5.w),
                          boxShadow: [kMarvalHardShadow],
                        ),
                        child: Center(child: Icon(Icons.camera, color: kWhite, size: 20.w,)),
                      ),
                      SizedBox(height: 3.h,),
                      TextH2(exercise.name, color: kBlack, size: 3.8),
                      SizedBox(width: 80.w,
                        child: Row(
                         children:[
                          Expanded(child: TextP2(exercise.description, maxLines: 10, textAlign: TextAlign.center, size: 3,))
                         ])
                      ),
                    SizedBox(height: 2.h),
                    GestureDetector(
                      onTap: (){
                        //@TODO
                      },
                      child: Container( width: 7.h, height: 7.h,
                        decoration: BoxDecoration(
                            boxShadow: [kMarvalBoxShadow],
                            borderRadius: BorderRadius.circular(100.w),
                            color: kGreen
                        ),
                        child: Icon(Icons.play_circle_outline_rounded, color: kWhite, size: 10.w,),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MarvalElevatedButton("Volver ",
                           textSize: 4,
                            onPressed: () => Navigator.of(context).pop(),
                            backgroundColor: MaterialStateColor.resolveWith((states){
                              return states.contains(MaterialState.pressed) ? kBlack : kBlack  ;
                            })
                        ),
                        MarvalElevatedButton("Guardar ",
                            textSize: 4,
                            onPressed: (){
                              //@TODO
                            },
                            backgroundColor: MaterialStateColor.resolveWith((states){
                              return states.contains(MaterialState.pressed) ? kGreenSec : kGreen  ;
                            })
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h,),
                    ]),
              )),
        ));
  }
}
