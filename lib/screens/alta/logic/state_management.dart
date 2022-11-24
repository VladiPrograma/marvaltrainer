import 'package:creator/creator.dart';

Creator<String?> _dropDownCreator = Creator.value(null);

class AddUserStateController{

  String? getDropDownValue(Ref ref) => ref.watch(_dropDownCreator);
  void setDropDownValue(Ref ref, String? value) => ref.update(_dropDownCreator, (t) => value);
  void clearDropDownValue(Ref ref)=> ref.update(_dropDownCreator, (t) => null);




}