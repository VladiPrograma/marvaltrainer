import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/constants/theme.dart';
import 'package:marvaltrainer/utils/decoration.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/utils/marval_arq.dart';
import 'package:sizer/sizer.dart';

import '../../config/custom_icons.dart';
import '../../constants/colors.dart';
import '../../constants/components.dart';
import '../../constants/string.dart';
import '../../utils/objects/message.dart';
import '../../utils/objects/user.dart';
import '../../widgets/marval_drawer.dart';



final _page = Creator.value(1);
void fetchMore(Ref ref) => ref.update<int>(_page, (n) => n + 1);

final chatCreator = Emitter.stream((ref) async {
  return FirebaseFirestore.instance.collection('users/${chatUser.id}/chat')
      .orderBy('date',descending: true)
      .limit(10*ref.watch(_page))
      .snapshots();
});
List<Message>? getMsg(Ref ref){
  final query = ref.watch(chatCreator.asyncData).data;
  if(isNull(query)||query!.size==0){ return null; }
  List<Message> list = [];
  for (var element in [...query.docs]){
    list.add(Message.fromJson(element.data()));
  }
  return list;
}

final TextEditingController _controller = TextEditingController();

ScrollController returnController(Ref ref){
  ScrollController  res = ScrollController();
  res.addListener((){
    if(res.position.maxScrollExtent==res.offset){
      fetchMore(ref);
    }
  });
  return res;
}


///@TODO Remove TEXTH1 "Waiting Conexion"
class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static String routeName = '/chat';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      drawer: const MarvalDrawer(name: 'Chat',),
      body:  Container( width: 100.w, height: 100.h,
          child: Stack(
              children: [
                /// Grass Image */
                Positioned( top: 0,
                    child: Container(width: 100.w, height: 12.h,
                        child: Image.asset('assets/images/grass.png', fit: BoxFit.cover))
                ),
                ///White Container */
                Positioned( top: 8.h,
                    child: Container(width: 100.w, height: 10.h,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.w), topRight: Radius.circular(10.w)),
                            color: kWhite
                        ))),
                /// Marval Trainer Data */
                Positioned(  top: 1.h, left: 8.w,
                    child: SafeArea(
                      child:  BoxUserData(user: chatUser)
                )),
                /// Chat Container */
                Positioned( top: 18.h,
                  child:  InnerShadow(
                      color: Colors.black,
                      blur: 10,
                      offset: Offset(0,2.w),
                      child: Container(width: 100.w, height: 82.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.w), topRight: Radius.circular(15.w)),
                              color: kBlack.withOpacity(0.85)
                          ))),
                ),
                ///* Chat Messages  */
                Positioned( top: 18.h,
                    child:  Container(width: 100.w, height: 72.h,
                        padding: EdgeInsets.only( bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15.w)),
                            child: Watcher((context, ref, child) {
                              final data = getMsg(ref);
                              if(isNull(data)||data!.isEmpty){
                                return SizedBox();
                              }
                              DateTime firstDate = data.first.date;
                              return ListView.separated(
                                  reverse: true,
                                  controller: returnController(ref),
                                  itemCount: data.length,
                                  separatorBuilder: (context, index) {
                                    if(isNotNull(data[index+1])&& firstDate.day != data[index+1].date.day){
                                      firstDate = data[index+1].date;
                                      return Container(
                                          padding: EdgeInsets.only(bottom: 1.h),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(width: 30.w, height: 0.5.w, color: kGrey, ),
                                              TextP2(' ${firstDate.toFormatStringDate()} ', color: kGrey,),
                                              Container(width: 30.w, height: 0.5.w, color: kGrey, )
                                            ],
                                          ));
                                    }
                                    return SizedBox();
                                  },
                                  itemBuilder: (context, index){
                                    Message msg = data[index];
                                    return MessageBox(msg: msg);
                                  });
                            })))),
                /// TextField */
                Positioned(bottom: 3.w, left: 5.w,
                  child: SizedBox( width: 90.w,
                    child: TextField(
                      onTap: () {
                        fetchMore(context.ref);
                      },
                      controller: _controller,
                      decoration: InputDecoration(
                          fillColor: kWhite,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(4.w)),
                          ),
                          hintText: 'Escribe algo',
                          hintStyle: TextStyle(fontSize: 4.w, fontFamily: p2, color: kGrey),
                          prefixIcon: Icon(CustomIcons.camera, color: kBlack, size: 6.w,),
                          suffixIcon: GestureDetector(
                            onTap:(){
                              if(isNotEmpty(_controller.text)){
                                Message newMsg = Message.create(_controller.text, MessageType.text);
                                newMsg.setInDBMessageFromTrainer();
                              }
                              _controller.text="";
                            },
                            child: Icon(Icons.send_rounded, color: kBlack, size: 7.w,),
                          )

                      ),
                      style: TextStyle(fontSize: 4.w, fontFamily: p2, color: kBlack),
                      cursorColor: kGreen,
                    ),
                  ),),
              ])),
    );
  }
}

class BoxUserData extends StatelessWidget {
  const BoxUserData({required this.user, Key? key}) : super(key: key);
  final MarvalUser user;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            decoration: BoxDecoration(
              boxShadow: [kMarvalHardShadow],
              borderRadius: BorderRadius.all(Radius.circular(100.w)),
            ),
            child: CircleAvatar(
                backgroundColor: kBlack,
                radius: 6.h,
                backgroundImage:  isNullOrEmpty(user.profileImage) ?
                null
                    :
                Image.network(user.profileImage!, fit: BoxFit.fitHeight).image
            )),
        SizedBox(width: 2.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h,),
            TextH2('${user.name} ${user.lastName}', size: 4),
            TextH2(user.work, size: 3, color: kGrey,),
          ],
        )
      ],
    );
  }
}

class MessageBox extends StatelessWidget {
  const MessageBox({required this.msg, Key? key}) : super(key: key);
  final Message msg;
  int getMarginSize(){
    const List<int> sizes = [0, 4, 8, 12, 16, 20];
    const List<int> margins = [77,70,61,53,42,29];
    int labelSize = 0;
    for (var element in sizes) {
      if(msg.message.length>=element) labelSize++;
    }
    return margins[labelSize-1];
  }

  @override
  Widget build(BuildContext context) {
    final bool fromUser = msg.user != authUser!.uid;

    return Column(
        crossAxisAlignment: fromUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children:[ Container(
          padding: EdgeInsets.all(3.w),
          margin: EdgeInsets.only(
              right: fromUser ? getMarginSize().w : 4.w,
              left : fromUser ? 4.w : getMarginSize().w
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight:  fromUser ? Radius.circular(2.w) : Radius.zero,
              topLeft : !fromUser ? Radius.circular(2.w) : Radius.zero,
              bottomLeft: Radius.circular(2.w),
              bottomRight: Radius.circular(2.w),
            ),
            color: fromUser ? kBlack : kBlue,
          ),
          child: TextH2(msg.message, color: kWhite, size: 4),
        ),
          Padding(padding: EdgeInsets.only(left: 4.w, right: 4  .w, bottom: 1.h,),
              child: TextP2(msg.date.toFormatStringHour(), color: kGrey,))
        ]);
  }
}
