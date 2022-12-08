import 'dart:collection';
import 'dart:math';

import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:marvaltrainer/config/custom_icons.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/config/screen_args_data.dart';
import 'package:marvaltrainer/constants/components.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/firebase/exercises/logic/exercise_logic.dart';
import 'package:marvaltrainer/firebase/exercises/model/exercise.dart';
import 'package:marvaltrainer/firebase/exercises/model/tags.dart';
import 'package:marvaltrainer/screens/exercise/add_image_screen.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/utils/marval_arq.dart';
import 'package:marvaltrainer/widgets/inner_border.dart';
import 'package:sizer/sizer.dart';

import 'package:marvaltrainer/constants/string.dart';
import 'package:marvaltrainer/constants/colors.dart';
import 'package:marvaltrainer/constants/theme.dart';

import 'package:marvaltrainer/firebase/habits/model/habits.dart';

import 'package:marvaltrainer/widgets/marval_elevated_button.dart';
import 'package:marvaltrainer/widgets/marval_textfield.dart';
import 'package:marvaltrainer/widgets/marval_drawer.dart';

//@Smells
void clearNewExerciseScreen(){
  _exercise = Exercise.empty();
  _tagMap.clear();
  _mapControllers['name']!.clear();
  _mapControllers['description']!.clear();
  _mapControllers['link']!.clear();
  _mapControllers['search']!.clear();
}

//@Smells
Map<String, TextEditingController> _mapControllers = {
  'name' : TextEditingController(),
  'description' : TextEditingController(),
  'link' : TextEditingController(),
  'search' : TextEditingController(),
};

Creator<String> _searchCreator = Creator.value('');
String getSearch(Ref ref)=> ref.watch(_searchCreator);
void setSearch(Ref ref, String text) => ref.update<String>(_searchCreator, (str) => text);

Exercise _exercise = Exercise.empty();

///@TODO Modify dialogs form admit very long descriptions without textoverflow.
class NewExerciseScreen extends StatelessWidget {
  static String routeName = '/exercises/new';
  NewExerciseScreen({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: true,
        drawer: const MarvalDrawer(name: 'Ejercicios',),
        body: SizedBox( width: 100.w, height: 100.h,
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children:<Widget> [
                  SizedBox(height: 2.h),
                  // Title
                  Row(
                      children: [
                        GestureDetector(
                            onTap: (){ Navigator.pop(context);},
                            child: SizedBox(width: 10.w,
                                child: Icon(Icons.keyboard_arrow_left, color: kBlack, size: 9.w)
                        )),
                        Center(child: SizedBox(width: 80.w, child: const TextH2( "Añadir Ejercicio", textAlign: TextAlign.center,))),
                      ]),
                  SizedBox(height: 1.h),
                  Form( key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 3.5.h,),
                          MarvalInputTextField(
                            width: 70.w,
                            hintText: "Nombre",
                            labelText: "Nombre",
                            labelIcon: Icon(CustomIcons.person, color: kGreen, size: 6.w,),
                            controller: _mapControllers['name'],
                            onSaved: (value) => _exercise.name = value ?? '',
                            validator: (value){
                              if(isNullOrEmpty(value)){ return kEmptyValue; }
                              if(value!.length>50)    { return "{$kToLong 50}";     }
                              return null;
                            },
                          ),
                          SizedBox(height: 3.5.h,),
                          MarvalInputTextField(
                            width: 70.w,
                            maxLines: 6,
                            hintText: "Descripcion",
                            labelText: "Descripcion",
                            labelIcon: Icon(CustomIcons.bolt, color: kGreen, size: 8.w,),
                            controller: _mapControllers['description'],
                            onSaved: (value) => _exercise.description = value ?? '',
                            validator: (value){
                              if(isNullOrEmpty(value)){ return kEmptyValue; }
                              if(value!.length>1000)    { return "{$kToLong 1000";     }
                              return null;
                            },
                          ),
                          SizedBox(height: 3.5.h,),
                          MarvalInputTextField(
                            width: 70.w,
                            hintText: "Enlace",
                            labelText: "Enlace",
                            labelIcon: Icon(Icons.link, color: kGreen, size: 6.w,),
                            controller: _mapControllers['link'],
                            onSaved: (value) => _exercise.link = value ?? '',
                            validator: (value){
                              if(isNullOrEmpty(value)){ return kEmptyValue; }
                              if( !Uri.parse(value!).isAbsolute)    { return r'No es un enlace valido.';     }
                              return null;
                            },
                          ),
                          SizedBox(height: 3.h,),
                        ],
                      )),
                  //Search InputTextField
                  SizedBox( width: 70.w,
                    child: TextField(
                        style: TextStyle(
                            fontFamily: p1,
                            color: kBlack,
                            fontSize: 4.w
                        ),
                        cursorColor: kGreen,
                        controller: _mapControllers['search'] ,
                        scrollPadding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 1.h),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: kWhite,
                            border: DecoratedInputBorder(
                              child:  OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4.w),
                                  topRight: Radius.circular(4.w),
                                ),
                              ),
                              shadow: BoxShadow(
                                color: kBlack.withOpacity(0.45),
                                offset: Offset(0, 1.3.w),
                                blurRadius: 2.1.w,
                              ),
                            ),
                            hintText: 'Buscar',
                            hintStyle:  TextStyle(fontFamily: p1, color: kBlack, fontSize: 4.w),
                            prefixIcon: GestureDetector(
                              onTap: (){
                                //@TODO Filter search by selected and un selected
                              },
                              child: Icon(Icons.search_rounded, color: kGrey,size: 6.w,),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                String newTag = getSearch(context.ref);
                                exerciseLogic.addTag(newTag);
                                _mapControllers['search']!.clear();
                                setSearch(context.ref, '');
                              },
                              child: Icon(Icons.add_circle, color: kGreen,size: 6.w,),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 0.5.h)
                        ),
                        onChanged: (value) =>  setSearch(context.ref, value),
                        ),
                  ),
                  TagListView(),
                  SizedBox(height: 6.h,),
                  MarvalElevatedButton("Continuar",
                      onPressed: (){
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                           _tagMap.removeWhere((key, value) => !value);
                           _exercise = Exercise.create(_exercise.name, _exercise.link, _exercise.description, _exercise.imageUrl, [..._tagMap.keys]);
                          Navigator.pushNamed(context, AddImageToExerciseScreen.routeName, arguments: ScreenArguments(exercise: _exercise));
                        }
                      },
                      backgroundColor: MaterialStateColor.resolveWith((states){
                        return states.contains(MaterialState.pressed) ? kGreenSec : kGreen  ;
                      })
                  ),
                  SizedBox(height: 2.h,),
                ]),
            )),
        ));
  }
}



