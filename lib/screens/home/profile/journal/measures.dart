import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/firebase/measures/model/measures.dart';
import 'package:marvaltrainer/screens/home/profile/widgets/journal_title_row.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:sizer/sizer.dart';

import 'package:marvaltrainer/constants/colors.dart';
import 'package:marvaltrainer/constants/theme.dart';

//@TODO Make one scrollController method to dont need the same method in every list.
ScrollController _returnController(Ref ref){
  ScrollController  res = ScrollController();
  res.addListener((){ if(res.position.maxScrollExtent==res.offset){ measuresLogic.fetchMore(ref, n:2); }});
  return res;
}

class MeasureList extends StatelessWidget {
  const MeasureList({required this.userId, Key? key}) : super(key: key);
  final String userId;
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 100.w, height: 76.h,
        child: Watcher((context, ref, child) {
          List<Measures>? measures = measuresLogic.getList(ref, userId);
          return ListView.builder(
              controller: _returnController(ref),
              itemCount: measures!.length+1,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                /// Title
                if(index==0){ return const JournalTitle(name: "     Medidas"); }
                return Container( width: 90.w,
                    margin: EdgeInsets.only(bottom: 3.h),
                    child: MeasureLabel(measure: measures[index-1],));
              });
        }));
  }
}

class MeasureLabel extends StatelessWidget {
  const MeasureLabel({required this.measure, Key? key}) : super(key: key);
  final Measures measure;
  @override
  Widget build(BuildContext context) {
    String aestheticDate = '${measure.date.day} ${measure.date.toStringMonth().toLowerCase()} ${measure.date.year}';
    return Container( width: 80.w,
        margin: EdgeInsets.all(8.w),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(
                offset: Offset(0, 3.w),
                color: kBlackSec,
                blurRadius: 4.w
            )],
            color: kBlack,
            borderRadius: BorderRadius.circular(2.w)
        ),
        child:  Column(
            children: [
              Row(children: [
                TextH2(measure.date.toStringWeekDayLong(), color: kWhite, size: 3.8),
                const Spacer(),
                TextH2(aestheticDate, color: kWhite, size: 3.8),
              ]),
              SizedBox(height: 3.h),
              Row(children: const [
                TextH2('Zona', color: kWhite, size: 3.8,),
                Spacer(),
                TextH2('Medidas(cm)', color: kWhite, size: 3.8,)
              ]),
              SizedBox(height: 1.h,),
              _RowMeasure(name: 'Ombligo', measure: measure.ombligo,),
              SizedBox(height: 1.h),
              _RowMeasure(name: 'Ombligo +2cm', measure: measure.ombligoP2),
              SizedBox(height: 1.h),
              _RowMeasure(name: 'Ombligo -2cm', measure: measure.ombligoM2),
              SizedBox(height: 1.h),
              _RowMeasure(name: 'Cadera', measure: measure.cadera),
              SizedBox(height: 1.h),
              _RowMeasure(name: 'Cont. pecho', measure: measure.contPecho),
              SizedBox(height: 1.h),
              _RowMeasure(name: 'Cont. hombros', measure: measure.contHombros),
              SizedBox(height: 1.h),
              _RowMeasure(name: 'Gemelo izq', measure: measure.gemeloIzq),
              SizedBox(height: 1.h),
              _RowMeasure(name: 'Gemelo drch', measure: measure.gemeloDrch),
              SizedBox(height: 1.h),
              _RowMeasure(name: 'Muslo izq', measure: measure.musloIzq),
              SizedBox(height: 1.h),
              _RowMeasure(name: 'Muslo drch', measure: measure.musloDrch),
              SizedBox(height: 1.h),
              _RowMeasure(name: 'Biceps izq', measure: measure.bicepsIzq),
              SizedBox(height: 1.h),
              _RowMeasure(name: 'Biceps drch', measure: measure.bicepsDrch),
              SizedBox(height: 2.h,),
            ])
    );
  }
}
class _RowMeasure extends StatelessWidget {
  const _RowMeasure({required this.measure, required this.name, Key? key}) : super(key: key);
  final double measure;
  final String name;
  @override
  Widget build(BuildContext context) {
    return Row( children: [
      TextH2(name, color: kWhite, size: 3.8,),
      const Spacer(),
      TextH2('$measure', color: kWhite, size: 3.8,),
      SizedBox(width: 9.w,)
    ]);
  }
}



