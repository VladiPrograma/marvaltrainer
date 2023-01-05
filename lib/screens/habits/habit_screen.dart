import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/custom_icons.dart';
import 'package:marvaltrainer/config/screen_args_data.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/firebase/habits/model/habits.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/screens/habits/add/add_habit_screen.dart';
import 'package:marvaltrainer/screens/habits/controllers/habit_controller.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/widgets/cached_avatar_image.dart';
import 'package:marvaltrainer/widgets/users_selection_grid.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/string.dart';
import '../../constants/theme.dart';

import '../../widgets/inner_border.dart';
import '../../widgets/marval_drawer.dart';

final TextEditingController _textEditingController = TextEditingController();
void _openHabitScreen(BuildContext context, Habit habit){
  Navigator.pushNamed(context, AddHabitScreen.routeName, arguments: ScreenArguments(habit: habit));
}

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({Key? key}) : super(key: key);
  static String routeName = "/habits";

  @override
  Widget build(BuildContext context) {
    HabitController controller = HabitController();
    return Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        drawer: const MarvalDrawer(name: 'Habitos',),
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
                        child: Center(child: TextH1('Habitos', size: 13,
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
                          child:  _HabitList(controller: controller,)
                      )),
                ),
                //Filter by User
                Positioned( top: 18.h, left: 12.5.w,
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomRight:     Radius.circular(10.w),
                          bottomLeft:      Radius.circular(10.w)
                      ),
                      child: Container( width:  75.w,
                          color: kWhite,
                          child: Watcher((context, ref, child) {
                            String userId = controller.getFilterId(ref);
                            bool userFilter = controller.isFilterActive(ref);
                            if(userId.isEmpty && userFilter){
                              return UserSelectionGrid(
                                // Get the first tap on the grid to dismiss the container and update creator
                                  onTap: (value) => controller.updateFilterId(ref, value.first)
                              );
                            }
                            return const SizedBox.shrink();
                          })
                      )),
                ),
                ///TextField
                Positioned( top: 16.5.h,  left: 12.5.w,
                    child: SizedBox(width: 75.w, height: 10.h,
                        child: TextField(
                          controller: _textEditingController,
                          onTap: () => controller.onTextFieldTap(context.ref),
                          onChanged: (value) {
                            controller.updateSearch(context.ref, value);
                            //@WTF
                            // if(value.length == 3){
                            //   exerciseLogic.fetchReset(context.ref);
                            // }
                          },
                          cursorColor: kGreen,
                          style: TextStyle(
                              fontFamily: p1,
                              color: kBlack,
                              fontSize: 4.w
                          ),
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
                                bool isActive = controller.isFilterActive(ref);
                                return GestureDetector(
                                  onTap: () => controller.onPrefixIconTap(context.ref, isActive, _textEditingController),
                                  child: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: Icon(CustomIcons.users, color: isActive ? kGreen : kGrey, size: 6.w,),
                                  ),
                                );
                              }),

                              suffixIcon: GestureDetector(
                                onTap: () => _openHabitScreen(context, Habit.empty()),
                                child: Icon(CustomIcons.leaf, color: kGreen, size: 5.w,),
                              ),
                              contentPadding: EdgeInsets.zero
                          ),
                        )
                    ))
              ]),
        ));
  }
}

class _HabitList extends StatelessWidget {
  const _HabitList({required this.controller, Key? key}) : super(key: key);
  final HabitController controller;
  @override
  Widget build(BuildContext context) {
    return Watcher((context, ref, child){
      List<User> users = userLogic.getAll(ref) ?? [];
      List<Habit> habits = habitsLogic.getAll(ref) ?? [];

      String search = controller.getSearchText(ref);
      String userId = controller.getFilterId(ref);
      bool isActive = controller.isFilterActive(ref);

      if(habits.isEmpty || userId.isEmpty && isActive) { return const SizedBox.shrink(); }

      if(userId.isNotEmpty){
        habits = habits.where((train) => train.users.contains(userId)).toList();
        User user = users.firstWhere((user) => user.id == userId );
        _textEditingController.text = '${user.name.removeIcon()}${user.lastName}';

        return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              return _HabitTile(users: users.where((user) => habits[index].users.contains(user.id)).toList(), habit: habits[index]);
            });
      }

      habits = habits.where((train) => train.label.toLowerCase().contains(search.toLowerCase()) ).toList();

      return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            return _HabitTile(habit: habits[index], users: users.where((user) => habits[index].users.contains(user.id)).toList());
          },
      );
    });
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({required this.habit, required this.users, Key? key}) : super(key: key);
  final Habit habit;
  final List<User> users;
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        onTap: () => _openHabitScreen(context, habit),
        child: Container(width: 100.w, height: 12.h,
            margin: EdgeInsets.only(top: 1.5.w),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 3.w,),
                  /// USER DATA
                  SizedBox( width: 60.w, height: 15.h,
                      child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextH2('${habit.label.getIcon()}${habit.label.removeIcon().trim()} - ${habit.name.trim()} '.maxLength(28), size: 3, ),
                            SizedBox(height: 0.4.h,),
                            Row( children: [
                              Expanded(
                                  child: TextP2(habit.description ,
                                    size: 3,
                                    maxLines: 3,
                                    color: kBlack,
                                    textAlign: TextAlign.start,
                                  )
                              )
                            ]),
                          ])),
                  const Spacer(),
                  Container(width: 30.w,
                      padding: EdgeInsets.only(left: 1.5.w),
                      decoration: BoxDecoration(
                          color: kBlack.withOpacity(0.25),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(3.w),
                            topLeft: Radius.circular(3.w),
                          )
                      ),
                      child: UsersListView(users: users)
                  )
                ])));
  }
}

class UsersListView extends StatelessWidget {
  const UsersListView({required this.users, Key? key}) : super(key: key);
  final List<User> users;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: users.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        itemBuilder: (context, index) {
          return Align(
              widthFactor: 0.53,
              child: Container(
                  padding: EdgeInsets.all(0.7.w),
                  decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(100.w)
                  ),
                  child: CachedAvatarImage(url: users[index].profileImage, size: 4.5, )));
        });
  }
}



