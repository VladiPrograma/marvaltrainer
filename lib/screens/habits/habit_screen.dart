import 'package:creator/creator.dart';
import 'package:flutter/material.dart';

import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/constants/string.dart';
import 'package:marvaltrainer/firebase/habits/model/habits.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/widgets/cached_avatar_image.dart';
import 'package:marvaltrainer/widgets/marval_elevated_button.dart';
import 'package:marvaltrainer/widgets/marval_textfield.dart';
import 'package:sizer/sizer.dart';
import '../../constants/alerts/snack_errors.dart';
import '../../constants/colors.dart';
import '../../constants/theme.dart';

import '../../utils/marval_arq.dart';
import '../../widgets/marval_drawer.dart';

//@SMELLS Look to dispose the keepAlive: TRUE


enum _Status {ALL, ASSIGNED, UNASSIGNED }
enum _Save {NO, YES, PENDING}

Creator<_Status> _statusCreator = Creator.value(_Status.ALL);
Creator<_Save> _saveState = Creator.value(_Save.NO);


///@TODO Modify dialogs form admit very long descriptions without textoverflow.
class HabitScreen extends StatelessWidget {
  HabitScreen({Key? key}) : super(key: key);
  static String routeName = '/habits/edit';
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    String titleByStatus(_Status status){
      return status == _Status.ALL ? "Todos los usuarios" :
      status == _Status.ASSIGNED ? "Usuarios asignados" :
      "Usuarios no asignados";
    }
    List<User> filterByStatus(List<User> users, _Status status, Habit filterHabit){
      List<User> res = users;
      if(status == _Status.ASSIGNED){
        res = List<User>.of(users.where((element){
          return filterHabit.users.contains(element.id);
        }));
      }
      if(status == _Status.UNASSIGNED){
        res = List<User>.of(users.where((element){
          return !filterHabit.users.contains(element.id);
        }));
      }
      return res;
    }
    double getGridSize(int items){
      int size = (items != 0 ? items : 3) ~/ 3;
      return (size+1) * 15; //Gets the Grid Height Size
    }

