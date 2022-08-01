import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/theme.dart';
import '../../constants/components.dart';

import '../../utils/marval_arq.dart';
import '../../utils/objects/user.dart';
import '../../utils/objects/user_handler.dart';


/// @TODO Configure in Firebase The Reset Password Email
/// @TODO Add common Profile Photo to Storage and let URL on User.create

UserHandler handler = UserHandler.create();

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = "/home";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Container(
          child: Container( width: 100.w, height: 80.h,
          padding: EdgeInsets.only(top: 6.h),
          child: UserInformation(),
      ))));
  }
}


class UserInformation extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            MarvalUser user = MarvalUser.fromJson(map);
            handler.addUser(user);
            return MarvalUserTile(user: user);
          }).toList(),
        );
      },
    );
  }
}

class MarvalUserTile extends StatelessWidget {
  const MarvalUserTile({required this.user, Key? key}) : super(key: key);
  final MarvalUser user;
  @override
  Widget build(BuildContext context) {
    double diff = user.currWeight - user.lastWeight;
    return Container(width: 100.w, height: 15.h,
    padding: EdgeInsets.symmetric(horizontal: 2.5.w),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Container( width: 60.w,
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Container(
        decoration: BoxDecoration(
          boxShadow: [kDarkShadow],
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
            TextH2("${user.name.maxLength(20)}", size: 4, ),
            TextP2("  ${user.work.maxLength(19)}", color: kGrey,size: 3),
            TextP2("  Recomposicion", color: kGrey, size: 3,),
          ],
        )],)),
        Container(width: 35.w,
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
    ));
  }
}


