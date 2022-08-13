import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/modules/ajustes/settings_screen.dart';
import 'package:marvaltrainer/modules/alta/add_users_screen.dart';
import 'package:marvaltrainer/modules/chat/chat_logic.dart';
import 'package:sizer/sizer.dart';

import '../config/custom_icons.dart';
import '../constants/colors.dart';
import '../constants/global_variables.dart';
import '../constants/theme.dart';
import '../core/login/login_screen.dart';
import '../modules/chat/chat_global_screen.dart';
import '../modules/home/home_screen.dart';
import '../utils/marval_arq.dart';
import '../utils/objects/user.dart';




class MarvalDrawer extends StatelessWidget {
  const MarvalDrawer({required this.name, Key? key}) : super(key: key);
  final String name;
  @override
  Widget build(BuildContext context) {
    final String userName = authUser.displayName!;
    return Drawer(
      backgroundColor: kWhite,
      child: SizedBox( height: 100.h,
        child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        children:  <Widget>[
          /// Header
          SizedBox(height: 39.h,
              child: DrawerHeader(
                decoration: BoxDecoration( color: kWhite, border: Border.all(color: kWhite) ),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: isNotNull(authUser.photoURL) ? Image.network(authUser.photoURL!).image : null,
                      backgroundColor: kBlack,
                      radius: 9.h,
                      child: isNull(authUser.photoURL) ? Icon(CustomIcons.person, color: kWhite, size: 13.w,): null,
                    ),
                    const TextH2('Bienvenido', color: kGrey, size: 6,),
                    TextH1(userName.length<13 ? userName : userName.substring(0,13), color: kBlack, size: 8, textOverFlow: TextOverflow.clip ,),
                  ],
                ),
              )),
          /// Dar de alta
          GestureDetector(
            onTap: () => Navigator.popAndPushNamed(context, AddUserScreen.routeName),
            child: ListTile(
              leading: Icon(CustomIcons.users,color: name=="Dar de alta" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Dar de alta', size: 4, color: name=="Dar de alta" ? kGreen : kBlack),
            ),
          ),
          /// Home
          GestureDetector(
            onTap: () => Navigator.popAndPushNamed(context, HomeScreen.routeName),
            child: ListTile(
              leading: Icon(CustomIcons.address_book, color: name=="Usuarios" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Usuarios', size: 4, color: name=="Usuarios" ? kGreen : kBlack),
            ),
          ),
          /// Chat
          GestureDetector(
            onTap: (){ Navigator.popAndPushNamed(context, ChatGlobalScreen.routeName);},
            child: ListTile(
              leading: Icon(CustomIcons.chat_empty, color: name=="Chat" ? kGreen : kBlack, size: 6.w,),
              title: Watcher((context, ref, _) {
                int notifications = 0;
                ///@TODO Change this piece of code
                handler.list.forEach((user) =>
                notifications += getUnreadMessages(ref, user.id) ?? 0);
                return Row( children: [
                  TextH2('Chat', size: 4, color: name == "Chat" ? kGreen : kBlack),
                  SizedBox(width: 3.w,),
                  notifications == 0 ?
                  const SizedBox()
                  :
                  CircleAvatar( radius: 2.w, backgroundColor: kRed, child: TextH1('$notifications', color: kWhite, size: 2,),)
                ]);
              }),
            ),
          ),
          /// Ejercicios
          GestureDetector(
            onTap: (){ Navigator.popAndPushNamed(context, LoginScreen.routeName);},
            child: ListTile(
              leading: Icon(CustomIcons.gym,color: name=="Ejercicios" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Ejercicios', size: 4, color: name=="Ejercicios" ? kGreen : kBlack),
            ),
          ),
          /// Entrenos
          GestureDetector(
            onTap: (){
              Navigator.popAndPushNamed(context, LoginScreen.routeName);},
            child: ListTile(
              leading: Icon(CustomIcons.muscle_up ,color: name=="Entrenos" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Entrenos', size: 4, color: name=="Entrenos" ? kGreen : kBlack),
            ),
          ),
          /// Ajustes
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(SettingScreen.routeName, (Route r) => r.settings.name == HomeScreen.routeName);
            },
            child: ListTile(
              leading: Icon(Icons.settings_rounded,color: name=="Ajustes" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Ajustes', size: 4, color: name=="Ajustes" ? kGreen : kBlack),
            ),
          ),
          SizedBox(height: 3.h,),
          SizedBox( height: 15.h,
            child: Image.asset('assets/images/marval_logo.png'),)
        ],
      ),
    ));
  }
}