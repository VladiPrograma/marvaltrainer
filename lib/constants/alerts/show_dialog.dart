import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/constants/colors.dart';
import 'package:marvaltrainer/constants/string.dart';

import 'package:marvaltrainer/firebase/messages/model/message.dart';
import 'package:marvaltrainer/firebase/trainings/model/training.dart';
import 'package:marvaltrainer/widgets/marval_dialogs.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:sizer/sizer.dart';


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

  static void goBackWithoutSaving({required BuildContext context, required Training training, required Function onAccept, required Function onCancel}){
    return MarvalDialogsAlert(context,
        height: 30,
        type: MarvalDialogAlertType.DELETE,
        title: r'Salir sin guardar ?',
        richText: RichText(text:  TextSpan(text: r'Tus cambios se perderan y no se veran reflejados en el entrenamiento si sales sin guardar', style: TextStyle(color: kBlack, fontFamily: p2, fontSize: 3.8.w ))),
        acceptText: r'Guardar',
        cancelText: r'Salir',
        onAccept: () => onAccept(),
        onCancel: () => onCancel());
  }

}