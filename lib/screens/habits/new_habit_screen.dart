import 'package:flutter/material.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/utils/marval_arq.dart';
import 'package:sizer/sizer.dart';

import 'package:marvaltrainer/constants/string.dart';
import 'package:marvaltrainer/constants/colors.dart';
import 'package:marvaltrainer/constants/theme.dart';

import 'package:marvaltrainer/firebase/habits/model/habits.dart';

import 'package:marvaltrainer/widgets/marval_elevated_button.dart';
import 'package:marvaltrainer/widgets/marval_textfield.dart';
import 'package:marvaltrainer/widgets/marval_drawer.dart';

Habit _habit = Habit.empty();
///@TODO Modify dialogs form admit very long descriptions without textoverflow.
class NewHabitScreen extends StatelessWidget {
  static String routeName = '/habits/new';
  NewHabitScreen({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        drawer: const MarvalDrawer(name: 'Habitos',),
        body: SizedBox( width: 100.w, height: 100.h,
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children:<Widget> [
                  SizedBox(height: 2.h),
                  // Title
                  Row(
                      children: [
                        GestureDetector(
                            onTap: (){ Navigator.pop(context);},
                            child: SizedBox(width: 10.w,
                                child: Icon(Icons.keyboard_arrow_left, color: kBlack, size: 9.w)
                        )),
                        Center(child: SizedBox(width: 80.w, child: const TextH2( "Añadir Habito", textAlign: TextAlign.center,))),
                      ]),
                  SizedBox(height: 3.h),
                  Form( key: _formKey,
                      child: Column(
                        children: [
                          Row(
                              children: [
                                Align( alignment: Alignment.centerLeft,
                                    child: Padding(padding: EdgeInsets.only(left: 15.w),
                                        child: MarvalInputTextField(
                                          width: 40.w,
                                          hintText:  "Nombre",
                                          labelText: "Nombre",
                                          onSaved: (value) => _habit.label = value ?? '',
                                          validator: (value){
                                            if(isNullOrEmpty(value?.trim())){ return kEmptyValue; }
                                            if(value!.length>25)    { return "{$kToLong 10";     }
                                            if(value.getIcon().isEmpty) return 'Añade un Emoji';
                                            return null;
                                          },
                                        ))),
                                SizedBox(width: 7.5.w,),
                          ]),
                          SizedBox(height: 3.h,),
                          MarvalInputTextField(
                            width: 70.w,
                            hintText: "Titulo",
                            labelText: "Titulo",
                            onSaved: (value) => _habit.name = value ?? '',
                            validator: (value){
                              if(isNullOrEmpty(value)){ return kEmptyValue; }
                              if(value!.length>25)    { return "{$kToLong 25}";     }
                              return null;
                            },
                          ),
                          SizedBox(height: 3.h,),
                          MarvalInputTextField(
                            width: 70.w,
                            maxLines: 6,
                            hintText: "Descripcion",
                            labelText: "Descripcion",
                            onSaved: (value) => _habit.description = value ?? '',
                            validator: (value){
                              if(isNullOrEmpty(value)){ return kEmptyValue; }
                              if(value!.length>1000)    { return "{$kToLong 1000";     }
                              return null;
                            },
                          ),
                          SizedBox(height: 3.h,),
                        ],
                      )),
                  SizedBox(height: 2.h,),
                  MarvalElevatedButton("Guardar ",
                      onPressed: (){
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          habitsLogic.add(_habit);
                          _formKey.currentState!.reset();
                        }
                      },
                      backgroundColor: MaterialStateColor.resolveWith((states){
                        return states.contains(MaterialState.pressed) ? kGreenSec :  kGreen;
                      })),
                  SizedBox(height: 3.h),
                  MarvalElevatedButton("Cancelar", onPressed: (){Navigator.pop(context);},
                      backgroundColor: MaterialStateColor.resolveWith((states){
                        return states.contains(MaterialState.pressed) ? kRed :  kBlack;
                      }))
                ],
              ),
            ),
          ),
        ));
  }
}

