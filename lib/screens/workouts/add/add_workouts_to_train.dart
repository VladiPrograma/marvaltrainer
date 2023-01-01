import 'package:sizer/sizer.dart';
import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_native_splash/cli_commands.dart';

import 'package:marvaltrainer/constants/theme.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/constants/string.dart';
import 'package:marvaltrainer/constants/colors.dart';
import 'package:marvaltrainer/widgets/inner_border.dart';
import 'package:marvaltrainer/widgets/cached_image.dart';
import 'package:marvaltrainer/config/screen_args_data.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/firebase/trainings/model/workout.dart';
import 'package:marvaltrainer/firebase/exercises/model/exercise.dart';
import 'package:marvaltrainer/firebase/trainings/model/training.dart';
import 'package:marvaltrainer/screens/workouts/controllers/training_controller.dart';

ScrollController returnController(Ref ref){
  ScrollController  res = ScrollController();
  res.addListener((){ if(res.position.maxScrollExtent==res.offset){ exerciseLogic.fetchMore(ref, n: 10); }});
  return res;
}
Creator<String> _searchCreator = Creator.value('');
Creator<bool> _searchByTags = Creator.value(false);


class AddWorkoutToTrain extends StatelessWidget {
  const AddWorkoutToTrain({Key? key}) : super(key: key);
  static String routeName = "/training/add/workouts";
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    Training training =  args.training!;

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: kBlack,
          child: Icon(Icons.arrow_circle_left_outlined, color: kWhite, size: 8.w,),
          onPressed: () =>  Navigator.pop(context),
        ),
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        body:   SizedBox( width: 100.w, height: 100.h,
          child: Stack(
              children: [
                /// Grass Image
                Positioned(
                    top: 0,
                    child: SizedBox(width: 100.w, height: 30.h,
                      child: Image.asset('assets/images/grass.png', fit: BoxFit.cover,),
                    )
                ),
                /// Home Text H1
                Positioned(
                    top: 0,
                    child: SizedBox(width: 100.w, height: 20.h,
                        child: Center(child: TextH1('Exercise', size: 13,
                          color: Colors.black.withOpacity(0.7),
                          shadows: [
                            BoxShadow(color: kWhite.withOpacity(0.4), offset: const Offset(0, 2), blurRadius: 15)
                          ],))
                    )
                ),
                /// List Tiles
                Positioned( bottom: 0,
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topRight:     Radius.circular(10.w),
                          topLeft:      Radius.circular(10.w)
                      ),
                      child: Container( width: 100.w, height: 80.5.h,
                          color: kWhite,
                          child: _ExerciseList(training: training,)
                      )),
                ),
                ///TextField
                Positioned( top: 16.5.h,  left: 12.5.w,
                    child: SizedBox(width: 75.w, height: 10.h,
                        child: TextField(
                            style: TextStyle(
                                fontFamily: p1,
                                color: kBlack,
                                fontSize: 4.w
                            ),
                            cursorColor: kGreen,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: kWhite,
                                border: DecoratedInputBorder(
                                  child:  OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(Radius.circular(4.w)),
                                  ),
                                  shadow: BoxShadow(
                                    color: kBlack.withOpacity(0.45),
                                    offset: Offset(0, 1.3.w),
                                    blurRadius: 2.1.w,
                                  ),
                                ),
                                hintText: 'Buscar',
                                hintStyle:  TextStyle(fontFamily: p1, color: kGrey, fontSize: 4.w),
                                prefixIcon: Watcher((context, ref, child) {
                                  bool isActive = ref.watch(_searchByTags);
                                  return GestureDetector(
                                    onTap: () => ref.update<bool>(_searchByTags, (value) => !value),
                                    child: Icon(Icons.tag_rounded, color: isActive ? kGreen : kGrey, size: 6.w,),
                                  );
                                }),
                                contentPadding: EdgeInsets.zero
                            ),
                            onChanged: (value) {
                              context.ref.update(_searchCreator, (name) => value);
                              if(value.length == 3){
                                exerciseLogic.fetchReset(context.ref);
                              }
                            })
                    ))
              ]),
        ));
  }
}

