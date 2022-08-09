import 'package:creator/creator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marvaltrainer/utils/objects/user_handler.dart';

import '../utils/objects/user.dart';

/// - - - FIREBASE AUTH - - -  */
 User? authUser;
 UserHandler handler = UserHandler.create();
 Map<String, Emitter> chatEmitterMap = {};

 late MarvalUser chatUser;
