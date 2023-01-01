import 'dart:ui';
import 'package:marvaltrainer/constants/alerts/show_dialog.dart';
import 'package:marvaltrainer/constants/alerts/snack_errors.dart';
import 'package:marvaltrainer/firebase/trainings/logic/training_logic.dart';
import 'package:sizer/sizer.dart';
import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/custom_icons.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/config/screen_args_data.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/constants/string.dart';
import 'package:marvaltrainer/firebase/trainings/model/training.dart';
import 'package:marvaltrainer/screens/workouts/add/add_workouts_to_train.dart';
import 'package:marvaltrainer/screens/workouts/controllers/training_controller.dart';
import 'package:marvaltrainer/screens/workouts/training_screen.dart';
import 'package:marvaltrainer/widgets/marval_elevated_button.dart';
import 'package:marvaltrainer/widgets/marval_textfield.dart';
import 'package:marvaltrainer/widgets/users_selection_grid.dart';
import 'package:marvaltrainer/constants/colors.dart';
import 'package:marvaltrainer/constants/theme.dart';
import 'package:marvaltrainer/firebase/trainings/model/workout.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/widgets/inner_border.dart';
import 'package:marvaltrainer/widgets/marval_drawer.dart';

class EditTrainingScreen extends StatelessWidget {
  EditTrainingScreen({Key? key}) : super(key: key);
  static String routeName= '/workouts/edit';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TrainingController controller = TrainingController();
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    Training training = args.training!;
    controller.initialValue(context.ref, training);

    final bool isNew = training.id.isEmpty;
    final String title = isNew ? 'Crear Entrenamiento' : 'Editar Entrenamiento';

    void goBack(BuildContext context){
      controller.dispose(context.ref);
      removeScreens(context, TrainingScreen.routeName);
    }

    void saveTraining(Ref ref){
      controller.initialValue(ref, training);
      controller.update(ref);
    }

