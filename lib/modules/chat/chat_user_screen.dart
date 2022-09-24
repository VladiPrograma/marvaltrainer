import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/modules/chat/chat_global_screen.dart';
import 'package:marvaltrainer/widgets/marval_dialogs.dart';
import 'package:sizer/sizer.dart';

import '../../config/custom_icons.dart';
import '../../constants/colors.dart';
import '../../constants/components.dart';
import '../../constants/global_variables.dart';
import '../../constants/string.dart';
import '../../constants/theme.dart';

import '../../utils/extensions.dart';
import '../../utils/decoration.dart';
import '../../utils/firebase/storage.dart';
import '../../utils/marval_arq.dart';
import '../../utils/objects/message.dart';
import '../../widgets/box_user_data.dart';
import '../../widgets/marval_drawer.dart';

import 'chat_logic.dart';



final TextEditingController _controller = TextEditingController();

ScrollController returnController(Ref ref){
  ScrollController  res = ScrollController();
  res.addListener((){ if(res.position.maxScrollExtent==res.offset){ fetchMoreMessages(ref); }});
  return res;
}


///@TODO Remove TEXTH1 "Waiting Conexion"
///@TODO Add any type of interaction to permit Open and resize image when user press on it.
class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static String routeName = '/chat';
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.popAndPushNamed(context, ChatGlobalScreen.routeName);
        return true;
        },
      child: Scaffold(
      backgroundColor: kWhite,
      drawer: const MarvalDrawer(name: 'Chat',),
      body:  SizedBox( width: 100.w, height: 100.h,
          child: Stack(
              children: [
                /// Grass Image */
                Positioned( top: 0,
                 child: SizedBox(width: 100.w, height: 12.h,
                 child: Image.asset(
                    'assets/images/grass.png',
                    fit: BoxFit.cover
                 )),
                ),
                ///White Container */
                Positioned( top: 8.h,
                child: Container(width: 100.w, height: 10.h,
                decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.w),
                      topRight: Radius.circular(10.w)
                    ),
                ))
                ),
                /// User Data */
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
                        borderRadius: BorderRadius.vertical( top: Radius.circular(15.w) ),
                        child: Watcher((context, ref, child) {
                              //Logic
                              final data = getLoadMessages(ref);
                              if(isNull(data)||data!.isEmpty){ return const SizedBox(); }
                              DateTime firstDate = data.first.date;
                              //Widgets
                              return ListView.separated(
                              reverse: true,
                              itemCount: data.length,
                              controller: returnController(ref),
                              separatorBuilder: (context, index) {
                                Message? message  = data[index+1];
                                if(isNotNull(message) && firstDate.day != message.date.day){
                                  firstDate = message.date;
                                  return Container(
                                   padding: EdgeInsets.only(bottom: 1.h),
                                   child: Row(  mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Container(width: 30.w, height: 0.5.w, color: kGrey, ),
                                     TextP2(' ${firstDate.toFormatStringDate()} ', color: kGrey,),
                                     Container(width: 30.w, height: 0.5.w, color: kGrey, )
                                   ]));
                                }
                                return const SizedBox();
                              },
                              itemBuilder: (context, index){
                                Message message = data[index];
                                if(message.type == MessageType.photo) return _ImageBox(message: message);
                                return MessageBox(message: message);
                              });
                })))),
                /// TextField */
                Positioned(bottom: 3.w, left: 5.w,
                  child: SizedBox( width: 90.w,
                    child: _ChatTextField())),
              ])),
    ));
  }
}

class _ChatTextField extends StatelessWidget {
  const _ChatTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    XFile? _image;
    final ImagePicker _picker = ImagePicker();

