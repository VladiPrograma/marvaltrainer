import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/widgets/marval_drawer.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/components.dart';
import '../../constants/global_variables.dart';
import '../../constants/string.dart';
import '../../constants/theme.dart';

import '../../utils/decoration.dart';
import '../../utils/marval_arq.dart';
import '../../utils/objects/message.dart';
import '../../utils/objects/user.dart';
import '../home/home_screen.dart';
import 'chat_user_screen.dart';


  Emitter createChatGlobalEmitter(String uid){
    return Emitter.stream((ref) async {
    return FirebaseFirestore.instance.collection('users/$uid/chat')
        .orderBy('date',descending: true)
        .limit(1)
        .snapshots();
  });
  }
  Message? getMsg(Ref ref, String uid){
    if(isNull(emitterMap[uid])){return null;}
    final query = ref.watch(emitterMap[uid]!.asyncData).data;
    if(isNull(query)||query!.size==0){ return null; }
    return Message.fromJson(query.docs.first.data());
  }
  Map<String, Emitter> emitterMap = {};

class ChatGlobalScreen extends StatelessWidget {
  const ChatGlobalScreen({Key? key}) : super(key: key);
  static String routeName = "/chat_global";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        drawer: const MarvalDrawer(name: 'Chat',),
        body:  Container( width: 100.w, height: 100.h,
        child: Stack(  children: [
        /// Grass Image
        Positioned( top: 0,
          child: Container(width: 100.w, height: 30.h,
            child: Image.asset('assets/images/grass.png', fit: BoxFit.cover,),
          )
        ),
        /// Home Text H1
        Positioned( top: 0,
        child: Container(width: 100.w, height: 17.5.h,
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
             child: UserList()
          )),
        ),
        ///TextField
        Positioned(
            top: 14.5.h,
            left: 12.5.w,
            child: Container(width: 75.w, height: 10.h,
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
                    listNotifier.value= handler.list.where((element) =>
                        element.name.
                        toLowerCase().
                        contains(value.toLowerCase()))
                        .toList();
                  },
                )),
          )
      ]))
    );
  }
}

/// Charging data on INIT
class UserList extends StatelessWidget {
  const UserList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: listNotifier, builder: (context, value, child) {
      return ListView.builder(
        itemCount: listNotifier.value.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: (){
                chatUser = listNotifier.value[index];
                Navigator.pushNamed(context, ChatScreen.routeName);
              },
              child: MarvalChatTile(user: listNotifier.value[index])
          );
        }
      );
    });
  }
}

class MarvalChatTile extends StatelessWidget {
  const MarvalChatTile({required this.user, Key? key}) : super(key: key);
  final MarvalUser user;
  @override
  Widget build(BuildContext context) {
    if(isNull(emitterMap[user.id])){
      emitterMap[user.id] = createChatGlobalEmitter(user.id);
      logSuccess('Creao');

    }
    return Container(width: 100.w, height: 12.h,
        padding: EdgeInsets.symmetric(horizontal: 2.5.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container( width: 92.w,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            boxShadow: [kDarkShadow],
                            borderRadius: BorderRadius.circular(100.w)
                        ),
                        child: CircleAvatar(
                          backgroundImage: isNull(user.profileImage) ?
                          null :
                          Image.network(user.profileImage!).image, radius: 5.h,
                          backgroundColor: kBlack,
                        )),
                    SizedBox(width: 2.w,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextH2(user.name.maxLength(20), size: 4, ),
                        SizedBox(height: 0.5.h,),
                        Watcher((context, ref, _){
                          final data = getMsg(ref, user.id);
                          return TextP2( isNull(data) ? "" : data!.message.maxLength(40), size: 3.5, color: kGrey, );
                        })
                      ]),
                    Spacer(),
                    Container(width: 14.w ,child:
                    Watcher((context, ref, _){
                      final data = getMsg(ref, user.id);
                      return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextH2( isNull(data) ? "" : data!.date.toFormatStringHour(), size: 2.5, color: kGrey, ),
                        Visibility(
                            visible: isNotNull(data),
                            child: Container(width: 10.w, height: 8.w,
                            decoration: BoxDecoration(
                                color: kGreen.withOpacity(0.9),
                                boxShadow: [kMarvalBoxShadow],
                                borderRadius: BorderRadius.circular(10.w)
                            ),
                            child: Center(child:  TextH2('3', color: kWhite,),)
                        )),
                      ]);}))
                  ])),
          ]));
  }
}