    void saveNewTraining({required bool back}){
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        // Savin data in Firebase
        trainingLogic.add(training);
        // Dispose all creators and pop pages
        if(back){
          goBack(context);
        }
      }
    }

    void updateTraining(Ref ref, {required bool back}){
      if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          trainingLogic.set(training);
          back ? goBack(context) : saveTraining(ref);
      }else if(back){
        ThrowSnackbar.trainingUpdateError(context);
        goBack(context);
      }
    }

    return Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        drawer: const MarvalDrawer(name: 'Entrenos',),
        body: SizedBox( width: 100.w, height: 100.h,
          child: SingleChildScrollView(
              child: SafeArea(
                  child: Watcher((context, ref, child) {
                    return Column(
                        children:<Widget> [
                          SizedBox(height: 2.h),
                          // Title
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              // Back Arrow
                                GestureDetector(
                                    onTap: (){
                                      if(controller.hasChange(context.ref)){
                                        ThrowDialog.goBackWithoutSaving(
                                            context: context,
                                            training: training,
                                            onAccept: () => isNew ? saveNewTraining(back: true) : updateTraining(ref, back: true),
                                            onCancel: () => goBack(context));
                                      }else{
                                        goBack(context);
                                      }
                                    },
                                    child: SizedBox(width: 10.w,
                                        child: Icon(Icons.keyboard_arrow_left,
                                            color: kBlack, size: 9.w)
                                    )),
                                // Title
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                                  child: TextH2(title, textAlign: TextAlign.center)
                                ),
                                if(!isNew)
                                  SizedBox( width: 10.w,
                                    child: Watcher((context, ref, child) {
                                      controller.getUpdates(ref);
                                      controller.getOnChangeUpdates(ref);
                                      bool hasChanges = controller.hasChange(ref);
                                      if(!hasChanges) return const SizedBox.shrink();

                                      return GestureDetector(
                                          onTap: () => updateTraining(context.ref, back: false),
                                          child: Icon(Icons.save_rounded,
                                              color: kRed, size: 8.w));
                                    }),
                                  )
                              ]),
                          SizedBox(height: 3.h),
                          //NAME TEXTFIELD
                          Form(
                              key: _formKey,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    MarvalInputTextField( width: 70.w,
                                      labelText: "Descripción",
                                      initialValue: training.label,
                                      onChanged: (value){
                                        training.label = value ?? '';
                                        controller.updateOnChange(context.ref);
                                      },
                                      onSaved: (value) => training.label = value ?? '',
                                      validator: (value){
                                        if(value == null || value.isEmpty){
                                          return kEmptyValue;
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 3.h,),
                                    MarvalInputTextField( width: 70.w,
                                      labelText: "Nombre",
                                      initialValue: training.name,
                                      onChanged: (value){
                                        training.name = value ?? '';
                                        controller.updateOnChange(context.ref);
                                      },
                                      onSaved: (value) => training.name = value ?? '',
                                      validator: (value){
                                        if(value == null || value.isEmpty){
                                          return kEmptyValue;
                                        }
                                        return null;
                                      },
                                    ),
                                  ])),
                          SizedBox(height: 3.h,),
                          //ADD EXERCISES
                          Stack(
                              children: [
                                InnerShadow(
                                  color: Colors.black,
                                  offset: Offset(0.5.w, 0.7.h),
                                  blur: 1.5.w,
                                  child: Container( width: 95.w, height: 40.h,
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    decoration: BoxDecoration(
                                      color: kBlack,
                                      borderRadius: BorderRadius.circular(12.w),
                                    ),
                                  ),
                                ),
                                Container( width: 95.w, height: 40.h,
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.w),
                                    ),
                                    child: SizedBox(width: 100.w, height: 43.h,
                                        child:  Watcher((context, ref, child) {
                                         controller.getUpdates(ref);
                                         return _ReordeableExercises(controller: controller, training: training,);
                                        },))
                                )
                              ]),
                          SizedBox(height: 3.h,),
                        //USERS GRID
                          UserSelectionGrid(
                              initialValues: training.users,
                              onTap: (value) {
                                controller.updateUsers(ref, training, value);
                                logInfo(value);
                          }),
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
                                    trainingLogic.add(training);
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

class _ReordeableExercises extends StatefulWidget {
  const _ReordeableExercises({required this.controller, required this.training, Key? key}) : super(key: key);
  final Training training;
  final TrainingController controller;
  @override
  State<_ReordeableExercises> createState() => _ReordeableExercisesState();
}
class _ReordeableExercisesState extends State<_ReordeableExercises> {
  @override
  Widget build(BuildContext context) {

    Widget proxyDecorator( Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(0, 6, animValue)!;
          return Material(
            elevation: elevation,
            color: kBlack,
            shadowColor: kBlackSec,
            child: child,
          );
        },
        child: child,
      );
    }
    Training training = widget.training;
    return ReorderableListView(
        header: SizedBox( height: 5.h,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 14.w),
                const TextH2('Lista de Ejercicios', color: kWhite, size: 3.8,),
                SizedBox(width: 7.w),
                GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, AddWorkoutToTrain.routeName, arguments: ScreenArguments(training: training));
                    },
                    child: SizedBox( width: 7.w, child: const Icon(CustomIcons.gym, color: kGreen)))
              ]),
        ),
        proxyDecorator: proxyDecorator,
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) { newIndex -= 1; }
            widget.controller.updateWorkoutPosition(context.ref, training, newIndex, oldIndex);
          });
        },
        children:<Widget>[
          for(int index = 0; index< training.workouts.length; index+=1)
            ListTile(
                contentPadding: EdgeInsets.zero,
                key: Key('$index'),
                title: _WorkoutTile(controller: widget.controller, workout: training.workouts[index])
            )
        ]
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile({required this.controller, required this.workout, Key? key}) : super(key: key);
  final Workout workout;
  final TrainingController controller;
  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(seconds: workout.restSeconds);
    return Row(
        children: [
          SizedBox(width: 4.w,
              child: Icon(Icons.bolt, color: kWhite, size: 4.w,)
          ),
          SizedBox(width: 2.w,),
          SizedBox(width: 30.w,
            child:TextH2(workout.name.maxLength(20), color: kWhite, size: 3, ),
          ),
          SizedBox(width: 2.w,),
          SizedBox(width: 12.w,
            child:TextH2('${workout.maxReps}-${workout.minReps}', color: kWhite, size: 3,),
          ),
          SizedBox(width: 2.w,),
          SizedBox(width: 6.w,
            child:TextH2('${workout.series}', color: kWhite, size: 3),
          ),
          SizedBox(width: 2.w,),
          SizedBox(width: 18.w,
            child:TextH2(duration.printDuration(), color: kWhite, size: 3,),
          ),
          GestureDetector(
            onTap: (){
              controller.removeWorkout(context.ref, workout.exercise);
            },
            child: SizedBox(width: 4.w,
                child: Icon(Icons.cancel_outlined, color: kRed, size: 4.w,)
            ),
          ),
        ]);
  }
}

