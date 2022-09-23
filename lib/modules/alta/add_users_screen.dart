import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:sizer/sizer.dart';


import '../../config/custom_icons.dart';

import '../../constants/global_variables.dart';
import '../../constants/components.dart';
import '../../constants/theme.dart';
import '../../constants/colors.dart';
import '../../constants/string.dart';

import '../../utils/firebase/auth.dart';
import '../../utils/marval_arq.dart';
import '../../utils/objects/user.dart';

import '../../widgets/marval_snackbar.dart';
import '../../widgets/marval_drawer.dart';
import '../../widgets/marval_elevated_button.dart';
import '../../widgets/marval_textfield.dart';

///* THIS PAGE IS COMPLETE //

late  TextEditingController _nameController;
late  TextEditingController _mailController;

Creator<String> _creator = Creator.value('');
String _getCreator(Ref ref) => ref.watch(_creator);
void _updateCreator(Ref ref, String newObjective) => ref.update(_creator, (t) => newObjective);

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({Key? key}) : super(key: key);
  static String routeName = "/alta";
  @override
  Widget build(BuildContext context) {
    _updateCreator(context.ref, '');
    _nameController = TextEditingController();
    _mailController = TextEditingController();
    logInfo('$logSuccessPrefix Alta Page Rebuilded');
  return Scaffold(
      backgroundColor: kWhite,
      drawer: const MarvalDrawer(name: 'Dar de alta',),
      body: SizedBox( width: 100.w, height: 100.h,
      child: SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.only(top: 2.h),
        child: Column( crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png"),
            Container(width: 70.w,
              margin: EdgeInsets.only(right: 10.w),
              ///@TODO Bienvenido or Bienvenida
              child: const TextH1( "Bienvenido!")),
            Container(width: 70.w,
              margin: EdgeInsets.only(right:10.w),
              child: const TextH2(
                  'La forma de predecir el futuro es creándolo.',
                  color: kGrey
              )),
            SizedBox(height: 5.h,),
            const _LogInForm(),
            SizedBox(height: 3.h,)
          ]))),
    ));
  }
}
class _LogInForm extends StatelessWidget {
  const _LogInForm({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String _email = "";
    String _name  = "";
    return Form(
        key: _formKey,
        child: Column(
          children: [
            /// NAME Label
            MarvalInputTextField(
              labelText   : 'Nombre',
              hintText    : "Mario Valgañon",
              controller  : _nameController,
              prefixIcon  : CustomIcons.person,
              keyboardType: TextInputType.name,
              onSaved     : (value)=> _name = value!,
              validator   : (value){
                if(isNullOrEmpty(value)){
                  return kEmptyValue;
                }if(value!.length>40){
                  return kToLong;
                }
                return null;
            }),
            SizedBox(height: 3.h,),
            /// EMAIL Label
            MarvalInputTextField(
              labelText   : 'Email',
              hintText    : "marvalfit@gmail.com",
              prefixIcon  : CustomIcons.mail,
              keyboardType: TextInputType.emailAddress,
              controller  : _mailController,
              onSaved     : (value) => _email = value!,
              validator   : (value){
                if(isNullOrEmpty(value)){
                  return kEmptyValue;
                }if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!)){
                  return kEmailMissmatch;
                }
                return null;
              },
            ),
            SizedBox(height: 3.h),
            _DropDown(),
            Container(width: 63.w, height: 3.h,
             padding: EdgeInsets.only(top: 1.h),
             child: Watcher((context, ref, child) {
              final String objective = _getCreator(ref);
              return objective == _list.first ?
                Text('Campo requerido',
                style: TextStyle(
                  color      : kRed,
                  fontSize   : 3.w,
                  fontFamily : h2,
                  overflow   : TextOverflow.visible
                ))
                :
                const SizedBox();
             })),
            SizedBox(height: 5.h),
            MarvalElevatedButton(
              "Dar de Alta",
              onPressed:  () async{
                String objective = _getCreator(context.ref);
                logInfo(objective);
                if(isEmpty(objective)){ _updateCreator(context.ref, _list.first);}
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate() && objective!=_list.first && objective.isNotEmpty){
                    _formKey.currentState!.save();
                    // Backend
                    String? _uid = await signUp(_email, 'temporal1');
                    if(isNull(_uid)){
                      MarvalSnackBar(context, SNACKTYPE.alert,
                          title: "Error al registrar usuario",
                          subtitle: 'No se pudo dar de alta al usuario debido a un error inesperado. Intenta de nuevo mas tarde');
                      return;
                    }
                    else if(_uid == kEmailExists){
                      MarvalSnackBar(context, SNACKTYPE.alert,
                          title: "Error al registrar usuario",
                          subtitle: 'El email proporcionado ya se encuentra actualmente registrado en la base de datos');
                    }
                    else {
                      MarvalUser _newUser = MarvalUser.create(
                        uid: _uid,
                        name: _name.normalize(),
                        email: _email,
                        objective: objective,
                      );
                      //Save user in DB
                      _newUser.setInDB();
                      handler.addUser(_newUser);
                      // Refresh Screen
                      _updateCreator(context.ref, '');
                      _mailController.clear();
                      _nameController.clear();
                      // SnackBar
                      MarvalSnackBar(context, SNACKTYPE.success,
                          title: "Usuario registrado con exito",
                          subtitle: 'Ya puedes configurar el entrenamiento del usuario.'
                      );
                    }
              }}),
            SizedBox(height: 5.h,),
          ],
        ));
  }
}

///* VARIABLES */
const List<String> _list = <String>['Elige el objetivo', 'Recomp. Corporal', 'Aumento de Masa', 'Deportista Profesional'];
class _DropDown extends StatelessWidget {
  const _DropDown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container( width:  70.w, height: 8.h,
        decoration: BoxDecoration(
          color: kWhite,
          boxShadow: [kMarvalBoxShadow],
          borderRadius: BorderRadius.all(Radius.circular(4.w)),
        ),
        child: Center(child:
        Row(children: [
          SizedBox(width: 2.w),
          Icon(CustomIcons.lightning_bolt, size: 7.w, color: kGreen,),
          SizedBox(width: 2.w),
          Watcher((context, ref, child){
            final objective = _getCreator(ref);
            return DropdownButton<String>(
              borderRadius : BorderRadius.all(Radius.circular(4.w)),
              underline    : const SizedBox(),
              style : TextStyle(  fontFamily: p1, fontSize: 4.w, color: kBlack),
              icon  : const Icon( Icons.arrow_drop_down, color: kBlack),
              value : isEmpty(objective) ? _list.first : objective,
              items : _list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: value == _list.first ?
                  Text(value, style: TextStyle(fontFamily: p1, color: kGrey, fontSize: 4.w))
                  :
                  Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) { _updateCreator(ref, newValue ?? '');  }
          );}),
        ])));
  }
}

