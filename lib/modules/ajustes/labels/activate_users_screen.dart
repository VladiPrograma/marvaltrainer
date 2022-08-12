import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/extensions.dart';
import '../../../utils/decoration.dart';
import '../../../utils/marval_arq.dart';
import '../../../utils/objects/user.dart';

import '../../../constants/theme.dart' ;
import '../../../constants/string.dart';
import '../../../constants/colors.dart';
import '../../../constants/components.dart';
import '../../../constants/global_variables.dart';

ValueNotifier<List<MarvalUser>> _listNotifier = ValueNotifier(handler.list);
class ActivateUserScreen extends StatelessWidget {
  const ActivateUserScreen({Key? key}) : super(key: key);
  static String routeName = "/activate_users";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        body:  Container(
            child: Container( width: 100.w, height: 100.h,
              child: Stack(
                children: [
                  /// Grass Image
                  Positioned(
                      top: 0,
                      child: Container(width: 100.w, height: 30.h,
                        child: Image.asset('assets/images/grass.png', fit: BoxFit.cover,),
                      )
                  ),
                  /// Home Text H1
                  Positioned(
                      top: 0,
                      child: Container(width: 100.w, height: 20.h,
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
                        borderRadius: BorderRadius.only(topRight:  Radius.circular(10.w), topLeft: Radius.circular(10.w)),
                        child: Container( width: 100.w, height: 80.5.h,
                            color: kWhite,
                            child: UserList()
                        )),
                  ),
                  ///TextField
                  Positioned(
                    top: 16.5.h,
                    left: 12.5.w,
                    child: Container(width: 75.w, height: 10.h,
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
                          onChanged: (value) {
                            ///Search logic
                            _listNotifier.value= handler.list.where((element) =>
                                element.name.
                                toLowerCase().
                                contains(value.toLowerCase()))
                                .toList();
                          },
                        )),
                  )
                ],
              ),
            )));
  }
}

/// Charging data on INIT
/// @TODO Change ValueListenable with Creator and Emitter states.
class UserList extends StatelessWidget {
  const UserList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: _listNotifier, builder: (context, value, child) {
      return ListView.builder(
        itemCount: _listNotifier.value.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return MarvalUserTile(user: _listNotifier.value[index]);
        },
      );
    });
  }
}

class MarvalUserTile extends StatelessWidget {
  const MarvalUserTile({required this.user, Key? key}) : super(key: key);
  final MarvalUser user;
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, height: 12.h,
        padding: EdgeInsets.symmetric(horizontal: 2.5.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container( width: 93.w,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            boxShadow: [kMarvalHardShadow],
                            borderRadius: BorderRadius.circular(100.w)
                        ),
                        child: CircleAvatar(
                          backgroundImage: isNull(user.profileImage) ?
                          null :
                          Image.network(user.profileImage!).image, radius: 5.h,
                          backgroundColor: kBlack,
                        )),
                    SizedBox(width: 2.w,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextH2(user.name.maxLength(20), size: 4, ),
                        TextP2("  ${user.work.maxLength(19)}", color: kGrey,size: 3),
                        TextP2("  ${user.hobbie?.maxLength(19)}", color: kGrey, size: 3,),
                    ]),
                    Spacer(),
                    UserSwitcher(user: user),
                  ],)),

          ]));
  }
}


class UserSwitcher extends StatefulWidget {
  const UserSwitcher({required this.user, Key? key}) : super(key: key);
  final MarvalUser user;
  @override
  State<UserSwitcher> createState() => _UserSwitcherState();
}

class _UserSwitcherState extends State<UserSwitcher> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 3.h),
      child:  CupertinoSwitch(
        activeColor: kGreen,
        value: widget.user.active,
        onChanged: (value) {
          setState(() {
            widget.user.updateActive();
          });
        },
      ),
    );
  }
}
