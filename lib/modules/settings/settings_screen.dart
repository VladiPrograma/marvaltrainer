import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../config/log_msg.dart';
import '../../config/custom_icons.dart';
import '../../utils/firebase/auth.dart';
import '../../core/login/login_screen.dart';

import '../../constants/theme.dart';
import '../../constants/string.dart';
import '../../constants/colors.dart';
import '../../constants/global_variables.dart';

import '../../widgets/box_user_data.dart';
import '../../widgets/marval_drawer.dart';
import '../../widgets/marval_dialogs.dart';

import 'labels/activate_users_screen.dart';
import 'labels/change_email_screen.dart';
import 'labels/change_password_screen.dart';
import '../home/home_screen.dart';



const _settings = [
  "Cambio de Correo",
  "Cambio de Contraseña",
  "Alta y Baja de Usuarios",
  "Salir"
];
const _settings_icons = [
  CustomIcons.mail,
  CustomIcons.lock,
  CustomIcons.loop,
  Icons.exit_to_app_rounded
];

///@TODO Add icon to make posible change profile photo from this screen.
class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);
  static String routeName = "/settings";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MarvalDrawer(name: "Ajustes",),
      backgroundColor: kWhite,
      body:  SizedBox( width: 100.w, height: 100.h,
      child: Column(
        children:[
        SizedBox(width: 100.w, height: 18.h,
            child: Stack(
            children: [
              /// Grass Image
              Positioned( top: 0,
                  child: SizedBox(width: 100.w, height: 12.h,
                      child: Image.asset('assets/images/grass.png',
                          fit: BoxFit.cover
                      ))),
              ///White Container
              Positioned( top: 8.h,
                  child: Container(width: 100.w, height: 10.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.w),
                              topRight: Radius.circular(10.w)),
                          color: kWhite
                      ))),
              /// User Box Data
              Positioned(  top: 1.h, left: 8.w,
                  child: SafeArea(
                      child: BoxUserData(user: handler.list.where((user) => user.id == authUser.uid).first)
                  )),
            ])),
          SizedBox(width: 100.w, height: 80.h,
              child: ListView.separated(
                itemCount: _settings.length,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(height: 2.h,),
                itemBuilder: (context, index) {
                return SettingTile(name: _settings[index], iconData: _settings_icons[index],
                onTap: () async{
                  logSuccess(_settings[index]);
                  if(_settings[index] == 'Cambio de Contraseña') Navigator.pushNamed(context, ResetPasswordScreen.routeName);
                  if(_settings[index] == 'Cambio de Correo') Navigator.pushNamed(context, ResetEmailScreen.routeName);
                  if(_settings[index] == 'Alta y Baja de Usuarios') Navigator.pushNamed(context, ActivateUserScreen.routeName);
                  if(_settings[index] == 'Salir' ){
                    MarvalDialogsAlert(context, type: MarvalDialogAlertType.DELETE, height: 30,
                    title: '¿ Salir de MarvalTrainer ? ',
                    richText: RichText(text: TextSpan(text: 'Si te desconectas deberas volver a iniciar sesion la proxima vez que entres en la app',
                    style: TextStyle(fontFamily: p2, fontSize: 4.w, color: kBlack ))),
                    acceptText: 'Salir',
                    onAccept: (){
                      logInfo('Saliendo de MarvalTrainer');
                      logOut();
                      Navigator.popAndPushNamed(context, LoginScreen.routeName);
                    }
                  );}
                });
            }))
      ])
    ));
  }
}

/// Settings WIDGET */
class SettingTile extends StatelessWidget {
  const SettingTile({required this.name, required this.iconData, required  this.onTap, Key? key}) : super(key: key);
  final String name;
  final IconData iconData;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ///* Label Icon
          Container(width: 16.w, height: 8.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4.w),
                    bottomLeft: Radius.circular(4.w),
                    bottomRight: Radius.circular(4.w),
                  ),
                  color: kBlue
              ),
              child: Center(child: Icon(iconData, color: kWhite, size: 9.w,)
              )),

          SizedBox(width: 7.w,),
          ///* Label Text
          GestureDetector(
            onTap: () => onTap(),
            child: Container(width: 65.w, height: 8.h,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all( Radius.circular(4.w)),
                  color: kBlueSec ),
              child: Row(
                  children: [
                    TextH2(name, color: kWhite, size: 3.5,),
                    Spacer(),
                    Icon(Icons.arrow_right_rounded, color: kBlue, size: 9.w,)
                  ])),
              )]);
  }
}
