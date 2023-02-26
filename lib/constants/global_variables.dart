import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marvaltrainer/firebase/dailys/model/cardio.dart';
import 'package:marvaltrainer/firebase/exercises/logic/exercise_logic.dart';
import 'package:marvaltrainer/firebase/plan/logic/plan_logic.dart';
import 'package:marvaltrainer/firebase/trainings/logic/training_logic.dart';

import 'package:marvaltrainer/utils/marval_arq.dart';
import 'package:marvaltrainer/utils/objects/user.dart';
import 'package:marvaltrainer/utils/objects/user_handler.dart';
import 'package:marvaltrainer/shared_preferences/controller/shared_controller.dart';

import 'package:marvaltrainer/firebase/users/logic/user_logic.dart';
import 'package:marvaltrainer/firebase/dailys/logic/daily_logic.dart';
import 'package:marvaltrainer/firebase/habits/logic/habits_logic.dart';
import 'package:marvaltrainer/firebase/gallery/logic/gallery_logic.dart';
import 'package:marvaltrainer/firebase/form/logic/form_answer_logic.dart';
import 'package:marvaltrainer/firebase/messages/logic/messages_logic.dart';
import 'package:marvaltrainer/firebase/measures/logic/measures_logic.dart';
import 'package:marvaltrainer/firebase/authentication/logic/auth_user_logic.dart';
import 'package:marvaltrainer/firebase/storage/controller/storage_controller.dart';



/// * - - - LOGIC INITS - - - */
final UserLogic userLogic = UserLogic();
final DailyLogic dailyLogic = DailyLogic();
final MeasuresLogic measuresLogic = MeasuresLogic();
final GalleryLogic galleryLogic = GalleryLogic();
final FormAnswersLogic formAnswersLogic = FormAnswersLogic();
final AuthUserLogic authUserLogic = AuthUserLogic();
final HabitsLogic habitsLogic  = HabitsLogic();
final MessagesLogic messagesLogic  = MessagesLogic();
final ExerciseLogic exerciseLogic  = ExerciseLogic();
final TrainingLogic trainingLogic  = TrainingLogic();
final PlanLogic planLogic  = PlanLogic();
final StorageController storageController  = StorageController();
final SharedPreferencesController sharedController = SharedPreferencesController();
//final AddWorkoutsController workoutsController  = AddWorkoutsController();

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

Map<CardioType, String> cardioNames = {
 CardioType.WALK : "🚶Andar",
 CardioType.RUN : "🏃Correr",
 CardioType.CICLING : "🚴Bici",
 CardioType.SWIM : "🏊Nadar",
 CardioType.DANCE : "🕺Bailar",
 CardioType.OTHER : "🏓Otro",
};
Map<CardioMeasure, String> cardioMeasureNames = {
 CardioMeasure.CAL : "Cal",
 CardioMeasure.MINS : "Mins",
 CardioMeasure.STEPS : "Pasos",
 CardioMeasure.KM : "Km",
};