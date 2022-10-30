import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/custom_icons.dart';
import 'package:marvaltrainer/modules/habits/habit_screen.dart';
import 'package:marvaltrainer/modules/home/profile/logic.dart';
import 'package:marvaltrainer/modules/home/profile/profile_screen.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/string.dart';
import '../../constants/theme.dart';

import '../../utils/decoration.dart';
import '../../utils/marval_arq.dart';
import '../../widgets/marval_drawer.dart';
import 'models/habits.dart';


Emitter _emitter = Emitter.stream((p0)  async {
return FirebaseFirestore.instance.collection('habits/')
    .orderBy('name',descending: true)
    .snapshots();
});

List<Habit>? _getHabits(Ref ref){
  final query = ref.watch(_emitter.asyncData).data;
  if(isNull(query)||query!.size==0){ return null; }

  //Pass data from querySnapshot to Messages
  final List<Habit> list = _queryToData(query);

  String name = ref.watch(_searchCreator);
  return list.where((habit) => habit.label.toLowerCase().contains(name)).toList();
}

List<Habit> _queryToData(var query){
  List<Habit> list = [];
  for (var element in [...query.docs]){
    list.add(Habit.fromJson(map: element.data()));
  }
  return list;
}

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
                          child: Watcher((context, ref, child) {
                            return const _HabitList();
                          })
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
                                  onTap: (){
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) =>  HabitScreen(edit: false),));
                                  },
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
      var data = _getHabits(ref);
      if(isNullOrEmpty(data)){ return const SizedBox(); }
      return GridView.count(
          crossAxisCount: 2,
          physics: BouncingScrollPhysics(),
          childAspectRatio: 1.8, /** Makes child non a Square */
          children:List.generate(data!.length, (index) {
            return HabitTile(habit: data[index]);
          })
      );
    });
  }
}
class HabitTile extends StatelessWidget {
  const HabitTile({required this.habit, Key? key}) : super(key: key);
  final Habit habit;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        habitSelected = habit;
        Navigator.push(context,
        MaterialPageRoute(builder: (context) =>  HabitScreen(edit: true),));
      },
    child: Container( width: 15.w, height: 15.w, 
        decoration: BoxDecoration(
          color: kBlack,
          borderRadius: BorderRadius.circular(4.w),
        ),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
        margin: EdgeInsets.all(2.w),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children:
        [
          TextH2(habit.label, color: kWhite,),
          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          TextH1("${habit.users.length}", color: kWhite, size: 6,),
          SizedBox(width: 2.w,),
          Icon(Icons.person, color: kGreen, size: 8.w,)
          ])
        ]
    )));
  }
}
