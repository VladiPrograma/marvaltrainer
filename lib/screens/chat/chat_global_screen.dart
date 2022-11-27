import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/firebase/messages/model/message.dart';
import 'package:marvaltrainer/firebase/messages/repository/message_repository.dart';
import 'package:marvaltrainer/firebase/users/dto/user_resume.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/screens/chat/chat_logic.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/widgets/cached_avatar_image.dart';
import 'package:marvaltrainer/widgets/marval_drawer.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/components.dart';
import '../../constants/global_variables.dart';
import '../../constants/string.dart';
import '../../constants/theme.dart';

import '../../utils/marval_arq.dart';
import '../../widgets/inner_border.dart';
import 'chat_user_screen.dart';

///@TODO Improve the size of the GestureDetector when user wants to openChat
Creator<String> _searchCreator = Creator.value('');

class ChatGlobalScreen extends StatelessWidget {
  const ChatGlobalScreen({Key? key}) : super(key: key);
  static String routeName = "/chat";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        drawer: const MarvalDrawer(name: 'Chat',),
        body:  SizedBox( width: 100.w, height: 100.h,
        child: Stack(  children: [
        /// Grass Image
        Positioned( top: 0,
          child: SizedBox(width: 100.w, height: 30.h,
            child: Image.asset('assets/images/grass.png', fit: BoxFit.cover,),
          )
        ),
        /// Home Text H1
        Positioned( top: 0,
        child: SizedBox(width: 100.w, height: 17.5.h,
          child: Center(child: TextH1('Chat', size: 13,
          color: Colors.black.withOpacity(0.7),
          shadows: [
          BoxShadow(color: kWhite.withOpacity(0.4), offset: const Offset(0, 2), blurRadius: 15)
          ]))
          )
        ),
        /// List Tiles
        Positioned(
        bottom: 0,
          child: ClipRRect(
          borderRadius: BorderRadius.only(
          topRight:  Radius.circular(10.w),
          topLeft: Radius.circular(10.w)),
            child: Container( width: 100.w, height: 82.h,
            color: kWhite,
             child: const _UsersList()
          )),
        ),
        ///TextField
        Positioned(
            top: 14.5.h,
            left: 12.5.w,
            child: SizedBox(width: 75.w, height: 10.h,
                child:  TextField(
                  cursorColor: kWhite,
                  style: TextStyle( fontFamily: p1, color: kBlack, fontSize: 4.w),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: kWhite,
                      border: DecoratedInputBorder(
                        child:  OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(4.w)),
                        ),
                        shadow: BoxShadow(
                          color: kBlack.withOpacity(0.45),
                          offset: Offset(0, 1.3.w),
                          blurRadius: 2.1.w,
                        ),
                      ),
                      hintText: 'Buscar',
                      hintStyle:  TextStyle(fontFamily: p1, color: kGrey, fontSize: 4.w),
                      prefixIcon: Icon(Icons.search_rounded, color: kGrey,size: 8.w,),
                      contentPadding: EdgeInsets.zero
                  ),
                  onChanged: (value) {
                    ///Search logic
                    context.ref.update(_searchCreator, (name) => value.toLowerCase());
                  },
                )),
          )
      ]))
    );
  }
}

