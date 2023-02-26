import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/habits/dto/habits_daily.dart';
import 'package:marvaltrainer/firebase/habits/dto/habits_resume.dart';

enum JournalState {DIARY, HABITS, GALLERY, MEASURES, LIST  }
List<String>   journalNames = ['Diario', 'Habitos', 'Galeria', 'Medidas'];
List<String> journalIcons = ['📓','🔆', '🎬', '📏'];

Creator<JournalState> _journalCreator = Creator.value(JournalState.LIST);

void updateJournal(JournalState state, Ref ref ){
  ref.update<JournalState>(_journalCreator, (p0) => state);
}
JournalState watchJournal(Ref ref){
  return ref.watch(_journalCreator);
}

Creator<HabitsResumeDTO?> _habitsCreator = Creator.value(null);

void updateHabitsCreator(HabitsResumeDTO? habit, Ref ref ){
  ref.update<HabitsResumeDTO?>(_habitsCreator, (p0) => habit);
}
HabitsResumeDTO? watchHabitsCreator(Ref ref){
  return ref.watch(_habitsCreator);
}