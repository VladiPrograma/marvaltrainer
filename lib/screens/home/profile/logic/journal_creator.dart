import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/dailys/model/daily.dart';

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

Creator<Habit?> _habitsCreator = Creator.value(null);

void updateHabitsCreator(Habit? habit, Ref ref ){
  ref.update<Habit?>(_habitsCreator, (p0) => habit);
}
Habit? watchHabitsCreator(Ref ref){
  return ref.watch(_habitsCreator);
}