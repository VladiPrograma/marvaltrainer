import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/constants/string.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/utils/objects/planing.dart';
import 'package:marvaltrainer/widgets/cached_avatar_image.dart';
import 'package:marvaltrainer/widgets/marval_elevated_button.dart';
import 'package:marvaltrainer/widgets/marval_textfield.dart';
import 'package:sizer/sizer.dart';
import '../../constants/alerts/snack_errors.dart';
import '../../constants/colors.dart';
import '../../constants/theme.dart';

import '../../utils/marval_arq.dart';
import '../../utils/objects/user.dart';
import '../../widgets/marval_drawer.dart';
import 'models/habits.dart';

//@SMELLS Look to dispose the keepAlive: TRUE

Emitter<List<MarvalUser>?> _usersEmitter = Emitter((ref, emit) async{
  final query = await FirebaseFirestore.instance.collection('users/')
      .where('active', isEqualTo: true)
      .orderBy('name').get();
  if(isNull(query)||query.size==0){ emit(null); }

  //Pass data from querySnapshot to Messages
  final List<MarvalUser> list = _queryToData(query);
  emit(list);
}, keepAlive: true);
List<MarvalUser> _queryToData(var query){
  List<MarvalUser> list = [];
  for (var element in [...query.docs]){
    list.add(MarvalUser.fromJson(element.data()));
  }
  return list;
}

enum _UserFilter {ALL_USERS, USERS_ASSIGNED, USERS_UNASSIGNED }
enum _SaveStates {NONE, TO_SAVE, SAVED }

Creator<_UserFilter> _checkFilter = Creator.value(_UserFilter.ALL_USERS);
Creator<bool> _repaintUsersAssigment = Creator.value(false);
Creator<_SaveStates> _saveIconState = Creator.value(_SaveStates.NONE);

late Habit  habitSelected;
String? _label;
String? _name;
String? _description;

