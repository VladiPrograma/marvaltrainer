import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/custom_icons.dart';
import 'package:marvaltrainer/config/screen_args_data.dart';
import 'package:marvaltrainer/firebase/trainings/model/training.dart';
import 'package:marvaltrainer/screens/workouts/add/edit_training_screen.dart';
import 'package:marvaltrainer/screens/workouts/controllers/training_controller.dart';
import 'package:marvaltrainer/widgets/cached_avatar_image.dart';
import 'package:marvaltrainer/widgets/users_selection_grid.dart';
import 'package:sizer/sizer.dart';

import '../../firebase/users/model/user.dart';
import '../../utils/extensions.dart';

import '../../constants/colors.dart';
import '../../constants/global_variables.dart';
import '../../constants/string.dart';
import '../../constants/theme.dart';

import '../../widgets/inner_border.dart';
import '../../widgets/marval_drawer.dart';


final TextEditingController _textEditingController = TextEditingController();
void _openTrainingScreen(BuildContext context,Training training){
  Navigator.pushNamed(context, EditTrainingScreen.routeName, arguments: ScreenArguments(training: training));
}

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({Key? key}) : super(key: key);
  static String routeName = "/workouts";
  static TrainingController controller = TrainingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        drawer: const MarvalDrawer(name: 'Entrenos'),
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
                        child: Center(child: TextH1('Entrenos', size: 13,
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
                          child:  _TrainingList(controller: controller,)
                      )),
                ),
                /// Filter by User
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
                              if(value.length == 3){
                                exerciseLogic.fetchReset(context.ref);
                              }
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
                                  onTap: () => _openTrainingScreen(context, Training.empty()),
                                  child: Icon(CustomIcons.gym, color: kGreen, size: 7.w,),
                                ),
                                contentPadding: EdgeInsets.zero
                            ),
                           )
                    ))
              ]),
        ));
  }
}

class _TrainingList extends StatelessWidget {
  const _TrainingList({required this.controller, Key? key}) : super(key: key);
  final TrainingController controller;
  @override
  Widget build(BuildContext context) {
    return Watcher((context, ref, child){
      List<User> users = userLogic.getAll(ref) ?? [];
      List<Training> trainings = trainingLogic.getAll(ref) ?? [];

      String search = controller.getSearchText(ref);
      String userId = controller.getFilterId(ref);
      bool isActive = controller.isFilterActive(ref);

      if(trainings.isEmpty || userId.isEmpty && isActive) { return const SizedBox.shrink(); }

      if(userId.isNotEmpty){
        trainings = trainings.where((train) => train.users.contains(userId)).toList();
        User user = users.firstWhere((user) => user.id == userId );
        _textEditingController.text = '${user.name.removeIcon()}${user.lastName}';

        return ListView.builder(
            itemCount: trainings.length,
            itemBuilder: (context, index) {
              return TrainingTile(users: users.where((user) => trainings[index].users.contains(user.id)).toList(), training: trainings[index]);
            });
      }

      trainings = trainings.where((train) => train.label.toLowerCase().contains(search.toLowerCase()) ).toList();
      return ListView.builder(
          itemCount: trainings.length,
          itemBuilder: (context, index) {
            return TrainingTile(users: users.where((user) => trainings[index].users.contains(user.id)).toList(), training: trainings[index]);
      });
    });
  }
}

class TrainingTile extends StatelessWidget {
  const TrainingTile({required this.training, required this.users, Key? key}) : super(key: key);
  final Training training;
  final List<User> users;
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        onTap: () => _openTrainingScreen(context, training),
        child: Container(width: 100.w, height: 12.h,
            margin: EdgeInsets.only(top: 1.5.w),
            padding: EdgeInsets.only(left: 2.5.w),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 3.w,),
                  /// USER DATA
                  SizedBox( width: 60.w, height: 12.h,
                      child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextH2(training.label.maxLength(25), size: 3.6, ),
                            SizedBox(height: 0.4.h,),
                            Row( children: [
                              Expanded(
                                  child: TextP2(training.workouts.map((e) => e.name).toString().replaceAll('(', '').replaceAll(')', ''),
                                    size: 3,
                                    maxLines: 3,
                                    color: kBlack,
                                    textAlign: TextAlign.start,
                                  )
                              )
                            ]),
                  ])),
                 const Spacer(),
                 Container(width: 32.w,
                 padding: EdgeInsets.only(left: 1.5.w),
                 decoration: BoxDecoration(
                   color: kBlack.withOpacity(0.25),
                   borderRadius: BorderRadius.only(
                     bottomLeft: Radius.circular(3.w),
                     topLeft: Radius.circular(3.w),
                   )
                 ),
                 child: users.isNotEmpty ? UsersListView(users: users) : const SizedBox.shrink()
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