    return Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        drawer: const MarvalDrawer(name: 'Habitos',),
        body: SizedBox( width: 100.w, height: 100.h,
          child: SingleChildScrollView(
            child: SafeArea(
            child: Watcher((context, ref, child) {
              Habit habit = habitsLogic.getSelect(ref) ?? Habit.empty();
              return Column(
                children:<Widget> [
                  SizedBox(height: 2.h),
                  // Title
                  Row(
                      children: [
                        // Back Arrow
                        GestureDetector(
                            onTap: (){ Navigator.pop(context);},
                            child: SizedBox(width: 10.w,
                                child: Icon(Icons.keyboard_arrow_left,
                                    color: kBlack, size: 9.w)
                            )),
                        // Title
                        Center(child: SizedBox(width: 80.w,
                            child: const  TextH2("Editar Habito", textAlign: TextAlign.center,))
                        ),
                        //Delete Icon
                        GestureDetector(
                            onTap: () async{
                              if(habit.users.isEmpty){
                                habitsLogic.delete(habit.id)
                                .then((value) => Navigator.pop(context));
                              }else{
                                ThrowSnackbar.deleteHabitError(context);
                              }
                            },
                            child: SizedBox( width: 7.w,
                                child: Icon(
                                    Icons.delete_rounded,
                                    color: kBlack,
                                    size: 7.w
                                )
                            )),
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
                                          onChanged: (value) => ref.update<_Save>(_saveState, (p0) => _Save.PENDING),
                                        ))),
                                SizedBox(width: 7.5.w,),
                                // Save Button
                                Watcher((context, ref, child){
                                  _Save iconState = ref.watch(_saveState);
                                  if(iconState == _Save.NO) return const SizedBox.shrink();
                                  Color iconColor = iconState == _Save.YES ? kGreen : kRed;
                                  return ElevatedButton(
                                      onPressed: (){
                                        if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                        habitsLogic.updateLabels(habit).then((value) =>
                                            context.ref.update(_saveState, (p0) => _Save.YES));
                                      }},
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(iconColor),
                                        elevation: MaterialStateProperty.all(2.w),
                                        shadowColor: MaterialStateProperty.all(kBlack),
                                      ),
                                      child: SizedBox(width: 15.w, child: const Icon(Icons.save_alt_rounded, color: kWhite,))
                                  );
                                })
                              ]),
                          SizedBox(height: 3.h,),
                          MarvalInputTextField(
                            width: 70.w,
                            initialValue: habit.name ,
                            labelText: "Titulo",
                            onSaved: (value) => habit.name = value ?? habit.name,
                            validator: (value){
                              if(isNullOrEmpty(value)){ return kEmptyValue; }
                              if(value!.length>25)    { return "{$kToLong 25}";     }
                              return null;
                            },
                            onChanged: (value) => ref.update<_Save>(_saveState, (p0) => _Save.PENDING),
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
                            onChanged: (value) => ref.update<_Save>(_saveState, (p0) => _Save.PENDING),
                          ),
                          SizedBox(height: 3.h,),
                        ],
                      )),
                  /// @OPTIONAL Nice animation in filter list when u press Icon Button
                  Watcher((context, ref, child){
                    _Status status = ref.watch(_statusCreator);
                    String _text = titleByStatus(status);
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextP1(_text),
                          SizedBox(width: 4.w),
                          GestureDetector(
                              onTap: (){ ref.update<_Status>(_statusCreator, (p0){
                                if(status == _Status.ALL) return _Status.ASSIGNED;
                                if(status == _Status.ASSIGNED) return _Status.UNASSIGNED;
                                return _Status.ALL;
                              });
                              },
                              child: Icon(
                                  status == _Status.ALL      ? Icons.check_box_outlined :
                                  status == _Status.ASSIGNED ? Icons.check_box_rounded :
                                  Icons.indeterminate_check_box_rounded,
                                  color: status == _Status.ALL      ? kGrey :
                                  status == _Status.ASSIGNED ? kGreen : kRed
                              )),
                        ]);
                  }),
                  SizedBox(height: 2.h,),
                  SizedBox(width: 70.w,
                      child: Watcher((context, ref, child) {
                        List<User> users = userLogic.getActive(ref) ?? [];
                        return Watcher((context, ref, child) {
                          Habit? streamHabit = habitsLogic.getByID(habit.id, ref);
                          final status = ref.watch(_statusCreator);
                          List<User> filter = filterByStatus(users, status, streamHabit ?? habit);
                          return SizedBox( height: getGridSize(filter.length).h,
                              child: GridView.count(
                                  crossAxisCount: 3,
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio: 0.8, /** Makes child non a Square */
                                  children:List.generate(filter.length, (index) {
                                    return _BasicUserTile(user: filter[index], habit: streamHabit ?? habit,);
                                  })
                              ));
                        });
                      })
                  )],
              );
        }))),
    ));
  }
}


class _BasicUserTile extends StatelessWidget {
  const _BasicUserTile({required this.user, required this.habit, Key? key}) : super(key: key);
  final User user;
  final Habit habit;
  @override
  Widget build(BuildContext context) {
    Color getBorderColor(){
      return habit.users.contains(user.id) ? kGreen : kRed.withOpacity(0);
    }
    return  GestureDetector(
      onTap: () async {
        habitsLogic.updateUser(habit, user.id);
       //@Error change this.
       //Planing planing = await Planing.getNewPlaning(user.id);
       //planing.updateHabits(habit);
      },
      child: Column(
        children: [
    
          Container(
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(25.w),
             border: Border.all(
               color: getBorderColor(),
               width: 0.6.w
             ),
             boxShadow: [
               BoxShadow(
                 color: kBlack.withOpacity(0.45),
                 offset: Offset(0, 1.3.w),
                 blurRadius: 2.1.w,
               )]
           ),
           child: CachedAvatarImage(url: user.profileImage, size: 5)),
          SizedBox(height: 0.5.h,),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: TextP1("${user.name.removeIcon() } ${user.lastName}".maxLength(25),
                size: 3,
                maxLines: 1,
                textAlign: TextAlign.center
            ),
          )
        ]));
  }
}
