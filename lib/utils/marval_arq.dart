import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/constants/string.dart';
import 'package:marvaltrainer/utils/extensions.dart';


bool isNull(item) => item==null;

bool isNotNull(item) => item!=null;

bool isEmpty(item) => item.isEmpty;

bool isNotEmpty(item) => item.isNotEmpty;

bool isNullOrEmpty(item) => isNull(item)||isEmpty(item);

bool isNotNullOrEmpty(item) => isNotNull(item)&&isNotEmpty(item);

/// Validations
String? validateNumber(String? value){
  double? number;
  if(isNullOrEmpty(value)){ return kEmptyValue; }
  number = value!.toDouble();
  if(isNull(number)){ return kNotNum; }
  
  if(number!.isNaN||number.isNegative||number>500){
    return kNotNum;
  }
  return null;
}

Map<String, dynamic>? toMap(DocumentSnapshot doc){
  try{  return doc.data() as Map<String, dynamic>; }
  catch(E){  logError(" DocumentSnapshot fails casting to Map<String, dynamic):\n $E"); return null; }
}

/// Search
bool containsArray(List<Object> a, List<Object> b){
  for (var element in b) {
    if(!a.contains(element)){
      return false;
    }
  }
  return true;
}

List<String> getKeywords(String name){
  if(name.length<3) throw ErrorText(' Name has to be more than 3 chars long');
  List<String> res = [];
  res.add(name.substring(0,1));
  res.add(name.substring(0,2));
  res.add(name.substring(0,3));
  return res;
}
void dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();


Function eq = const ListEquality().equals;