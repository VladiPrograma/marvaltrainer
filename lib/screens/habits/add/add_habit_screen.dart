import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/custom_icons.dart';
import 'package:marvaltrainer/config/screen_args_data.dart';
import 'package:marvaltrainer/constants/alerts/show_dialog.dart';

import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/constants/string.dart';
import 'package:marvaltrainer/firebase/habits/model/habits.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/screens/habits/controllers/habit_controller.dart';
import 'package:marvaltrainer/screens/habits/habit_screen.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/widgets/cached_avatar_image.dart';
import 'package:marvaltrainer/widgets/marval_elevated_button.dart';
import 'package:marvaltrainer/widgets/marval_textfield.dart';
import 'package:marvaltrainer/widgets/users_selection_grid.dart';
import 'package:sizer/sizer.dart';
import '../../../constants/alerts/snack_errors.dart';
import '../../../constants/colors.dart';
import '../../../constants/theme.dart';

import '../../../utils/marval_arq.dart';
import '../../../widgets/marval_drawer.dart';

class AddHabitScreen extends StatelessWidget {
  AddHabitScreen({Key? key}) : super(key: key);
  static String routeName = '/habits/edit';
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    HabitController controller = HabitController();
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    Habit habit = args.habit!;
    controller.initialValue(context.ref, habit);

    final bool isNew = habit.id.isEmpty;
    final String title = isNew ? 'Crear Habito' : 'Editar Habito';

    void goBack(BuildContext context){
      controller.dispose(context.ref);
      removeScreens(context, HabitsScreen.routeName);
    }

    void saveHabit(Ref ref){
      controller.initialValue(ref, habit);
      controller.update(ref);
    }

    void saveNewHabit({required bool back}){
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        // Savin data in Firebase
        habitsLogic.add(habit);
        // Dispose all creators and pop pages
        if(back){
          goBack(context);
        }
      }
    }

    void updateHabit(Ref ref, {required bool back}){
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        habitsLogic.set(habit);
        back ? goBack(context) : saveHabit(ref);
      }else if(back){
        ThrowSnackbar.habitUpdateError(context);
        goBack(context);
      }
    }

    return Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        drawer: const MarvalDrawer(name: 'Habitos',),
        body: SizedBox( width: 100.w, height: 100.h,
          child: SingleChildScrollView(
            child: SafeArea(
            child: Watcher((context, ref, child) {
              return Column(
                children:<Widget> [
                  SizedBox(height: 2.h),
                  // Title
                  Row(
                      children: [
                        // Back Arrow
                        GestureDetector(
                            onTap: (){ if(controller.hasChange(context.ref)){
                                ThrowDialog.goBackWithoutSaving(
                                    context: context,
                                    onAccept: () => isNew ? saveNewHabit(back: true) : updateHabit(ref, back: true),
                                    onCancel: () => goBack(context));
                              }else{
                                goBack(context);
                              }
                            },
                            child: SizedBox(width: 20.w,
                                child: Icon(Icons.keyboard_arrow_left,
                                    color: kBlack, size: 9.w)
                            )),
                        // Title
                        Center(child: SizedBox(width: 60.w,
                            child:   TextH2(title, textAlign: TextAlign.center,))
                        ),
                        //Delete Icon
                        if(!isNew)
                          SizedBox( width: 20.w,
                            child: Watcher((context, ref, child) {
                              controller.getUpdates(ref);
                              controller.getOnChangeUpdates(ref);
                              bool hasChanges = controller.hasChange(ref);

                              if(!hasChanges) return const SizedBox.shrink();

                              return GestureDetector(
                                  onTap: () => updateHabit(context.ref, back: false),
                                  child: Icon(CustomIcons.save,
                                      color: kRed, size: 8.w));
                            }),
                          )
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
                                          initialValue: habit.label,
                                          labelText: "Nombre",
                                          onSaved: (value) => habit.label = value ?? habit.label,
                                          validator: (value){
                                            if(isNullOrEmpty(value?.trim())){ return kEmptyValue; }
                                            if(value!.length>25)    { return "{$kToLong 10";     }
                                            return null;
                                          },
                                          onChanged: (value){
                                            habit.label = value ?? '';
                                            controller.updateOnChange(context.ref);
                                          },
                                        ))),
                                SizedBox(width: 7.5.w,),
                              ]),
                          SizedBox(height: 3.h,),
                          MarvalInputTextField(
                            width: 70.w,
                            initialValue: habit.name ,
                            labelText: "Resumen",
                            onSaved: (value) => habit.name = value ?? habit.name,
                            validator: (value){
                              if(isNullOrEmpty(value)){ return kEmptyValue; }
                              if(value!.length>25)    { return "{$kToLong 25}";     }
                              return null;
                            },
                            onChanged: (value){
                              habit.name = value ?? '';
                              controller.updateOnChange(context.ref);
                            },
                          ),
                          SizedBox(height: 3.h,),
                          MarvalInputTextField(
                            width: 70.w,
                            maxLines: 6,
                            initialValue:  habit.description,
                            labelText: "Descripcion",
                            onSaved: (value) => habit.description = value ?? habit.description,
                            validator: (value){
                              if(isNullOrEmpty(value)){ return kEmptyValue; }
                              if(value!.length>1000)    { return "{$kToLong 1000";     }
                              return null;
                            },
                            onChanged: (value){
                              habit.description = value ?? '';
                              controller.updateOnChange(context.ref);
                            },
                          ),
                          SizedBox(height: 3.h,),
                        ],
                      )),
                  //USERS GRID
                  UserSelectionGrid(
                      initialValues: habit.users,
                      onTap: (value) => controller.updateUsers(ref, habit, value)
                  ),
                  //BOTON
                  Visibility(
                    visible: isNew,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 3.h),
                      child: MarvalElevatedButton(
                        'Guardar',
                        onPressed: (){
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            // Savin data in Firebase
                            habitsLogic.add(habit);
                            // Dispose all creators and pop pages
                            goBack(context);
                          }
                        },
                      ),
                    ),
                  ),
                ]);
        }))),
    ));
  }
}

