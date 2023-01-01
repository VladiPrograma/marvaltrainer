import 'package:creator/creator.dart';
import 'package:flutter/cupertino.dart';
import 'package:marvaltrainer/firebase/habits/model/habits.dart';
import 'package:marvaltrainer/utils/marval_arq.dart';

Creator<Habit> _habitCreator = Creator.value(Habit.empty(), keepAlive: true);
Creator<Habit> _initialHabitCreator = Creator.value(Habit.empty());
Creator<bool> _updateCreator = Creator.value(false);

// For MarvalTextFields
Creator<bool> _onChangeUpdateCreator = Creator.value(false);

Creator<String> _searchCreator = Creator.value('');
Creator<String> _searchByUser = Creator.value('');
Creator<bool> _filterCreator = Creator.value(false);

class HabitController {

  Habit get(Ref ref) => ref.watch(_habitCreator);

  void dispose(Ref ref){
    ref.dispose(_habitCreator);
    ref.dispose(_initialHabitCreator);
    ref.dispose(_updateCreator);
    ref.dispose(_onChangeUpdateCreator);
  }

  void initialValue(Ref ref, Habit habit){
    ref.update<Habit>(_habitCreator, (p0) => habit);
    ref.update<Habit>(_initialHabitCreator, (p0) => Habit.clone(habit));
    update(ref);
  }


  void updateUsers(Ref ref, Habit habit, List<String> users){
    habit.users = users;
    update(ref);
  }

  void update(Ref ref) => ref.update<bool>(_updateCreator, (value) => !value);
  void getUpdates(Ref ref) => ref.watch(_updateCreator);

  void getOnChangeUpdates(Ref ref) => ref.watch(_onChangeUpdateCreator);
  void updateOnChange(Ref ref) => ref.update<bool>(_onChangeUpdateCreator, (value) => !value);

  bool hasChange(Ref ref)=> ref.watch(_initialHabitCreator) !=  ref.watch(_habitCreator);


  bool isFilterActive(Ref ref) => ref.watch(_filterCreator);
  String getFilterId(Ref ref) => ref.watch(_searchByUser);
  String getSearchText(Ref ref) => ref.watch(_searchCreator);

  void updateSearch(Ref ref, String newValue) => ref.update(_searchCreator, (value) => newValue);
  void updateFilterId(Ref ref, String userId) => ref.update(_searchByUser, (value) => userId);

  void onTextFieldTap(Ref ref){
    bool isActive = ref.watch(_filterCreator);
    if(isActive){
      dismissKeyboard();
      ref.update(_searchByUser, (userId) => '');
    }
  }

  void onPrefixIconTap(Ref ref, bool isActive, TextEditingController textEditingController){
    textEditingController.clear();
    dismissKeyboard();
    ref.update(_searchCreator, (p0) => '');
    ref.update(_searchByUser, (userId) => '');
    ref.update<bool>(_filterCreator, (value) => !value);
  }



}