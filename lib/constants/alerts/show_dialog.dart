import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:marvaltrainer/firebase/messages/model/message.dart';
import 'package:marvaltrainer/widgets/marval_dialogs.dart';
import 'package:marvaltrainer/constants/global_variables.dart';


class ThrowDialog{

  static void uploadImage(BuildContext context, XFile xfile, String userId){
    MarvalImageAlert(context,
        image: xfile,
        title: "Deseas subir esta foto ?",
        onAccept: () async{
          String? networkImg = await storageController.uploadChatImage(userId, xfile);
          if(networkImg !=null){
            Message message = Message.create( networkImg, MessageType.IMAGE, userId);
            sharedController.setLastMessage(context.ref, userId, message);
            messagesLogic.add(context.ref, message);
          }
        });
  }

}