import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marvaltrainer/firebase/messages/logic/messages_logic.dart';
import 'package:marvaltrainer/firebase/storage/controller/storage_controller.dart';
import 'package:marvaltrainer/utils/marval_arq.dart';
import 'package:marvaltrainer/utils/objects/user.dart';
import 'package:marvaltrainer/utils/objects/user_handler.dart';
import 'package:marvaltrainer/firebase/users/logic/user_logic.dart';
import 'package:marvaltrainer/firebase/dailys/logic/daily_logic.dart';
import 'package:marvaltrainer/firebase/habits/logic/habits_logic.dart';
import 'package:marvaltrainer/firebase/gallery/logic/gallery_logic.dart';
import 'package:marvaltrainer/firebase/form/logic/form_answer_logic.dart';
import 'package:marvaltrainer/firebase/measures/logic/measures_logic.dart';
import 'package:marvaltrainer/firebase/authentication/logic/auth_user_logic.dart';



/// * - - - LOGIC INITS - - - */
final UserLogic userLogic = UserLogic();
final DailyLogic dailyLogic = DailyLogic();
final MeasuresLogic measuresLogic = MeasuresLogic();
final GalleryLogic galleryLogic = GalleryLogic();
final FormAnswersLogic formAnswersLogic = FormAnswersLogic();
final AuthUserLogic authUserLogic = AuthUserLogic();
final HabitsLogic habitsLogic  = HabitsLogic();
final MessagesLogic messagesLogic  = MessagesLogic();
final StorageController storageController  = StorageController();


/// - - - FIREBASE AUTH - - -  */
late User authUser;
late MarvalUser chatUser;

UserHandler handler = UserHandler.create();
Map<String, Emitter> chatEmitterMap = {};


/// - - - -  USERS HANDLER - - -  - */
final handlerEmitter = Emitter.stream((ref) async {
 return FirebaseFirestore.instance.collection('users')
     .where('active', isEqualTo: true)
     .orderBy('update', descending: false)
     .snapshots();
}, keepAlive: true);

List<MarvalUser>? getUserList(Ref ref){
 final query = ref.watch(handlerEmitter.asyncData).data;
 if(isNull(query)||query!.size==0){ return null; }
 return _queryToUserList(query).whereType<MarvalUser>().toList();
}
//Pass data from query to MarvalUser list
List _queryToUserList(var query){
 List list = [];
 for (var element in [...query.docs]){
  list.add(MarvalUser.fromJson(element.data()));
 }
 return list;
}

