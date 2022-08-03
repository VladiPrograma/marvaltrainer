import 'package:flutter/material.dart';
import 'package:marvaltrainer/constants/components.dart';
import 'package:marvaltrainer/constants/theme.dart';
import 'package:marvaltrainer/widgets/marval_snackbar.dart';
import 'package:sizer/sizer.dart';

import '../../config/custom_icons.dart';
import '../../constants/colors.dart';
import '../../constants/string.dart';
import '../../utils/firebase/auth.dart';
import '../../utils/marval_arq.dart';
import '../../utils/objects/user.dart';
import '../../widgets/marval_drawer.dart';
import '../../widgets/marval_elevated_button.dart';
import '../../widgets/marval_textfield.dart';

/// @TODO Improve SignUp methods and normalize data.
/// @TODO Reload Data on user added i can add it from local variable ^^.
/// @TODO Problems when i "Dar de alta" without any value
/// @TODO Re estructure data in MarvalFit
class AddUserScreen extends StatelessWidget {
  const AddUserScreen({Key? key}) : super(key: key);
  static String routeName = "/alta";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: kWhite,
      drawer: MarvalDrawer(name: 'Dar de alta',),
      body: Container( width: 100.w, height: 100.h,
        child: SafeArea(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(top: 4.h),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/images/logo.png"),
                  Container(width: 70.w, margin: EdgeInsets.only(right: 10.w),
                      child: const TextH1( "Bienvenido!")),
                  Container(width: 70.w,margin: EdgeInsets.only(right:10.w),
                      child: const TextH2(
                          'La forma de predecir el futuro es creándolo.',
                          color: kGrey
                      )),
                  SizedBox(height: 5.h,),
                  _LogInForm(),
                ]))),
    ));
  }
}
class _LogInForm extends StatelessWidget {
  const _LogInForm({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String _email= "";
    String _name= "";
    return Form(
        key: _formKey,
        child: Column(
          children: [
            /** INPUT TEXT FIELD*/
            MarvalInputTextField(
              labelText: 'Nombre',
              hintText: "Mario Valgañon",
              prefixIcon: CustomIcons.person,
              keyboardType: TextInputType.name,
              controller: _nameController,
              validator: (value){
                if(isNullOrEmpty(value)){
                  return kInputErrorEmptyValue;
                }if(value!.length>40){
                  return kInputErrorToLong;
                }
                return null;
              },
              onSaved: (value){_name = value!;},
            ),
            SizedBox(height: 3.h,),
            MarvalInputTextField(
              labelText: 'Email',
              hintText: "marvalfit@gmail.com",
              prefixIcon: CustomIcons.mail,
              keyboardType: TextInputType.emailAddress,
              controller: _mailController,
              validator: (value){
                if(isNullOrEmpty(value)){
                  return kInputErrorEmptyValue;
                }if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!)){
                  return kInputErrorEmailMissmatch;
                }
                return null;
              },
              onSaved: (value){_email = value!;},
            ),
            SizedBox(height: 3.h),
             Container(width: 100.w, height: 12.h, child:
             ValueListenableBuilder(
              valueListenable: _notifier,
              builder: (context, value, child) {
              return Column(children: [
              _DropDown(),
              Container(width: 63.w,
              padding: EdgeInsets.only(top: 1.h),
                child:Visibility(
                visible: _notifier.value == _list.first && _validated,
                child: Text('Campo requerido',
                style: TextStyle(fontSize: 3.w, fontFamily: h2, color: kRed, overflow: TextOverflow.visible),)
              ))]);})),
            SizedBox(height: 5.h),
            MarvalElevatedButton(
              "Dar de Alta",
              onPressed:  () async{
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()&&_notifier.value!=_list.first) {
                  _formKey.currentState!.save();
                  _validated = false;
                  bool isRegistered =await MarvalUser.isNotRegistered(_email);
                  if(!isRegistered){
                    // Backend
                    String? _uid = await SignUp(_email, 'temporal1');
                    if(isNull(_uid)){
                      MarvalSnackBar(context, SNACKTYPE.alert, title: "Error al registrar usuario", subtitle: 'No se pudo dar de alta al usuario debido a un error inesperado. Intenta de nuevo mas tarde');
                      return;
                    }
                    MarvalUser _newUser = MarvalUser.create(_uid, normalize(_name)!, _email, _notifier.value);
                    _newUser.setInDB();
                    // Refresh Screen
                    _notifier.value = _list.first;
                    _mailController.clear();
                    _nameController.clear();
                    MarvalSnackBar(context, SNACKTYPE.success, title: "Usuario registrado con exito", subtitle: 'Ya puedes configurar el entrenamiento del usuario.');

                  }
                }else{
                  _validated = true;
                  MarvalSnackBar(context, SNACKTYPE.alert, title: "Error al registrar usuario", subtitle: 'El email proporcionado se encuentra actualmente registrado en la base de datos');
                }
              },
            ),
            SizedBox(height: 5.h,),
          ],
        ));
  }
}

///* VARIABLES */
final List<String> _list = <String>['Elige el objetivo', 'Recomp. Corporal', 'Aumento de Masa', 'Deportista Profesional'];
final TextEditingController _nameController = TextEditingController();
final TextEditingController _mailController = TextEditingController();
final ValueNotifier<String> _notifier = ValueNotifier(_list.first);
bool _validated = false;
class _DropDown extends StatefulWidget {
  const _DropDown({Key? key}) : super(key: key);
  @override
  State<_DropDown> createState() => _DropDownState();
}
class _DropDownState extends State<_DropDown> {

  @override
  Widget build(BuildContext context) {
    return Container( width:  70.w, height: 8.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4.w)),
        color: kWhite,
        boxShadow: [kMarvalBoxShadow]
      ),
      child: Center(child:
        Row(children: [
          SizedBox(width: 2.w),
          Icon(CustomIcons.lightning_bolt, size: 7.w, color: kGreen,),
          SizedBox(width: 2.w),
          DropdownButton<String>(
          style: TextStyle(fontFamily: p1, fontSize: 4.w, color: kBlack),
          borderRadius:BorderRadius.all(Radius.circular(4.w)),
          icon:  const Icon(Icons.arrow_drop_down, color: kBlack),
          underline: Container(),
          value: _notifier.value,
          items: _list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: value == _list.first ?
                Text(value, style: TextStyle(fontFamily: p1, color: kGrey, fontSize: 4.w))
                :
                Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() => _notifier.value = newValue!);
          }
        ),
      ]))
    );
  }
}