class _UsersList extends StatelessWidget {
  const _UsersList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Watcher((context, ref, child){
      List<UserResumeDTO> users = userLogic.getUserHome(ref, ref.watch(_searchCreator));
      List<Message> unreadMsg = messagesLogic.getUnread(ref);
      List<Message> lastMsgByUser = [];
      for (var user in users) {
        Message? lastMsg = unreadMsg.firstWhereOrNull((msg) => msg.user == user.id);
        lastMsg ??= messagesLogic.getLast(ref, user.id);
        lastMsgByUser.add(lastMsg ?? Message.empty(user.id));
      }
      lastMsgByUser.sort((a, b) => b.date.compareTo(a.date));

        return ListView.builder(
            itemCount: users.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return  _MarvalChatTile(user: users.firstWhere((user) => user.id == lastMsgByUser[index].user),
                  message: lastMsgByUser[index].content.isNotEmpty ? lastMsgByUser[index] : null,
                  notification: unreadMsg.where((msg) => msg.user == lastMsgByUser[index].user).length);
            }
        );
    });
  }
}
class ScreenArguments {
  final String userId;
  ScreenArguments(this.userId);
}
class _MarvalChatTile extends StatelessWidget {
  const _MarvalChatTile({required this.message, required this.notification, required this.user, Key? key}) : super(key: key);
  final UserResumeDTO user;
  final Message? message;
  final int notification;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, ChatScreen.routeName, arguments: ScreenArguments(user.id));
        },
    child: Container(width: 100.w, height: 12.h,
        padding: EdgeInsets.symmetric(horizontal: 2.5.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox( width: 92.w,
                child: Watcher((context, ref, child) {
                    List<Message> unreadMsg = messagesLogic.getUnread(ref).where((msg) => msg.user == user.id).toList();
                    Message? lastMsg = unreadMsg.isNotEmpty ? unreadMsg.last : messagesLogic.getLast(ref, user.id);
                    return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Profile Image
                          Container(
                              decoration: BoxDecoration(
                                  boxShadow: [kDarkShadow],
                                  borderRadius: BorderRadius.circular(100.w)
                              ),
                              child:  CachedAvatarImage(
                                url: user.img,
                                size: 5,
                              )),
                          SizedBox(width: 3.w,),
                          /** Last Message **/
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextH2('${user.name.removeIcon()} ${user.lastName} ${user.name.getIcon()}'.maxLength(20), size: 3.8, ),
                                SizedBox(height: 0.5.h,),
                                SizedBox(width: 53.w,
                                    child: Row(children: [
                                      lastMsg?.user == authUserLogic.getCurrUser()?.uid
                                        ? Icon(Icons.check_sharp, color: kGreen, size: 6.w,)
                                        : const SizedBox.shrink(),
                                     _LastMessageBox(message: lastMsg,)
                                    ]))
                              ]),
                          const Spacer(),
                          /** Notifications **/
                          SizedBox(width: 14.w,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      unreadMsg.isEmpty ? SizedBox(width: 5.w, height: 5.w):
                                      Container(width: 5.w, height: 5.w,
                                          decoration: BoxDecoration(
                                              color: kGreen,
                                              borderRadius: BorderRadius.circular(7.w)
                                          ),
                                          child: Center(child:
                                          TextH1('${unreadMsg.length}',
                                            color: kWhite,
                                            size: 2.5,
                                          ))
                                      ),
                                    SizedBox(height: 1.5.h,),
                                    // Last Message Hour
                                     TextH2( isNull(lastMsg) ? "" : lastMsg!.date.toFormatStringHour(),
                                      size: 2.3,
                                      color: kGrey,
                                    ),
                                  ]))
                        ]);
                })),
          ])));
  }
}

class _LastMessageBox extends StatelessWidget {
  const _LastMessageBox({required this.message, Key? key}) : super(key: key);
  final Message? message;
  @override
  Widget build(BuildContext context) {
    if(message == null){
      return const SizedBox.shrink();
    }
    if(message!.type == MessageType.IMAGE){
      return const Expanded(
          child:TextP2( "📷 Image",
            size: 3.5, color: kGrey,
            textAlign: TextAlign.start, maxLines: 2,
          ));
    }
    if(message!.type == MessageType.AUDIO){
      return const Expanded(
          child:TextP2( "🎤 Audio",
            size: 3.5, color: kGrey,
            textAlign: TextAlign.start, maxLines: 2,
          ));
    }
    return Expanded(
        child:TextP2( message!.content,
          size: 3.1, color: kGrey,
          textAlign: TextAlign.start, maxLines: 2,
        ));
  }
}
