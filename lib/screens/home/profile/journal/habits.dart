import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/custom_icons.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/constants/colors.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/constants/theme.dart';
import 'package:marvaltrainer/firebase/dailys/model/daily.dart';
import 'package:marvaltrainer/screens/home/profile/widgets/journal_title_row.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:sizer/sizer.dart';

import 'package:marvaltrainer/constants/string.dart';
import 'package:marvaltrainer/utils/marval_arq.dart';
import 'package:marvaltrainer/widgets/marval_dialogs.dart';

import '../logic/journal_creator.dart';
import '../logic/state_controller.dart';

///HABIT LABELS
ScrollController _returnController(Ref ref){
  ScrollController  res = ScrollController();
  res.addListener((){ if(res.position.maxScrollExtent==res.offset){ dailyLogic.fetchMore(ref, n:31); }});
  return res;
}
//@TODO Make access to see all the habits include the non current ones .
class HabitList extends StatelessWidget {
  const HabitList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 100.w, height: 72.h,
    child: Watcher((context, ref, child) {
      Daily? daily = dailyLogic.getLast(ref);
      Habit? habit = watchHabitsCreator(ref);
      if(isNull(habit)){
        return ListView.separated(
            itemCount: (daily?.habitsFromPlaning.length ?? 0) + 1,
            scrollDirection: Axis.vertical,
            separatorBuilder: (context, index) => SizedBox(height: 2.h,),
            itemBuilder: (context, index) {
              /// Title
              if(index==0){ return const JournalTitle(name: "Innegociables"); }
              return Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  child: HabitLabel(habit: daily!.habitsFromPlaning[index-1]));
            });
      }
      else{
        return _CalendarList(habit: habit!);
      }
    }));
  }
}
class HabitLabel extends StatelessWidget {
  const HabitLabel({ required this.habit, Key? key}) : super(key: key);
  final Habit habit;
  @override
  Widget build(BuildContext context) {
    return   Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
            onTap: (){ MarvalDialogsInfo(context, 40,
                title: habit.name,
                richText:RichText(
                  text: TextSpan(text: habit.description,
                      style: TextStyle(fontFamily: p2, fontSize: 4.5.w, color: kBlack)),));
            },
            child:Container(width: 12.w, height: 12.w,
              decoration: BoxDecoration(
                  color: kWhite,
                  boxShadow: [BoxShadow(
                      offset: Offset(0, 3.w),
                      color: kBlackSec,
                      blurRadius: 4.w
                  )],
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(3.w),
                      bottomRight: Radius.circular(3.w),
                      bottomLeft: Radius.circular(3.w))
              ),
              child: Center(child: TextH2(habit.icon, size: 4,),),
            )),
        SizedBox(width: 6.w,),
        GestureDetector(
            onTap: () {
              dailyLogic.fetchMore(context.ref, n:31);
              updateHabitsCreator(habit, context.ref);
            },
            child:Container(width: 50.w, height: 12.w,
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                    color: kWhite,
                    boxShadow: [BoxShadow(
                        offset: Offset(0, 3.w),
                        color: kBlackSec,
                        blurRadius: 4.w
                    )],
                    borderRadius: BorderRadius.circular(3.w)
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextH2(habit.label.removeIcon(), color: kBlack, size: 4.2),
                )
            )),
      ],
    );
  }
}

class _CalendarList extends StatelessWidget {
  const _CalendarList({required this.habit, Key? key}) : super(key: key);
  final Habit habit;
  List<bool> getCalendarHabitList(List<Daily> list, DateTime date, String habit){
    // Get the dailys for this month.
    list = list.where((daily) => daily.date.month == date.month && daily.date.year == date.year && daily.habits.contains(habit)).toList();
    List<bool> calendar = List.generate(date.monthDays(), (index) => false);
    for (var daily in list) {
      calendar[daily.date.day-1] = true;
    }
    return calendar;
  }
  @override
  Widget build(BuildContext context) {
    return Watcher((context, ref, child){
            List<Daily> dailys = dailyLogic.getList(ref);
            final DateTime lastDate   = dailys.isEmpty ? DateTime.now() : dailys.first.date;
            final int monthDifference = dailys.isEmpty ? 0 : dailys.last.date.monthDifference(lastDate);
            return SizedBox(width: 100.w, height: 72.h,
                child: ListView.separated(
                  controller: _returnController(ref),
                  itemCount: monthDifference+2,
                  itemBuilder: (context, index){
                    if(index==0){ return JournalTitle(name: habit.name, onTap: (){ updateHabitsCreator(null, context.ref);}); }
                    var nextMonth =  DateTime(lastDate.year, lastDate.month - (index-1), lastDate.day);
                    List<bool> list = getCalendarHabitList(dailys, nextMonth, habit.name);
                    return Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                        child: _Calendar(habits: list, date: nextMonth));
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 3.h,),
                ));
          });
  }
}
class _Calendar extends StatelessWidget {
  const _Calendar({required this.habits, required this.date,  Key? key}) : super(key: key);
  final List<bool> habits;
  final DateTime date;
  @override
  Widget build(BuildContext context) {
    return
      Container(width: 80.w, height: 34.h,
          padding: EdgeInsets.all( 2.w),
          decoration: BoxDecoration(
              color: kBlack,
              boxShadow: [BoxShadow(
                  offset: Offset(0, 3.w),
                  color: kBlackSec,
                  blurRadius: 4.w
              )],
              borderRadius: BorderRadius.circular(2.w)
             ),
          child:
          Column(
              children: [
                SizedBox(height: 0.5.h,),
                Row(children: [
                  SizedBox(width: 4.w,),
                  TextH2(date.toStringMonthLong(), color: kWhite, size: 3.8),
                  const Spacer(),
                  TextH2('${date.year}', color: kWhite, size: 3.8),
                  SizedBox(width: 4.w,),
                ]),
                SizedBox(height: 2.h,),
                Container(width: 80.w, height: 26.h,
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: GridView.count(
                        crossAxisCount: 7,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(date.monthDays(), (index) =>
                            Padding(padding: EdgeInsets.all(1.w),
                                child:  CircleAvatar(radius: 7.w, backgroundColor: habits[index]! ? kGreen : kWhite,
                                  child: TextH1('${index+1}', color: habits[index]! ? kWhite : kBlack, size: 4,),)))
                    ))]
          ));
  }
}



