import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/screens/testing/testing_screen.dart';
import 'package:marvaltrainer/widgets/cached_avatar_image.dart';

import 'package:sizer/sizer.dart';

import '../config/custom_icons.dart';
import '../constants/colors.dart';
import '../constants/global_variables.dart';
import '../constants/theme.dart';
import '../screens/chat/chat_global_screen.dart';
import '../screens/habits/habits_screen_global.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../utils/extensions.dart';

class MarvalDrawer extends StatelessWidget {
  const MarvalDrawer({required this.name, Key? key}) : super(key: key);
  final String name;
  @override
  Widget build(BuildContext context) {

    void removeScreens(String routeName){
      while(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.pushNamed(context, routeName);
    }

    return Drawer(
      backgroundColor: kWhite,
      child: SizedBox( height: 100.h,
        child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        children:  <Widget>[
          /// Header
          Watcher((context, ref, child) {
                User? user = userLogic.getAuthUser(ref);
                return SizedBox(height: 38.h,
                    child: DrawerHeader(
                      decoration: BoxDecoration( color: kWhite, border: Border.all(color: kWhite) ),
                      child: Column(
                        children: [
                          CachedAvatarImage(url: user?.profileImage ?? '', size: 9),
                          const TextH2('Bienvenido', color: kGrey, size: 6,),
                          TextH1(user?.name.maxLength(13) ?? "" , color: kBlack, size: 7.5, textOverFlow: TextOverflow.clip ,),
                        ],
                      ),
                    ));
              }),
          /// Home
          GestureDetector(
            onTap: () => removeScreens(HomeScreen.routeName),
            child: ListTile(
              leading: Icon(CustomIcons.address_book, color: name=="Usuarios" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Usuarios', size: 4, color: name=="Usuarios" ? kGreen : kBlack),
            ),
          ),
          /// Chat
          GestureDetector(
            onTap: () => removeScreens(ChatGlobalScreen.routeName),
            child: ListTile(
              leading: Icon(CustomIcons.chat_empty, color: name=="Chat" ? kGreen : kBlack, size: 6.w,),
              title: Watcher((context, ref, _) {
                int unread = messagesLogic.getUnread(ref).length;
                if(unread > 999) unread = 999;
                return Row( children: [
                  TextH2('Chat', size: 4, color: name == "Chat" ? kGreen : kBlack),
                  SizedBox(width: 3.w,),
                  unread == 0 ?
                  const SizedBox()
                  :
                  CircleAvatar( radius: 2.3.w, backgroundColor: kRed, child: TextH1('$unread', color: kWhite, size: 2,),)
                ]);
              }),
            ),
          ),
          /// Habitos
          GestureDetector(
            onTap: () => removeScreens(HabitsScreenGlobal.routeName),
            child: ListTile(
              leading: Icon(CustomIcons.habits,color: name=="Habitos" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Habitos', size: 4, color: name=="Habitos" ? kGreen : kBlack),
            ),
          ),
          /// Ejercicios
          GestureDetector(
            onTap: () => removeScreens(HomeScreen.routeName),
            child: ListTile(
              leading: Icon(CustomIcons.gym,color: name=="Ejercicios" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Ejercicios', size: 4, color: name=="Ejercicios" ? kGreen : kBlack),
            ),
          ),
          /// Entrenos
          GestureDetector(
            onTap: () => removeScreens(TestingScreen.routeName),
            child: ListTile(
              leading: Icon(CustomIcons.muscle_up ,color: name=="Entrenos" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Entrenos', size: 4, color: name=="Entrenos" ? kGreen : kBlack),
            ),
          ),
          /// Ajustes
          GestureDetector(
            onTap: () => removeScreens(SettingScreen.routeName),
            child: ListTile(
              leading: Icon(Icons.settings_rounded,color: name=="Ajustes" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Ajustes', size: 4, color: name=="Ajustes" ? kGreen : kBlack),
            ),
          ),
          SizedBox( height: 12.h,
            child: Image.asset('assets/images/marval_logo.png'),)
        ],
      ),
    ));
  }
}