class _ExerciseList extends StatelessWidget {
  const _ExerciseList({required this.training, Key? key}) : super(key: key);
  final Training training;
  @override
  Widget build(BuildContext context) {
    List<Exercise> getByFilter(Ref ref){
      bool searchByTags = ref.watch(_searchByTags);
      String search = ref.watch(_searchCreator);
      List<Exercise> res = [];
      if(searchByTags && search.isNotEmpty){
        List<String> tags = search.trim().split(',');
        tags = tags.where((element) => element.isNotEmpty).map((e) => e.trim().capitalize()).toList();
        res = exerciseLogic.getByAllTags(ref, tags);
      }else{
        res = exerciseLogic.getByName(ref, search);
        if(search.length>3){
          res = res.where((exercise) => exercise.name.toLowerCase().contains(search.toLowerCase())).toList();
        }
      }
      return res;
    }
    return Watcher((context, ref, child){
      List<Exercise> exercises = getByFilter(ref);
      if(exercises.isEmpty) { return const SizedBox.shrink(); }
      return ListView.builder(
          controller: returnController(ref),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            Workout? workout = training.workouts.firstWhereOrNull((element) => element.exercise == exercises[index].id);
            workout ??= Workout.empty(exercise: exercises[index].id, name: exercises[index].name);
            return _ExpandableTile(exercise: exercises[index], workout: workout);
          });
    });
  }
}



class _ExpandableTile extends StatelessWidget {
  const _ExpandableTile({required this.exercise, required this.workout,  Key? key}) : super(key: key);
  final Exercise exercise;
  final Workout workout;
  @override
  Widget build(BuildContext context) {
    final ExpandableController expandableController = ExpandableController();

    return ExpandablePanel(
          collapsed: const SizedBox.shrink(),
          header: SelectExerciseTile(exercise: exercise),
          controller: expandableController,
          expanded: WorkoutFormLabel(workout: workout, expandableController: expandableController),
      );
  }
}
class WorkoutFormLabel extends StatefulWidget {
   WorkoutFormLabel({required this.workout, required this.expandableController, Key? key}) : super(key: key);
  final formKey = GlobalKey<FormState>();
  final Workout workout;
  final ExpandableController expandableController;
  final TrainingController controller = TrainingController();

   @override
  State<WorkoutFormLabel> createState() => _WorkoutFormLabelState();
}

class _WorkoutFormLabelState extends State<WorkoutFormLabel> {
  @override
  Widget build(BuildContext context) {
    Workout workout = widget.workout;
    return Form( key: widget.formKey,
      child: Column( children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:[
              SizedBox(width: 30.w,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const TextH2('Repeticiones', size: 3),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WorkoutInputField(initialValue: workout.maxReps, autofocus: true, onSaved: (value) => workout.maxReps = int.parse(value)),
                            const TextH2('-', size: 5),
                            WorkoutInputField(initialValue: workout.minReps, onSaved: (value) => workout.minReps = int.parse(value)),
                          ])
                    ]),
              ),
              // Series
              SizedBox(width: 25.w,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const TextH2('Series', size: 3),
                      WorkoutInputField(initialValue: workout.series, onSaved: (value) => workout.series = int.parse(value)),
                    ]),
              ),
              // Metodo
              SizedBox( width: 34.w,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextH2('Metodo', size: 3),
                      WorkoutTypeInput(workout: workout, onTap: (value) => workout.type = value)
                    ]),
              ),
            ]),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Repes
              SizedBox( width: 30.w,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const TextH2('Descanso', size: 3),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WorkoutInputField(initialValue: workout.restSeconds~/60, onSaved: (value) => workout.restSeconds =  int.parse(value)*60),
                            const TextH2(':', size: 5),
                            WorkoutInputField(initialValue: workout.restSeconds%60, onSaved: (value) => workout.restSeconds += int.parse(value)),
                          ])
                    ]),
              ),
              // Series
              SizedBox( width: 25.w,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const TextH2('RIR', size: 3),
                        WorkoutInputField(initialValue: workout.rir, onSaved: (value) => workout.rir = int.parse(value)),
                      ])),
              // Metodo
              GestureDetector(
                onTap: () {
                  if (widget.formKey.currentState!.validate()) {
                    widget.formKey.currentState!.save();
                    widget.expandableController.expanded = false;
                    widget.controller.addWorkout(context.ref, workout);
                    //workoutsController.add(context.ref, workout);
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                child: SizedBox( width: 24.w, height: 7.h,
                    child: Icon(Icons.add_box_rounded, color: kGreen, size: 8.w,)
                ),
              ),

              SizedBox(width: 10.w,)
            ]),
      ]),
    );
  }
}


