import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/firebase/users/repository/trainer_users_repo.dart';
import 'package:marvaltrainer/screens/home/alta/add_users_screen.dart';
import 'package:sizer/sizer.dart';

import '../../firebase/users/dto/user_resume.dart';
import '../../screens/home/profile/profile_screen.dart';
import '../../utils/extensions.dart';

import '../../constants/colors.dart';
import '../../constants/global_variables.dart';
import '../../constants/string.dart';
import '../../constants/theme.dart';

import '../../widgets/inner_border.dart';
import '../../widgets/marval_drawer.dart';
import '../../widgets/cached_avatar_image.dart';


/// @TODO Configure in Firebase The Reset Password Email
/// @TODO Add common Profile Photo to Storage and let URL on User.create
/// @TODO Change the Details hobbie to User Hobbie


Creator<String> _searchCreator = Creator.value('');


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = "/home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      resizeToAvoidBottomInset: false,
      drawer: const MarvalDrawer(name: 'Usuarios'),
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
                    child: Center(child: TextH1('Home', size: 13,
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
                      child: const _UsersList()
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
                            //@TODO Add push page animation, from bottom to start.
                            Navigator.pushNamed(context, AddUserScreen.routeName);
                          },
                          child: Icon(Icons.add_reaction, color: kGreen, size: 7.w,),
                        ),
                        contentPadding: EdgeInsets.zero
                    ),
                      onChanged: (value) {
                        context.ref.update(_searchCreator, (name) => value);
                    })
                ))
            ]),
      ));
  }
}

class _UsersList extends StatelessWidget {
  const _UsersList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Watcher((context, ref, child){
      // Get User mapped and filtered by search.
      List<UserResumeDTO> users = userLogic.getUserHome(ref, ref.watch(_searchCreator)) ?? [];
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return MarvalUserTile(user: users[index]);
      });
    });
  }
}
class MarvalUserTile extends StatelessWidget {
  const MarvalUserTile({required this.user, Key? key}) : super(key: key);
  final UserResumeDTO user;
  @override
  Widget build(BuildContext context) {
    double diff = (user.weight ?? 0) - (user.lastWeight ?? 0);
    void openProfilePage(BuildContext context, UserResumeDTO userDTO){
      userLogic.select(context.ref, userLogic.getByID(userDTO.id, context.ref));
      Navigator.push(context, MaterialPageRoute(builder: (context) =>  const ProfileScreen()));
    }

    return GestureDetector(
      onTap: () => openProfilePage(context, user),
      child: Container(width: 100.w, height: 12.h,
          padding: EdgeInsets.symmetric(horizontal: 2.5.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             /// PROFILE IMAGE
             Container(
             margin: EdgeInsets.only(right: 3.w),
             decoration: BoxDecoration(
                 boxShadow: [BoxShadow(
                   color: kBlack.withOpacity(0.8),
                   offset: Offset(0, 1.6.w),
                   blurRadius: 1.4.w,
                 )],
                 borderRadius: BorderRadius.circular(100.w)
             ),
              child: CachedAvatarImage(
               url: user.img,
               size: 5,
             )),
              /// USER DATA
             SizedBox( width: 70.w, height: 12.h,
             child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Row(
               mainAxisAlignment: MainAxisAlignment.start,
               children: [
                 TextH2('${user.name.removeIcon()} ${user.lastName}'.maxLength(16), size: 4, ),
                 SizedBox(width: 4.w,),
                 const Spacer(),
                 TextH1('${user.weight}', size: 4,  textAlign: TextAlign.center),
                 Icon(diff>0 ? Icons.arrow_drop_up_outlined : diff == 0 ? Icons.arrow_left_outlined : Icons.arrow_drop_down_outlined,
                   color: diff>0 ? kRed : diff == 0 ? kGrey : kGreen,
                   size: 6.w,
                 ),
                 TextH2( diff.abs()<1 ? diff.abs().toStringAsPrecision(1) : diff.abs().toStringAsPrecision(2),
                   color: diff>0 ? kRed : diff == 0 ? kGrey : kGreen,
                   size: 3.2,)
               ]),
               SizedBox(height: 0.4.h,),
               TextP2("${user.job.isEmpty ? " - " : user.job} "
                      "  ${user.hobbie.isEmpty ? " - " : user.hobbie}", color: kBlack,size: 3),
               SizedBox(height: 0.2.h,),
               TextP2(user.objective, color: kGrey, size: 3,),
             ]))
    ])));
  }
}