///@TODO Modify dialogs form admit very long descriptions without textoverflow.
class HabitScreen extends StatelessWidget {
  HabitScreen({required this.edit,  Key? key}) : super(key: key);
  final bool edit;
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
                children:<Widget>
                [
                 SizedBox(height: 2.h),
                 Row(
                 children: [
                  GestureDetector(
                  onTap: (){ Navigator.pop(context);},
                  child: SizedBox(width: 10.w,
                         child: Icon(Icons.keyboard_arrow_left,
                         color: kBlack, size: 9.w)
                  )),
                  Center(child: SizedBox(width: 80.w,
                         child: TextH2(edit ? "Editar Habito" : "Añadir Habito",
                                textAlign: TextAlign.center,))
                  ),
                  Visibility(
                  visible: edit,
                  child:  GestureDetector(
                    onTap: (){
                      if(habitSelected.users.isNotEmpty){
                        ThrowSnackbar.deleteHabitError(context);
                        return;
                      }
                      habitSelected.deleteFromDB();
                      Navigator.pop(context);

                    },
                    child: SizedBox( width: 7.w,
                     child: Icon(
                        Icons.delete_rounded,
                        color: kBlack,
                        size: 7.w
                     )
                  ))),
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
                                hintText: edit ? null : "Nombre",
                                initialValue: edit ? habitSelected.label : null,
                                labelText: "Nombre",
                                onSaved: (value) => _label = value,
                                validator: (value){
                                  if(isNullOrEmpty(value?.trim())){ return kEmptyValue; }
                                  if(value!.length>25)    { return "{$kToLong 10";     }
                                  return null;
                                },
                      ))),
                      SizedBox(width: 7.5.w,),
                      Watcher((context, ref, child){
                        _SaveStates iconState = ref.watch(_saveIconState);
                        if(iconState == _SaveStates.NONE) return const SizedBox.shrink();
                        Color iconColor = kRed;
                        if(iconState == _SaveStates.SAVED){
                          iconColor = kGreen;
                        }
                        return GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              Habit addHabit = Habit(name: habitSelected.name, label: _label!, description: _description!, users: habitSelected.users);
                              addHabit.setInDB()
                               .then((value){ ThrowSnackbar.habitUpdateSuccess(context); })
                               .onError((error, stackTrace){ ThrowSnackbar.habitUpdateError(context);});
                              };
                              context.ref.update(_saveIconState, (p0) => _SaveStates.SAVED);
                          },
                          child: Icon(Icons.save, color: iconColor, size: 15.w,),
                        );
                      })
                    ]),
                    SizedBox(height: 3.h,),
                    MarvalInputTextField(
                      width: 70.w,
                      readOnly: edit,
                      hintText: edit ? null : "Titulo",
                      initialValue: edit ? habitSelected.name : null,
                      labelText: "Titulo",
                      onSaved: (value) => _name = value,
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
                      hintText: edit ? null : "Descripcion",
                      initialValue: edit ? habitSelected.description : null,
                      labelText: "Descripcion",
                      onSaved: (value) => _description = value,
                      validator: (value){
                        if(isNullOrEmpty(value)){ return kEmptyValue; }
                        if(value!.length>1000)    { return "{$kToLong 1000";     }
                        return null;
                      },
                     onChanged: (value) {
                       context.ref.update(_saveIconState, (p0) => _SaveStates.TO_SAVE);
                     },
                    ),
                    SizedBox(height: 3.h,),
                  ],
                )),
                  /// @OPTIONAL Nice animation in filter list when u press Icon Button
                  Watcher((context, ref, child){
                    if(!edit) return const SizedBox.shrink();
                    _UserFilter check = ref.watch(_checkFilter);
                    String _text = check == _UserFilter.ALL_USERS ? "Todos los usuarios" :
                                   check == _UserFilter.USERS_ASSIGNED ? "Usuarios asignados" :
                                   "Usuarios no asignados";
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextP1(_text),
                          SizedBox(width: 4.w),
                          GestureDetector(
                           onTap: (){ ref.update<_UserFilter>(_checkFilter, (p0){
                             if(check == _UserFilter.ALL_USERS) return _UserFilter.USERS_ASSIGNED;
                             if(check == _UserFilter.USERS_ASSIGNED) return _UserFilter.USERS_UNASSIGNED;
                             return _UserFilter.ALL_USERS;
                            });
                           },
                           child: Icon(
                               check == _UserFilter.ALL_USERS      ? Icons.check_box_outlined :
                               check == _UserFilter.USERS_ASSIGNED ? Icons.check_box_rounded :
                               Icons.indeterminate_check_box_rounded,
                               color: check == _UserFilter.ALL_USERS      ? kGrey :
                                      check == _UserFilter.USERS_ASSIGNED ? kGreen : kRed
                           )),
                        ]);
                  }),
                  SizedBox(height: 2.h,),
                  SizedBox(width: 70.w,
                      child: Watcher((context, ref, child) {
                        if(!edit) return const SizedBox.shrink();

                        final check = ref.watch(_checkFilter);
                        List<MarvalUser>? users = ref.watch(_usersEmitter.asyncData).data;

                        if(isNull(users)) return const SizedBox.shrink();
                        if(check == _UserFilter.USERS_ASSIGNED){
                          users = List<MarvalUser>.of(users!.where((element){
                            return habitSelected.users.contains(element.id);
                          }));
                        } //Filtering Users list
                        if(check == _UserFilter.USERS_UNASSIGNED){
                          users = List<MarvalUser>.of(users!.where((element){
                            return !habitSelected.users.contains(element.id);
                          }));
                        }//Filtering Users list
                        int length = (users?.length ?? 3) ~/ 3;
                        double size = (length+1) * 15; //Gets the Grid Height Size
                        return SizedBox( height: size.h,
                        child: GridView.count(
                            crossAxisCount: 3,
                            physics: NeverScrollableScrollPhysics(),
                            childAspectRatio: 0.8, /** Makes child non a Square */
                            children:List.generate(users!.length, (index) {
                              return _BasicUserTile(user: users![index],);
                            })
                        ));
                      })),
                  !edit ? MarvalElevatedButton("Guardar ",
                      onPressed: (){
                        if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            Habit addHabit = Habit.create(name: _name!, label: _label!, description: _description!);
                            addHabit.setInDB();
                            _formKey.currentState!.reset();
                        }
                      },
                      backgroundColor: MaterialStateColor.resolveWith((states){
                        return states.contains(MaterialState.pressed) ? kGreenSec :  kGreen;
                      })) : const SizedBox.shrink(),
                  !edit ? SizedBox(height: 3.h) : const SizedBox.shrink(),
                  !edit ? MarvalElevatedButton("Cancelar", onPressed: (){Navigator.pop(context);},
                    backgroundColor: MaterialStateColor.resolveWith((states){
                      return states.contains(MaterialState.pressed) ? kRed :  kBlack;
                    })) : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ));
  }
}


class _BasicUserTile extends StatelessWidget {
  const _BasicUserTile({required this.user, Key? key}) : super(key: key);
  final MarvalUser user;
  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: () async {

          habitSelected.updateUsers(user.id);
          context.ref.update<bool>(_repaintUsersAssigment, (flag) => !flag);

          Planing planing = await Planing.getNewPlaning(user.id);
          planing.updateHabits(habitSelected);

      },
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Watcher((context, ref, child){
            bool flag = ref.watch(_repaintUsersAssigment);
            bool active = habitSelected.users.contains(user.id);
            return CircleAvatar(
              radius: 10.5.w,
              backgroundColor: active ? kGreen : kBlack,
            );
          }),
          CachedAvatarImage(url: user.profileImage, size: 5),
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