class TagListView extends StatelessWidget {
  const TagListView({Key? key}) : super(key: key);

  List<String> getFilerTags(Ref ref){
    Tags tags = exerciseLogic.getTags(ref) ?? Tags.empty();
    List<String> list = tags.values;
    String filter = getSearch(ref);
   return filter.isNotEmpty
        ? list.where((tag) => tag.contains(filter.capitalize())).toList()
        : list;
  }

  @override
  Widget build(BuildContext context) {
    return  Container(width: 70.w, height: 15.h,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(4.w),
          bottomRight: Radius.circular(4.w),
        ),
        color: kWhite,
        boxShadow: [kMarvalBoxShadow]
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Watcher((context, ref, child) {
        List<String> tags = getFilerTags(ref);
        return ClipRRect(
          borderRadius: BorderRadius.circular(4.w),
          child: Wrap(
            runSpacing: 0.5.h,
            spacing: 0.5.w,
            alignment: WrapAlignment.spaceEvenly,
            children: List.generate(tags.length+2, (index) {
              if(index == 0) return SizedBox(width: 70.w, height: 1.h,);
              if(index == tags.length+1) return SizedBox(width: 70.w, height: 1.h,);
              return TagLabel(tag: tags[index-1]);
            }
          )),
        );
      })
      ),
    );
  }
}

Map<String, bool> _tagMap = {};
class TagLabel extends StatefulWidget {
  const TagLabel({required this.tag, Key? key}) : super(key: key);
  final String tag;
  @override
  State<TagLabel> createState() => _TagLabelState();
}
class _TagLabelState extends State<TagLabel> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        setState(() {
          if(_tagMap.containsKey(widget.tag)){
            _tagMap[widget.tag] = !_tagMap[widget.tag]!;
          }else{
            _tagMap[widget.tag] = true;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0.7.h, horizontal: 3.w),
        decoration: BoxDecoration(
          color: _tagMap.containsKey(widget.tag) ? _tagMap[widget.tag]! ? kGreen : kBlack : kBlack,
          borderRadius: BorderRadius.circular(2.w)
        ),
        child: TextH2(widget.tag, color: kWhite, size: 3,),
      ),
    );
  }
}




