import 'dart:io';

import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marvaltrainer/config/screen_args_data.dart';
import 'package:marvaltrainer/constants/components.dart';
import 'package:marvaltrainer/firebase/exercises/model/exercise.dart';
import 'package:marvaltrainer/screens/exercise/edit/edit_exercise_screen.dart';
import 'package:marvaltrainer/widgets/cached_image.dart';
import 'package:sizer/sizer.dart';

import 'package:marvaltrainer/constants/colors.dart';
import 'package:marvaltrainer/constants/theme.dart';

import 'package:marvaltrainer/widgets/marval_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

Creator<XFile?> _fileCreator = Creator.value(null);
void setImageFile(Ref ref, XFile image) => ref.update(_fileCreator, (p0) => image);
XFile? getImageFile(Ref ref) => ref.watch(_fileCreator);

class ExerciseScreen extends StatelessWidget {
  static String routeName = '/exercise-home/view';
  const ExerciseScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    Exercise exercise = args.exercise!;

    void launchURL(String link) async{
      if(Platform.isIOS){
        if (await canLaunchUrl(Uri.parse(link))) {
          await launchUrl(Uri.parse(link));
        } else {
            throw 'Could not launch $link';
        }
      }
      else if(Platform.isAndroid){
        if (await canLaunchUrl(Uri.parse(link))) {
          await launchUrl(Uri.parse(link));
        } else {
          throw 'Could not launch $link';
        }
      }
    }

    return Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        drawer: const MarvalDrawer(name: 'Ejercicios',),
        body: SizedBox( width: 100.w, height: 100.h,
          child: SafeArea(
            child: Column(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:<Widget> [
                  // Title
                  SizedBox( width: 100.w, height: 10.h,
                    child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                              onTap: (){ Navigator.pop(context);},
                              child: SizedBox(width: 10.w,
                                  child: Icon(Icons.keyboard_arrow_left_rounded, color: kBlack, size: 8.w)
                          )),
                          TextH2(exercise.name, size: 4,),
                          GestureDetector(
                              onTap: () => Navigator.pushNamed(context, EditExerciseScreen.routeName, arguments: ScreenArguments(exercise: exercise)),
                              child: SizedBox(width: 10.w,
                                  child: Icon(Icons.edit, color: kBlack, size: 6.w)
                          )),
                        ]),
                  ),
                  //Image
                  const Spacer(),
                  SizedBox( width: 90.w, height: 40.h,
                      child: CachedImage(url: exercise.imageUrl, size: 100)),
                  //Description
                  Container( width: 80.w,
                    constraints: BoxConstraints(
                      maxHeight: 35.h
                    ),
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                       children:[
                        Expanded(child: TextP2(exercise.description, maxLines: 1000, textAlign: TextAlign.center, size: 3,))
                       ]),
                    )
                  ),
                  const Spacer(),
                  GestureDetector(
                  onTap: () =>  launchURL(exercise.link),
                  child: Container( width: 7.h, height: 7.h,
                    margin: EdgeInsets.only(bottom: 3.h, top: 1.h),
                    decoration: BoxDecoration(
                        boxShadow: [kMarvalBoxShadow],
                        borderRadius: BorderRadius.circular(100.w),
                        color: kGreen
                    ),
                    child: Icon(Icons.play_circle_outline_rounded, color: kWhite, size: 10.w,),
                  ),
                ),
                ]),
          ),
        ));
  }
}


