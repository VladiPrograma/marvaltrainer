import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/config/log_msg.dart';

import '../../utils/marval_arq.dart';
import '../../utils/objects/message.dart';
import '../../constants/global_variables.dart';

/// Emitter that takes al Firebase Data from _page variable.
Emitter createChatEmitter(String uid){
  return Emitter.stream((ref) async {
    return FirebaseFirestore.instance.collection('users/$uid/chat')
        .orderBy('date',descending: true)
        .limit(5)
        .snapshots();
  });
}

Message? getLastMessage(Ref ref, String uid){
  final query = ref.watch(chatEmitterMap[uid]!.asyncData).data;
  if(isNull(query)||query!.size==0){ return null; }
  return Message.fromJson(query.docs.first.data());
}

int? getUnreadMessages(Ref ref, String uid){
  if(isNull(chatEmitterMap[uid])){return null;}
  final query = ref.watch(chatEmitterMap[uid]!.asyncData).data;
  if(isNull(query)||query!.size==0){ return null; }

  final List<Message> list = _queryToData(query);
  return list.where((element) => element.user==uid && !element.read).length;
}

List<Message>? getLoadMessages(Ref ref){
  final query = ref.watch(_chatCreator.asyncData).data;
  if(isNull(query)||query!.size==0){ return null; }

  //Pass data from querySnapshot to Messages
  final List<Message> list = _queryToData(query);

  //Mark messages from read:false to read:true when user reads it.
  _readMessages(list);

  return list;
}

final _page = Creator.value(1);
void fetchMoreMessages(Ref ref) => ref.update<int>(_page, (n) => n + 1);

///* Internal Logic ///
List<Message> _queryToData(var query){
  List<Message> list = [];
  for (var element in [...query.docs]){
    list.add(Message.fromJson(element.data()));
  }
  return list;
}

final _chatCreator = Emitter.stream((ref) async {
  return FirebaseFirestore.instance.collection('users/${chatUser.id}/chat')
      .orderBy('date',descending: true)
      .limit(10*ref.watch(_page))
      .snapshots();
});

void _readMessages(List<Message> data ) =>
       data.where((message) => message.user == chatUser.id && !message.read)
      .forEach((message) => message.updateRead() );

