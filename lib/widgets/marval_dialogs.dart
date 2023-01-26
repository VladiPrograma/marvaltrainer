import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../config/custom_icons.dart';
import '../constants/theme.dart';
import '../utils/marval_arq.dart';
import '../constants/colors.dart';

void MarvalDialogsInfo(BuildContext context, double height, {RichText? richText, String? title}){
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 2.w),
        backgroundColor: Colors.transparent,
        child:  Container(
          width: 100.w, height: height.h,
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(7.w),
          ),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CustomIcons.info, color: kBlue, size: 10.w,),
                  Spacer(),
                  TextH2(title ?? "", color: kBlue,),
                  Spacer(),
                ],
              ),
              SizedBox(height: 2.h,),
              richText ?? SizedBox(),
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  TextButton(onPressed: (){Navigator.pop(context);}, child: TextH2("Entendido", size: 4, color: kBlue,))
                ],
              ),
            ],
          ),
        ),
    ),
  );
}



enum MarvalDialogAlertType {
  DELETE,
  ACCEPT,
  ACTIVATE
}
void MarvalDialogsAlert(BuildContext context, {required MarvalDialogAlertType type, String? title, String? acceptText, String?  cancelText, required double height, RichText? richText, Function()? onAccept, Function()? onCancel}){
  late IconData _icon;
  late String _textButton;
  late Color _textColor;
  late Color _buttonColor;
  if(type == MarvalDialogAlertType.ACCEPT){
    _icon = CustomIcons.info;
    _textButton = acceptText ?? "Aceptar";
    _textColor = kBlue;
    _buttonColor = kBlueThi;
  }
  else if(type == MarvalDialogAlertType.DELETE){
    _icon = CustomIcons.exclamation;
    _textButton =acceptText ?? "Eliminar";
    _textColor = kRed;
    _buttonColor = kRedThi;
  }
  else{
    _icon = CustomIcons.info;
    _textButton = acceptText ?? "Activar";
    _textColor = kGreen;
    _buttonColor = kGreenThi;
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 2.w),
      backgroundColor: Colors.transparent,
      child:  Container(
        width: 100.w, height: height.h,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(7.w),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_icon, color: _textColor, size: 10.w,),
                const Spacer(),
                TextH2(title ?? "", color: _textColor,),
                const Spacer(),
              ],
            ),
            SizedBox(height: 2.h,),
            richText ?? const SizedBox.shrink(),
            const Spacer(),
            Row(
              children: [
                TextButton(
                    onPressed: () =>  onCancel!=null ? onCancel() : null,
                    child: TextH2(cancelText ?? "Cancelar", size: 4, color: _textColor,)),
                const Spacer(),
                TextButton(
                    onPressed: () =>  onAccept!=null ? onAccept() : null,
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.3.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.w)),
                          color: _buttonColor,
                        ),
                        child:  TextH2(_textButton, size: 4, color: _textColor,)),
                )
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void MarvalDialogsInput(BuildContext context, { required String title, required double height, required Form form, required RichText richText, Function()? onSuccess}){
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 2.w),
      backgroundColor: Colors.transparent,
      child:  Container(
        width: 100.w, height: height.h,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(7.w),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CustomIcons.info, color: kGreen, size: 10.w,),
                Spacer(),
                TextH2(title , color: kBlack,),
                Spacer(),
              ],
            ),
            SizedBox(height: 2.h,),
            richText,
            Spacer(),
            form,
            Spacer(),
            Row(
              children: [
                TextButton(onPressed: (){Navigator.pop(context);}, child: TextH2("Cancelar", size: 4, color: kGreySec,)),
                Spacer(),
                TextButton(
                    onPressed: (){
                      GlobalKey<FormState> _formKey = form.key as GlobalKey<FormState>;
                      if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if(isNotNull(onSuccess)){ onSuccess!(); }
                          Navigator.pop(context);
                      }},
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.3.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.w)),
                          color: kGreenThi,

                        ),
                        child:  TextH2("Enviar", size: 4, color: kGreen,)))
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void MarvalImageAlert(BuildContext context, {required XFile image, String? title, Function()? onAccept}){
   IconData _icon =CustomIcons.info;
   Color _textColor =kBlue;
   Color _buttonColor =kBlueThi;
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 2.w),
      backgroundColor: Colors.transparent,
      child:  Container(
        width: 90.w, height: 50.h,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(7.w),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_icon, color: _textColor, size: 6.w,),
                const Spacer(),
                TextH2(title ?? "", color: _textColor, size: 4,),
                const Spacer(),
              ],
            ),
            SizedBox(height: 2.h,),
            ClipRRect(
                borderRadius: BorderRadius.circular(12.w),
                child: SizedBox(width: 72.w, height: 32.5.h,
                     child:  Image.file(File(image.path),
                      fit: BoxFit.cover,
            ))),
            SizedBox(height: 1.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: (){Navigator.pop(context);}, child: TextH2("Cancelar", size: 3.3, color: _textColor,)),
                TextButton(
                  onPressed: () async{
                    Navigator.pop(context);
                    if(isNotNull(onAccept)){  onAccept!();  }
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4.w)),
                        color: _buttonColor,
                      ),
                      child:  TextH2("Enviar", size: 3.3, color: _textColor,)),
                )
              ],
            ),
          ],
        ),
      ),
    ),
  );
}