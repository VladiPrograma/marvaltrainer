import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../config/custom_icons.dart';
import '../constants/colors.dart';
import '../constants/global_variables.dart';
import '../constants/theme.dart';
import '../core/login/login_screen.dart';
import '../utils/marval_arq.dart';

class MarvalDrawer extends StatelessWidget {
  const MarvalDrawer({required this.name, Key? key}) : super(key: key);
  final String name;
  @override
  Widget build(BuildContext context) {
    final String userName = authUser!.displayName!;
    return Drawer(
      backgroundColor: kWhite,
      child: Container( height: 100.h,
        child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        children:  <Widget>[
          SizedBox(height: 39.h,
              child: DrawerHeader(
                decoration: BoxDecoration( color: kWhite, border: Border.all(color: kWhite) ),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: isNotNull(authUser!.photoURL) ? Image.network(authUser!.photoURL!).image : null,
                      backgroundColor: kBlack,
                      radius: 9.h,
                      child: isNull(authUser!.photoURL) ? Icon(CustomIcons.person, color: kWhite, size: 13.w,): null,
                    ),
                    const TextH2('Bienvenido', color: kGrey, size: 6,),
                    TextH1(userName.length<13 ? userName : userName.substring(0,13), color: kBlack, size: 8, textOverFlow: TextOverflow.clip ,),
                  ],
                ),
              )),
          GestureDetector(
            onTap: (){},
            child: ListTile(
              leading: Icon(Icons.home_rounded,color: name=="Home" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Home', size: 4, color: name=="Home" ? kGreen : kBlack),
            ),
          ),
          GestureDetector(
            onTap: (){},
            child: ListTile(
              leading: Icon(Icons.message_outlined,color: name=="Chat" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Chat', size: 4, color: name=="Chat" ? kGreen : kBlack),
            ),
          ),
          GestureDetector(
            onTap: (){},
            child: ListTile(
              leading: Icon(Icons.run_circle_outlined,color: name=="Ejercicios" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Ejercicios', size: 4, color: name=="Ejercicios" ? kGreen : kBlack),
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.pop(context);
              Navigator.pushNamed(context, LoginScreen.routeName);},
            child: ListTile(
              leading: Icon(CustomIcons.person ,color: name=="Perfil" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Perfil', size: 4, color: name=="Perfil" ? kGreen : kBlack),
            ),
          ),
          GestureDetector(
            onTap: (){ },
            child: ListTile(
              leading: Icon(Icons.settings_rounded,color: name=="Ajustes" ? kGreen : kBlack, size: 6.w,),
              title: TextH2('Ajustes', size: 4, color: name=="Ajustes" ? kGreen : kBlack),
            ),
          ),
          SizedBox(height: 10.h,),
          Container( height: 15.h,
            child: Image.asset('assets/images/marval_logo.png'),)
        ],
      ),
    ));
  }
}