    return TextField(
      onTap: () { fetchMoreMessages(context.ref); },
      controller: _controller,
      cursorColor: kGreen,
      style: TextStyle(fontSize: 4.w, fontFamily: p2, color: kBlack),
      decoration: InputDecoration(
          filled: true,
          fillColor: kWhite,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(4.w)),
          ),
          hintText: 'Escribe algo',
          hintStyle: TextStyle(fontSize: 4.w, fontFamily: p2, color: kGrey),
          ///@TODO Let user send Audios
          ///@TODO Let user send Images
          prefixIcon: GestureDetector(
            onTap: () async{
              _image = await _picker.pickImage(source: ImageSource.gallery);
              if(isNotNull(_image)){
                MarvalImageAlert(context,
                  image: _image!,
                  title: "Deseas subir esta foto ?",
                  onAccept: () async{
                    Message imageMessage = Message.image();
                    String? docID = await imageMessage.addInDBFromTrainer();
                      if(isNotNull(docID)){
                        imageMessage.message = await uploadChatImage(
                            uid: chatUser.id,
                            date: imageMessage.date,
                            name: docID!,
                            xfile: _image!
                        );
                        imageMessage.setInDBFromTrainer(docID);
                      }else{
                        logError(logErrorPrefix+" Problem adding Image to BD");
                      }
                  },
                );
              }
            },
            child: Icon(CustomIcons.camera, color: kBlack, size: 6.w,),
          ),
          suffixIcon: GestureDetector(
            onTap:(){
              if(isNotEmpty(_controller.text)){
                Message newMessage = Message.create(
                    message: _controller.text,
                    type: MessageType.text
                );
                newMessage.addInDBFromTrainer();
              }
              _controller.text="";
            },
            child: Icon(Icons.send_rounded, color: kBlack, size: 7.w,),
          )),
    );
  }
}



const List<int> _sizes = [0, 4, 8, 12, 16, 20];
const List<int> _margins = [77,65,53,41,29,15];

int _getMarginSize(Message msg){
  int labelSize = 0;
  _sizes.where((size) => msg.message.length>=size).forEach((element)=> labelSize++);
  return _margins[labelSize-1];
}
class MessageBox extends StatelessWidget {
  const MessageBox({required this.message, Key? key}) : super(key: key);
  final Message message;

  @override
  Widget build(BuildContext context) {
    final bool fromUser = message.user != authUser.uid;
    return Column(
        crossAxisAlignment: fromUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children:[ Container(
          padding: EdgeInsets.all(3.w),
          margin: EdgeInsets.only(
              right: fromUser ? _getMarginSize(message).w : 4.w,
              left : fromUser ? 4.w : _getMarginSize(message).w
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
          child: message.type == MessageType.photo ?
          Container(width: 50.w, height: 20.h, color: fromUser ? kBlack : kBlue,
          child: message.message.isEmpty ? null : Image.network(message.message, fit: BoxFit.cover,),)
           :              
          TextH2(message.message, color: kWhite, size: 4,textAlign: TextAlign.start),
        ),
          Padding(padding: EdgeInsets.only(left: 4.w, right: 4  .w, bottom: 1.h,),
              child: TextP2(message.date.toFormatStringHour(), color: kGrey,))
        ]);
  }
}

class _ImageBox extends StatelessWidget {
  const _ImageBox({required this.message, Key? key}) : super(key: key);
  final Message message;

  @override
  Widget build(BuildContext context) {
    final bool fromUser = message.user != authUser.uid;
    return Column(
        crossAxisAlignment: fromUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children:[ Container(
            margin: EdgeInsets.only(
                right: fromUser ? 0   : 4.w,
                left : fromUser ? 4.w : 0
            ),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight:  fromUser ? Radius.circular(2.w) : Radius.zero,
              topLeft : !fromUser ? Radius.circular(2.w) : Radius.zero,
              bottomLeft: Radius.circular(2.w),
              bottomRight: Radius.circular(2.w),
            ),
            color: fromUser ? kBlack : kBlue,
          ),
          child: Container(width: 50.w, height: 20.h,
            color: fromUser ? kBlack : kBlue,
            child: message.message.isEmpty ?
            Center(child: CircularProgressIndicator(color: kBlueSec, backgroundColor: kWhite))
                :
            Image.network(message.message, fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if(loadingProgress == null ) return child;
              return const CircularProgressIndicator(color: kBlueSec, backgroundColor: kWhite);})
          )
        ),
          Padding(padding: EdgeInsets.only(left: 4.w, right: 4  .w, bottom: 1.h,),
              child: TextP2(message.date.toFormatStringHour(), color: kGrey,))
        ]);
  }
}