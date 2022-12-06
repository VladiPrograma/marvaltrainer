import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../constants/string.dart';
import '../constants/theme.dart';
import 'inner_border.dart';
import '../utils/marval_arq.dart';


/// Custom TextField

class MarvalInputTextField extends StatelessWidget {
  const MarvalInputTextField({Key? key,
    this.controller,
    this.maxLines,
    this.maxLength,
    this.readOnly,
    this.initialValue,
    this.width,
    this.labelText,
    this.labelIcon,
    this.onTap,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.hintText,
    this.keyboardType,
    this.prefixIcon,
    this.obscureText,
    this.suffixIcon
  }) : super(key: key);

  final double? width;
  final int? maxLines;
  final int? maxLength;
  final String? initialValue;
  final String? labelText;
  final Widget? labelIcon;
  final String? hintText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool? obscureText;
  final String? Function(String? value)? validator;
  final Function(String? value)? onSaved;
  final Function()? onTap;
  final Function(String? value)? onChanged;
  final TextEditingController? controller;
  final bool? readOnly;

  @override
  Widget build(BuildContext context) {
    return Focus(
        child: Builder(
            builder: (context) {
              final bool hasFocus = Focus.of(context).hasFocus;
              return Column(
                children: [
                  /** Text field */
                  SizedBox(
                      width: width ?? 70.w,
                      child:  TextFormField(
                        controller: controller,
                        readOnly: readOnly ?? false,
                        cursorColor: kWhite,
                        keyboardType: keyboardType ?? TextInputType.text,
                        obscureText: obscureText ?? false,
                        initialValue: initialValue,
                        maxLines: maxLines ?? 1,
                        maxLength: maxLength,
                        style: TextStyle( fontFamily: p1, color: hasFocus ? kWhite : kBlack, fontSize: 4.w),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: hasFocus ? kGreen: kWhite,
                            label: hasFocus ?
                            Container(
                                margin: EdgeInsets.only(bottom: labelIcon!=null ? 3.5.h : 2.3.h),
                                child: labelIcon != null ?
                                Row( children: [
                                    labelIcon!,
                                    SizedBox(width: 2.w,),
                                    TextP1( labelText ?? "", color: kBlack )
                                ])
                                :
                                TextP1( labelText ?? "", color: kBlack  ))
                                : // NO Focus
                            labelText != null ?
                            labelIcon != null && controller!=null && controller!.text.isNotEmpty ?
                              Row(children: [
                                    labelIcon!,
                                    SizedBox(width: 2.w,),
                                    TextP1( labelText ?? "", color: kBlack )
                              ])
                                :
                            TextP1(labelText!, color: kBlack)
                                :
                            const SizedBox.shrink(),
                            border: DecoratedInputBorder(
                              child:  OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(Radius.circular(4.w)),
                              ),
                              shadow: BoxShadow(
                                color: kBlack.withOpacity(0.45),
                                offset: Offset(0, 1.3.w),
                                blurRadius: 2.1.w,
                              ),
                            ),
                            hintText: hintText,
                            hintStyle:  TextStyle(fontFamily: p1, color: hasFocus ? kGreenThi : kGrey, fontSize: 4.w),
                            prefixIcon: prefixIcon!=null ? Icon( prefixIcon, color: hasFocus ? kWhite : kGreen,size: 7.w,) : null,
                            suffixIcon: suffixIcon,
                            errorStyle: TextStyle(fontSize: 3.w, fontFamily: h2, color: kRed, overflow: TextOverflow.visible),
                            errorMaxLines: 2

                        ),
                        validator: (value) {
                          if (validator == null) {  return null;  }
                          return validator!(value);
                        },
                        onSaved:(value){ isNotNull(onSaved) ? onSaved!(value) : null;},
                        onChanged: (value){isNotNull(onChanged) ? onChanged!(value):null;},
                        onTap: (){isNotNull(onTap) ? onTap!() : null;},
                      )),
                ],
              );}));
  }
}




