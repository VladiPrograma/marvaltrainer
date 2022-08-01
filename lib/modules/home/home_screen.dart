import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/utils/objects/user_handler.dart';

import 'package:sizer/sizer.dart';


import '../../constants/colors.dart';
import '../../utils/objects/user.dart';


/// TODO Configure in Firebase The Reset Password Email

UserHandler handler = UserHandler.create();

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = "/home";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
          child: Container( width: 100.w, height: 100.h,
          padding: EdgeInsets.only(top: 6.h),
          child: UserInformation(),
      )));
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
            logInfo(map);
            MarvalUser user = MarvalUser.fromJson(map);
            handler.addUser(user);
            return ListTile(
              title: Text(map['name']),
              subtitle: Text(map['work']),
            );
          }).toList(),
        );
      },
    );
  }
}



