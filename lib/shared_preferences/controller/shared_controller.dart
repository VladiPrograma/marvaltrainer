import 'package:collection/collection.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/firebase/messages/model/message.dart';
import 'package:marvaltrainer/shared_preferences/repository/shared_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesController {
  SharedPreferencesRepository repo = SharedPreferencesRepository();

  final String lastMsgId = 'last_msg_';
  final String contentId = 'content';
  final String dateId = 'date';
  final String typeId = 'type';
  final String trainerId = 'trainer';


  void setLastMessage(Ref ref, String userId, Message? msg){
    if(msg == null) return;
    String key = userId + lastMsgId;
    repo.setString(ref, key+contentId, msg.content);
    repo.setString(ref, key+dateId, msg.date.toString());
    repo.setString(ref, key+typeId, msg.type.name);
    repo.setBool(ref, key+trainerId, msg.trainer);
  }

  Message? getLastMessage(Ref ref, String userId){
    String key = userId + lastMsgId;
    String? content = repo.getString(ref, key+contentId);
    String? date = repo.getString(ref, key+dateId);
    String? strType = repo.getString(ref, key+typeId);
    bool? trainer = repo.getBool(ref, key+trainerId);

    DateTime? parseDate = DateTime.tryParse(date ?? '');
    MessageType? parseType = MessageType.values.firstWhereOrNull((type) => type.name == strType);
    logInfo('content: ${content ?? 'Null'}, date: $date, type: $parseType, trainer: $trainer');
    if(content!=null && parseDate != null && parseType != null && trainer != null){
      logWarning('Retrieving');
      return Message(id: '', content: content, type: parseType, user: userId, trainer: trainer, date: parseDate, read: false);
    }
    return null;
  }

}