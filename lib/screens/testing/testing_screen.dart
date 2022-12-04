import 'package:creator/creator.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:flutter/material.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/widgets/marval_drawer.dart';
import 'package:sizer/sizer.dart';

import '../../config/log_msg.dart';
import '../../config/custom_icons.dart';
import '../../screens/chat/chat_logic.dart';
import '../../screens/home/home_screen.dart';
import '../../utils/firebase/auth.dart';
import '../../utils/marval_arq.dart';

import '../../constants/theme.dart' ;
import '../../constants/string.dart';
import '../../constants/colors.dart';
import '../../constants/global_variables.dart';

import '../../widgets/marval_dialogs.dart';
import '../../widgets/marval_elevated_button.dart';
import '../../widgets/marval_password_textfield.dart';
import '../../widgets/marval_textfield.dart';
/// TODO Configure in Firebase The Reset Password Email

class TestingScreen extends StatelessWidget {
  const TestingScreen({Key? key}) : super(key: key);
  static String routeName = "/testing";

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: kWhite,
        drawer: const MarvalDrawer(name: 'testing'),
        body: SafeArea(child:
        SizedBox( width: 100.w, height: 100.h,
          child: Column(
            children: [
              const Center(child: TextH1('TESTING'),),
              Watcher((context, ref, child){
                String? getAndres = sharedController.repo.getString(ref, '6TcV7cdJQmeWYpyo282a5d7qwmy1last_msg_content');
                String? getName = sharedController.repo.getString(ref, 'Test');
                return TextH2(getAndres ?? 'Null');
              })
            ],
          ),
        )
        ),
      );
  }
}

