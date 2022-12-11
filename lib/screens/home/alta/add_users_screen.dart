import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/custom_icons.dart';
import 'package:marvaltrainer/firebase/users/dto/user_init.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:sizer/sizer.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/constants/components.dart';
import 'package:marvaltrainer/constants/theme.dart';
import 'package:marvaltrainer/constants/colors.dart';
import 'package:marvaltrainer/constants/string.dart';
import 'package:marvaltrainer/utils/marval_arq.dart';
import 'package:marvaltrainer/widgets/marval_drawer.dart';
import 'package:marvaltrainer/widgets/marval_elevated_button.dart';
import 'package:marvaltrainer/widgets/marval_textfield.dart';

///* THIS PAGE IS COMPLETE //
Creator<String?> _dropDownCreator = Creator.value(null);
 String? _getDropDownValue(Ref ref) => ref.watch(_dropDownCreator);
 void _setDropDownValue(Ref ref, String? value) => ref.update(_dropDownCreator, (t) => value);
 void _clearDropDownValue(Ref ref)=> ref.update(_dropDownCreator, (t) => null);

TextEditingController _nameController = TextEditingController();
TextEditingController _mailController = TextEditingController();
String? _dropDownValue;

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({Key? key}) : super(key: key);
  static String routeName = "/Home/Alta-Usuarios";
  @override
  Widget build(BuildContext context) {
  return Scaffold(
      backgroundColor: kWhite,
      drawer: const MarvalDrawer(name: 'Usuarios',),
      body: SizedBox( width: 100.w, height: 100.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.only(top: 2.h),
        child: SafeArea(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
    final formKey = GlobalKey<FormState>();
    String email = "";
    String name  = "";
    return Form(
        key: formKey,
        child: Column(
          children: [
            /// NAME Label
            MarvalInputTextField(
              labelText   : 'Nombre',
              hintText    : "Mario Valgañon",
              controller  : _nameController,
              prefixIcon  : CustomIcons.person,
              keyboardType: TextInputType.name,
              onSaved     : (value)=> name = value!,
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
              onSaved     : (value) => email = value!,
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
            const _DropDown(),
            Container(width: 63.w, height: 3.h,
             padding: EdgeInsets.only(top: 1.h),
             child: Watcher((context, ref, child) {
              final String? objective = _getDropDownValue(ref);
              return isNotNull(objective) && objective! == 'error' ?
                Text('Campo requerido',
                style: TextStyle(
                  color      : kRed,
                  fontSize   : 3.w,
                  fontFamily : h2,
                  overflow   : TextOverflow.visible
                ))
                :
                const SizedBox.shrink();
             })),
            SizedBox(height: 5.h),
            MarvalElevatedButton(
              "Dar de Alta",
              onPressed:  () async{
                // Validate returns true if the form is valid, or false otherwise.
                if (formKey.currentState!.validate() && _dropDownValue != null && _dropDownValue!.isNotEmpty){
                    formKey.currentState!.save();
                    // Backend
                    String? uid = await authUserLogic.signUp(context, email, true);
                    if(isNotNull(uid)){
                      UserInitDTO userDTO = UserInitDTO(id: uid, name: name, email: email, objective: _dropDownValue!);
                      User user = userDTO.modelFromDTO();
                      userLogic.add(user);
                      clear(context);
                    }
                }
                else{
                  _setDropDownValue(context.ref, 'error');
                }
              }),
            SizedBox(height: 5.h,),
          ],
        ));
  }

  void clear(BuildContext context){
    _clearDropDownValue(context.ref);
    _mailController.clear();
    _nameController.clear();
  }
}

///* VARIABLES */
class _DropDown extends StatelessWidget {
  const _DropDown({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const List<String> labels = <String>['Elige el objetivo', 'Recomp. Corporal', 'Aumento de Masa', 'Deportista Profesional'];

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
            final value = _getDropDownValue(ref);
            return DropdownButton<String>(
              borderRadius : BorderRadius.all(Radius.circular(4.w)),
              underline    : const SizedBox(),
              style : TextStyle(  fontFamily: p1, fontSize: 4.w, color: kBlack),
              icon  : const Icon( Icons.arrow_drop_down, color: kBlack),
              value : labels.contains(value) ? value : labels.first,
              items : labels.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: value == labels.first ?
                  Text(value, style: TextStyle(fontFamily: p1, color: kGrey, fontSize: 4.w))
                  :
                  Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if(newValue == labels.first){
                  _setDropDownValue(ref, null);
                  _dropDownValue = null;
                }else{
                  _setDropDownValue(ref, newValue);
                  _dropDownValue = newValue;
                }
              }
          );}),
        ])));
  }
}

