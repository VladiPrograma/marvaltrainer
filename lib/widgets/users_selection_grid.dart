import 'dart:ui';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/widgets/cached_avatar_image.dart';
import 'package:sizer/sizer.dart';
import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marvaltrainer/constants/colors.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/constants/theme.dart';
import 'package:marvaltrainer/utils/extensions.dart';


/// * Gets the Grid Height Size *
double _getGridSize(int items){
  int size = (items != 0 ? items : 3) ~/ 3;
  return (size+1) * 13;
}

Creator<_FilterOption> _filterCreator = Creator.value(_FilterOption .ALL);
Creator<List<String>> _userIdCreator = Creator.value([]);
enum _FilterOption  {ALL, SELECTED, NOT_SELECTED }
class UserFilterController {
  List<String> get(Ref ref) =>ref.watch(_userIdCreator);
  void add(Ref ref, String userId) => ref.update<List<String>>(_userIdCreator, (list) => [userId, ...list]);
  void clear(Ref ref) => ref.update<List<String>>(_userIdCreator, (list) => []);
  void remove(Ref ref, String userId){
    ref.update<List<String>>(_userIdCreator, (list){
      list.removeWhere((element) => element == userId);
      return [...list];
    });
  }
  void next(Ref ref){
    ref.update<_FilterOption>(_filterCreator, (selection){
      if(selection == _FilterOption.ALL){
        return _FilterOption.SELECTED;
      }
      if( selection == _FilterOption.SELECTED){
        return _FilterOption.NOT_SELECTED;
      }
      return _FilterOption.ALL;
    });
  }
}

List<User> _filter(Ref ref, List<User> users, List<String> userSelection){
  _FilterOption option = ref.watch(_filterCreator);

  if(option == _FilterOption.SELECTED){
    return users.where((user) => userSelection.contains(user.id)).toList();
  }
  if(option == _FilterOption.NOT_SELECTED){
    return users.where((user) => !userSelection.contains(user.id)).toList();
  }
  return users;
}
UserFilterController _controller = UserFilterController();

class UserSelectionGrid extends StatelessWidget {
  const UserSelectionGrid({required this.onTap, this.initialValues, Key? key}) : super(key: key);
  final Function(List<String> value) onTap;
  final List<String>? initialValues;
  @override
  Widget build(BuildContext context) {
    if(initialValues != null){
      context.ref.update(_userIdCreator, (p0) => initialValues);
    }
    return Column(
      children: [
        Watcher((context, ref, child){
          _FilterOption option = ref.watch(_filterCreator);
          if(option == _FilterOption.ALL){
            return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 7.w),
              SizedBox( width: 60.w,
                  child: const TextP1('Todos los usuarios',
                    size: 3.8,
                    textAlign: TextAlign.center
                  )
              ),
              SizedBox(width: 7.w,
                  child: GestureDetector(
                      onTap: () => _controller.next(ref),
                      child:  Icon( Icons.check_box_outline_blank_rounded, color: kGrey, size: 6.w,)
                  )),
            ]);
          }
          if(option == _FilterOption.SELECTED){
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 7.w),
                  SizedBox( width: 60.w,
                      child: const TextP1('Usuarios asignados',
                        size: 3.8,
                        textAlign: TextAlign.center
                      ),
                  ),
                  SizedBox(width: 7.w,
                      child: GestureDetector(
                          onTap: () => _controller.next(ref),
                          child: Icon( Icons.check_box_rounded, color: kGreen, size: 6.w)
                      )),
            ]);
          }
          return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 7.w),
                SizedBox( width: 60.w,
                 child: const TextP1('Usuarios no asignados',
                     size: 3.8,
                     textAlign: TextAlign.center
                )),
                SizedBox(width: 7.w,
                    child: GestureDetector(
                        onTap: () => _controller.next(ref),
                        child: Icon(Icons.indeterminate_check_box_rounded, color: kRed, size: 6.w)
                    )),
          ]);
        }),
        SizedBox(height: 2.h,),
        SizedBox(width: 70.w,
            child: Watcher((context, ref, child) {
              List<User> users = userLogic.getActive(ref) ?? [];
              List<String> filter = ref.watch(_userIdCreator);
              users = _filter(ref, users, filter);
              return SizedBox( height: _getGridSize(users.length).h,
                  child: GridView.count(
                      crossAxisCount: 3,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.8, /** Makes child non a Square */
                      children:List.generate(users.length, (index) {
                        return _BasicUserTile(
                            user: users[index],
                            onTap: (value) => onTap(value),
                            active: filter.contains(users[index].id)
                        );
                      })
                  ));
            })
        ),
      ],
    );
  }
}
//active ? _controller.remove(context.ref, user.id) : _controller.add(context.ref, user.id),
class _BasicUserTile extends StatelessWidget {
  const _BasicUserTile({required this.user,required this.onTap,  required this.active, Key? key}) : super(key: key);
  final User user;
  final bool active;
  final Function(List<String> value) onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (){
          active ? _controller.remove(context.ref, user.id) : _controller.add(context.ref, user.id);
          onTap(_controller.get(context.ref));
        },
        child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.w),
                      border: Border.all(
                          color: active ? kGreen : kBlack.withOpacity(0),
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
                  ))
            ])
    );
  }
}