class WorkoutInputField extends StatelessWidget {
  const WorkoutInputField({this.autofocus, required this.onSaved,  required this.initialValue, Key? key}) : super(key: key);
  final bool? autofocus;
  final int initialValue;
  final Function(String value) onSaved;
  @override
  Widget build(BuildContext context) {
    String init = initialValue<10 ? '0$initialValue' : '$initialValue';
    return SizedBox( width: 11.w, height: 6.h,
      child: TextFormField(
        initialValue: init,
        onSaved: (newValue) => newValue == null || newValue.isEmpty ? onSaved('0') :onSaved(newValue),
        keyboardType: TextInputType.number,
        autofocus: autofocus ?? false,
        enableInteractiveSelection: false,
        textInputAction: TextInputAction.next,
        onEditingComplete: () => FocusScope.of(context).nextFocus(),
        inputFormatters: [
          LengthLimitingTextInputFormatter(2),
          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
        ],
        cursorColor: kGreen,
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: h2, fontSize: 5.w, color: kBlack),
        decoration:  const InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class WorkoutTypeInput extends StatefulWidget {
  const WorkoutTypeInput({required this.workout, required this.onTap,  Key? key}) : super(key: key);
  final Workout? workout;
  final Function(WorkoutType value) onTap;
  @override
  State<WorkoutTypeInput> createState() => _WorkoutTypeInputState();
}
class _WorkoutTypeInputState extends State<WorkoutTypeInput> {
  int n = 0;
  @override
  void initState() {
    if(widget.workout != null){
      n =  WorkoutType.values.indexOf(widget.workout!.type);
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
        onTap: (){
          setState(() {
            n = (n+1)>= WorkoutType.values.length ? 0 : n+1;
            widget.onTap(WorkoutType.values[n]);
          });
        },
        child: Container(width: 40.w, height: 6.h,
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: TextH2(WorkoutType.values[n].name, size: 5,)),

      );
    }
}

class SelectExerciseTile extends StatelessWidget {
  const SelectExerciseTile({required this.exercise, Key? key}) : super(key: key);
  final Exercise exercise;
  @override
  Widget build(BuildContext context) {
    final TrainingController controller = TrainingController();
    return  Container(width: 90.w,
            padding: EdgeInsets.only(left: 2.w),
            constraints: BoxConstraints(
              maxHeight: 10.h,
              minHeight: 5.h
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// PROFILE IMAGE
                  CachedImage(
                        url: exercise.imageUrl,
                        size: 10,
                   ),
                  SizedBox(width: 6.w,),
                  /// USER DATA
                  SizedBox( width: 60.w,
                   child:  Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(children: [
                       TextH2(exercise.name.maxLength(20), size: 3.6, ),
                       SizedBox(width: 2.w),
                       Watcher((context, ref, child) {
                         controller.getUpdates(ref);
                         bool exists =  controller.containsExercise(ref, exercise.id);
                         return Icon(Icons.verified_outlined, color: exists ? kGreen : kWhite, size: 5.w,);
                       })
                     ]),
                     SizedBox(height: 0.4.h,),
                     Row( children: [
                       Expanded(
                        child: TextP2(exercise.tags.toString().replaceAll('[', '').replaceAll(']', ''),
                        size: 3,maxLines: 3, color: kBlack,
                        textAlign: TextAlign.start,
                     ))])
                   ])),
   ]));
  }
}

