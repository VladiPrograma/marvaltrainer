import 'package:creator/creator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/firebase/users/dto/user_active.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/widgets/cached_avatar_image.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/extensions.dart';
import '../../../utils/objects/user.dart';
import '../../../constants/theme.dart' ;
import '../../../constants/string.dart';
import '../../../constants/colors.dart';
import '../../../constants/components.dart';
import '../../../constants/global_variables.dart';
import '../../../widgets/inner_border.dart';
import '../../../widgets/marval_drawer.dart';

Creator<String> _searchCreator = Creator.value('');

class ActivateUserScreen extends StatelessWidget {
  const ActivateUserScreen({Key? key}) : super(key: key);
  static String routeName = "/activate_users";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: kWhite,
        drawer: const MarvalDrawer(name: "Ajustes",),
        resizeToAvoidBottomInset: false,
        body: SizedBox( width: 100.w, height: 100.h,
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
                          child: Center(child: TextH1('Alta y Baja', size: 13,
                            color: Colors.black.withOpacity(0.7),
                            shadows: [
                              BoxShadow(color: kWhite.withOpacity(0.4), offset: const Offset(0, 2), blurRadius: 15)
                            ],))
                      )
                  ),
                  /// List Tiles
                  Positioned(
                    bottom: 0,
                    child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topRight:  Radius.circular(10.w),
                            topLeft: Radius.circular(10.w)
                        ),
                        child: Container( width: 100.w, height: 80.5.h,
                            color: kWhite,
                            child: UserList()
                        )),
                  ),
                  ///TextField
                  Positioned(
                    top: 16.5.h,
                    left: 12.5.w,
                    child: SizedBox(width: 75.w, height: 10.h,
                        child:  TextField(
                          cursorColor: kGreen,
                          style: TextStyle( fontFamily: p1, color: kBlack, fontSize: 4.w),
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
                              contentPadding: EdgeInsets.zero
                          ),
                          onChanged: (value) => context.ref.update(_searchCreator, (name) => value),
                        )),
                  )
                ],
              ),
            ));
  }
}

/// Charging data on INIT
/// @TODO Change ValueListenable with Creator and Emitter states.
class UserList extends StatelessWidget {
  const UserList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Watcher((context, ref, child){
      List<UserActiveDTO> users = userLogic.getUserAlta(ref, ref.watch(_searchCreator)) ?? [];
      return ListView.builder(
        itemCount: users.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _UserTile(user: users[index]);
        },
      );
    });
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, Key? key}) : super(key: key);
  final UserActiveDTO user;
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, height: 12.h,
        padding: EdgeInsets.only(left: 6.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                    boxShadow: [kMarvalHardShadow],
                    borderRadius: BorderRadius.circular(100.w)
                ),
                child: CachedAvatarImage(
                  url: user.img,
                  size: 5,
            )),
            SizedBox(width: 3.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              TextH2('${user.name.removeIcon()} ${user.lastName}  ${user.name.getIcon()}'.maxLength(20), size: 3.6, ),
              Padding(padding: EdgeInsets.only(left: 3.w), child: UserSwitcher(user: user),)
            ])
          ]));
  }
}


class UserSwitcher extends StatefulWidget {
  const UserSwitcher({required this.user, Key? key}) : super(key: key);
  final UserActiveDTO user;
  @override
  State<UserSwitcher> createState() => _UserSwitcherState();
}
class _UserSwitcherState extends State<UserSwitcher> {
  @override
  Widget build(BuildContext context) {
    return  CupertinoSwitch(
        activeColor: kGreen,
        value: widget.user.active,
        onChanged: (value) {
          setState(() {
            userLogic.updateActive(widget.user.id, !widget.user.active);
          });
        },
    );
  }
}
