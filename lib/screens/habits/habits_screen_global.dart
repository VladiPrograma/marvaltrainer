import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/firebase/habits/dto/habits_resume.dart';
import 'package:marvaltrainer/firebase/habits/logic/habits_logic.dart';
import 'package:marvaltrainer/firebase/habits/model/habits.dart';
import 'package:marvaltrainer/screens/habits/habit_screen.dart';
import 'package:marvaltrainer/screens/habits/new_habit_screen.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/string.dart';
import '../../constants/theme.dart';

import '../../widgets/inner_border.dart';
import '../../widgets/marval_drawer.dart';


Creator<String> _searchCreator = Creator.value('');

class HabitsScreenGlobal extends StatelessWidget {
  const HabitsScreenGlobal({Key? key}) : super(key: key);
  static String routeName = "/habits";

  @override
  Widget build(BuildContext context) {
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
                          child: _HabitList()
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
                                prefixIcon: Icon(Icons.search_rounded, color: kGrey,size: 8.w,),
                                suffixIcon: GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, NewHabitScreen.routeName),
                                  child: Icon(Icons.add_box_rounded, color: kGreen, size: 8.w,),
                                ),
                                contentPadding: EdgeInsets.zero
                            ),
                            onChanged: (value) {
                                ///Search logic
                                context.ref.update(_searchCreator, (name) => value.toLowerCase());
                            })
                    ))
              ]),
        ));
  }
}

class _HabitList extends StatelessWidget {
  const _HabitList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Watcher((context, ref, child){
      List<HabitsResumeDTO> habits = habitsLogic.getUserHome(ref, ref.watch(_searchCreator));
      return GridView.count(
          crossAxisCount: 3,
          physics: const BouncingScrollPhysics(),
          childAspectRatio: 0.9, /** Makes child non a Square */
          children:List.generate(habits.length, (index) {
            return _HabitTile(habit: habits[index]);
          })
      );
    });
  }
}


class _HabitTile extends StatelessWidget {
  const _HabitTile({required this.habit, Key? key}) : super(key: key);
  final HabitsResumeDTO habit;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (){
          habitsLogic.updateSelect(context.ref, habit.id);
          Navigator.pushNamed(context, HabitScreen.routeName);
        },
        child: Container( width: 15.w,
            decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(4.w),
                boxShadow: [BoxShadow(
                    color: kBlack.withOpacity(0.8),
                    spreadRadius: 0.5.w,
                    blurRadius: 1.w,
                    offset: Offset(0, 1.w)
                )]
            ),
            margin: EdgeInsets.all(2.w),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 TextH2(habit.label.getIcon(), size: 9),
                  SizedBox(height: 2.h,),
                  Container( width: 20.w,
                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                    decoration: BoxDecoration(
                        color: kWhite,
                        border: Border.all(color: kBlack, width: 0.5.w),
                        borderRadius: BorderRadius.circular(3.w)
                    ),
                    child: TextH2(habit.label.removeIcon(), size: 3.3, textAlign: TextAlign.center, color: kBlack,),
                  )
                ]
            )));
  }
}
