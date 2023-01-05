import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/screens/home/profile/widgets/journal_title_row.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/utils/firebase/storage.dart';
import 'package:marvaltrainer/utils/marval_arq.dart';
import 'package:marvaltrainer/widgets/cached_avatar_image.dart';
import 'package:sizer/sizer.dart';

import '../../config/log_msg.dart';
import '../../config/custom_icons.dart';
import '../../utils/firebase/auth.dart';

import '../../constants/theme.dart';
import '../../constants/string.dart';
import '../../constants/colors.dart';
import '../../constants/global_variables.dart';

import '../../widgets/inner_border.dart';
import '../../widgets/marval_drawer.dart';
import '../../widgets/marval_dialogs.dart';

import '../login/login_screen.dart';
import 'labels/activate_users_screen.dart';
import 'labels/change_email_screen.dart';
import 'labels/change_password_screen.dart';
import 'package:image_picker/image_picker.dart';

const _settings = [
  "Cambio de Correo",
  "Cambio de Contraseña",
  "Alta y Baja de Usuarios",
  "Salir"
];
const _settings_icons = [
  CustomIcons.mail,
  CustomIcons.lock,
  CustomIcons.users,
  Icons.exit_to_app_rounded
];

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
        SizedBox(width: 100.w, height: 100.h,
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
                      child: Watcher((context, ref, child) {
                        User? user = userLogic.getAuthUser(ref);
                        if(user == null) return const SizedBox.shrink();
                        return SettingsUserData(user: user);
                      },)
                  )),
              // User Box image icon
              Positioned(  top: 14.5.h, left: 15.5.w,
                  child: Watcher((context, ref, child) {
                    User? user = userLogic.getAuthUser(ref);
                    if(user == null) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () => _selectAndUpdateImage(user.id),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.w),
                            color: kWhite,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 0.2.h, horizontal: 1.4.w),
                          child:  const TextH1('📷', size: 4,)
                      ));
              })),
              /// Activities Background
              Positioned( top: 18.h,
                  child: InnerShadow(
                    color: Colors.black,
                    offset: Offset(0, 0.7.h),
                    blur: 1.5.w,
                    child: Container( width: 100.w, height: 90.h,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: kBlack,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12.w),
                              topLeft: Radius.circular(12.w)
                          ),
                        )),
                  )),
              // Activities Widget
              Positioned( top: 18.h,
                  child:   SizedBox(width: 100.w, height: 80.h,
                  child: ListView.separated(
                      itemCount: _settings.length+1,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => SizedBox(height: 0.3.h,),
                      itemBuilder: (context, index) {
                        if(index == 0) return JournalTitle(name: 'Ajustes', bottomMargin: 2, onTap: () => Navigator.pop(context),);
                        index--;
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
                      }))),
            ])),

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
    return  GestureDetector(
      onTap: () => onTap(),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 8.w,),
          ///* Label Icon
          Container(width: 10.w, height: 5.h,
              decoration: BoxDecoration(
                  boxShadow: [BoxShadow(
                      color: kBlack.withOpacity(0.8),
                      blurRadius: 1.w,
                      offset: Offset(0, 0.3.h)
                  )],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4.w),
                    bottomLeft: Radius.circular(4.w),
                    bottomRight: Radius.circular(4.w),
                  ),
                  color: kBlue
              ),
              child: Center(child: Icon(iconData, color: kWhite, size: 5.w,)
              )),
          SizedBox(width: 2.w,),
          ///* Label Text
          Container(width: 55.w, height: 6.h,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all( Radius.circular(4.w)),
              ),
              child: TextH2(name, color: kWhite, size: 3.5,),
              ),
          Icon(Icons.arrow_circle_right, color: kWhite, size: 5.w,),
          SizedBox(width: 5.w,),
      ]));
  }
}


class SettingsUserData extends StatelessWidget {
  const SettingsUserData({required this.user, Key? key}) : super(key: key);
  final User user;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
         onTap: () => _selectAndUpdateImage(user.id),
         child: CachedAvatarImage(url: user.profileImage, size: 6, expandable: false)
        ),
        SizedBox(width: 5.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h,),
            TextH2('${user.name.removeIcon()} ${user.lastName}', size: 4),
            TextH2(user.work, size: 3, color: kGrey,),
          ],
        )
      ],
    );
  }
}
void _selectAndUpdateImage(String id) async{
  final ImagePicker imagePicker = ImagePicker();
  XFile? profilePhoto;
  // Image picker opens gallery and save ur selection into XFile
  profilePhoto = await imagePicker.pickImage(source: ImageSource.gallery);
  // If selection is any image update.
  if(isNotNull(profilePhoto)){
    await uploadProfileImage(id, profilePhoto!).then((value){
      userLogic.updateImage(id, value);
    });
  }
}
