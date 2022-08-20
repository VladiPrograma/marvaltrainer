import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/modules/home/profile/logic.dart';
import 'package:marvaltrainer/modules/home/profile/profile_screen.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/components.dart';
import '../../constants/global_variables.dart';
import '../../constants/string.dart';
import '../../constants/theme.dart';

import '../../utils/decoration.dart';
import '../../utils/marval_arq.dart';
import '../../utils/objects/user.dart';
import '../../widgets/marval_drawer.dart';


/// @TODO Configure in Firebase The Reset Password Email
/// @TODO Add common Profile Photo to Storage and let URL on User.create
/// @TODO Change the Details hobbie to User Hobbie

List<MarvalUser>? _getMarvalUserList(Ref ref){
  final query = ref.watch(handlerEmitter.asyncData).data;
  if(isNull(query)||query!.size==0){ return null; }

  //Pass data from querySnapshot to Messages
  final List<MarvalUser> list = queryToData(query).whereType<MarvalUser>().toList();
  String name = ref.watch(_searchCreator);
  return list.where((user) => user.name.toLowerCase().contains(name)).toList();
}
Creator<String> _searchCreator = Creator.value('');


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = "/home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      resizeToAvoidBottomInset: false,
      drawer: const MarvalDrawer(name: 'Usuarios',),
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
                        contentPadding: EdgeInsets.zero
                    ),
                      onChanged: (value) {
                        context.ref.update(_searchCreator, (name) => value.toLowerCase());
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
      var data = _getMarvalUserList(ref);
      if(isNullOrEmpty(data)){ return const SizedBox(); }
      return ListView.builder(
        itemCount: data!.length,
        itemBuilder: (context, index) {
          return MarvalUserTile(user: data[index]);
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
    double diff = user.currWeight - user.lastWeight;
    return GestureDetector(
      onTap: (){
        context.ref.update(userCreator, (p0) => user);
        Navigator.pushNamed(context, ProfileScreen.routeName);
        },
      child: Container(width: 100.w, height: 12.h,
          padding: EdgeInsets.symmetric(horizontal: 2.5.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox( width: 60.w,
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
                          TextP2("  ${user.hobbie.maxLength(19)}", color: kGrey, size: 3,),
                        ],
                      )],)),
              SizedBox(width: 35.w,
                child: Row(children: [
                  TextH1(user.currWeight.toString(), size: 7, height: 0.5.w, textAlign: TextAlign.end),
                  Spacer(),
                  Icon(diff>0 ? Icons.arrow_drop_up_outlined : diff == 0 ? Icons.arrow_left_outlined : Icons.arrow_drop_down_outlined,
                    color: diff>0 ? kRed : diff == 0 ? kGrey : kGreen,
                    size: 6.w,
                  ),
                  TextH2( diff.abs()<1 ? diff.abs().toStringAsPrecision(1) : diff.abs().toStringAsPrecision(2),
                    color: diff>0 ? kRed : diff == 0 ? kGrey : kGreen,
                    size: 3.2,)
                ]),)],
          )),
    );
  }
}


