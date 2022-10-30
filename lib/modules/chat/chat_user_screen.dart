import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../alerts/dialog_errors.dart';
import '../../alerts/snack_errors.dart';
import '../../modules/chat/chat_global_screen.dart';

import '../../config/log_msg.dart';
import '../../config/custom_icons.dart';

import '../../constants/colors.dart';
import '../../constants/global_variables.dart';
import '../../constants/string.dart';
import '../../constants/theme.dart';

import '../../utils/extensions.dart';
import '../../utils/decoration.dart';
import '../../utils/firebase/storage.dart';
import '../../utils/marval_arq.dart';
import '../../utils/objects/audio_system.dart';
import '../../utils/objects/message.dart';

import '../../widgets/marval_dialogs.dart';
import '../../widgets/box_user_data.dart';
import '../../widgets/marval_drawer.dart';

import '../../widgets/show_fullscreen_image.dart';
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
                                if(message.type == MessageType.audio) return  _AudioBox(message: message);
                                return _MessageBox(message: message);
                              });
                })))),
                /// TextField */
                Positioned(bottom: 3.w, left: 5.w,
                    child: SafeArea(
                        child: SizedBox( width: 90.w,
                            child: Stack(
                              children: [
                                _ChatTextField(),
                                Watcher((context, ref, child){
                                  int secs = ref.watch(timerCreator);
                                  Duration duration = Duration(seconds: secs);
                                  if(secs!=0){
                                    return Center(
                                        child: Container(width: 70.w, height: 5.h,
                                          margin: EdgeInsets.only(top: 1.h), color: kWhite,
                                          child: Padding(padding: EdgeInsets.only(top: 1.h, left: 2.w), child: TextH2(duration.printDuration())),
                                        )
                                    );
                                  }
                                  return const SizedBox.shrink();
                                })

                              ],
                            )
                        ))
                )
              ])),
    ));
  }
}
Timer? _timer;
Creator<int> timerCreator = Creator.value(0);
enum ChatActionType { SEND_MSG, SEND_AUDIO, RECORD }
Creator<ChatActionType> actionCreator = Creator.value(ChatActionType.RECORD);
Emitter<AudioSystem?> audioEmitter = Emitter((ref, emit) async{
  AudioSystem audioSystem = AudioSystem();
  await audioSystem.initAudioSystem();
  emit(audioSystem);
});
class _ChatTextField extends StatelessWidget {
  const _ChatTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    XFile? _image;
    final ImagePicker _picker = ImagePicker();

    return TextField(
        onTap: () { fetchMoreMessages(context.ref); },
        onChanged: (value) => context.ref.update<ChatActionType>(actionCreator, (p0) => value.isEmpty ? ChatActionType.RECORD : ChatActionType.SEND_MSG),
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
          ///@TODO Let user send Videos
          prefixIcon: Watcher((context, ref, child) {
            ChatActionType actionType = ref.watch(actionCreator);
            return GestureDetector(
              onTap: () async{
                if(actionType == ChatActionType.SEND_AUDIO){
                  ref.update(timerCreator, (p0) => 0);
                  ref.update(actionCreator, (p0) => ChatActionType.RECORD);
                }else{
                  _image = await _picker.pickImage(source: ImageSource.gallery)
                      .then((value) { ThrowDialog.uploadImage(context, _image!); })
                      .onError((error, stackTrace){  ThrowSnackbar.imageError(context); });

                }},
              child:  Watcher((context, ref, child) {
                ChatActionType actionType = ref.watch(actionCreator);
                return Icon( actionType == ChatActionType.SEND_AUDIO ? Icons.delete_rounded: CustomIcons.camera,
                    color: actionType == ChatActionType.SEND_AUDIO ? kRed: kBlack,
                    size: 7.w);
              }),
            );
          }),
          suffixIcon: Watcher((context, ref, child) {
            ChatActionType actionType = ref.watch(actionCreator);
            AudioSystem? audioSystem = ref.watch(audioEmitter.asyncData).data;
            return GestureDetector(
                onLongPressStart: (details) async{
                  if(actionType == ChatActionType.RECORD && audioSystem!.isInit){
                    logWarning("Long Press Start");
                    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                      ref.update<int>(timerCreator, (cont) => cont+1);
                    });
                    audioSystem.record();
                  }
                },
                onLongPressEnd: (details) async{
                  if(actionType == ChatActionType.RECORD && audioSystem!.isInit){
                    logWarning("Long Press End");
                    await audioSystem.stopRecorder();
                    ref.update(actionCreator, (p0) => ChatActionType.SEND_AUDIO);
                    _timer?.cancel();
                  }
                },
                onTap:() async{
                  if(isNotEmpty(_controller.text) && actionType == ChatActionType.SEND_MSG){
                    Message newMessage = Message.create(
                        message: _controller.text,
                        type: MessageType.text
                    );
                    newMessage.addInDBFromTrainer();
                    //Clean Screen
                    _controller.text="";
                    ref.update(actionCreator, (p0) => ChatActionType.RECORD);
                  } else if(actionType == ChatActionType.SEND_AUDIO){
                    ref.update(actionCreator, (p0) => ChatActionType.RECORD);
                    int secs = ref.watch(timerCreator);
                    ref.update<int>(timerCreator, (p0) => 0);
                    Message audioMessage = Message.audio(secs);
                    String? docID = await audioMessage.addInDBFromTrainer();
                    if(isNotNull(docID)){
                      audioMessage.message = await uploadChatAudio(
                          uid: audioMessage.user,
                          date: audioMessage.date,
                          audioPath: audioSystem!.uri!
                      );
                      audioMessage.setInDBFromTrainer(docID!);
                    }else{
                      logError("$logErrorPrefix Problem adding audio to BD");
                    }
                  }
                },
                child: Icon( actionType == ChatActionType.RECORD ? Icons.mic_rounded : Icons.send_rounded, color: kBlack, size: 7.w));
          }),
        )
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
class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.message, Key? key}) : super(key: key);
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
        children:[
          Container(
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
                child: CachedNetworkImage(
                    imageUrl: message.message,
                    fadeInDuration: Duration.zero,
                    placeholder: (context, url) => Center(child: Icon(CustomIcons.camera_retro, size: 8.w, color: kWhite)),
                    errorWidget: (context, url, error) =>
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.w),
                              color: kWhite,
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(CustomIcons.camera_retro, size: 8.w, color: kRed),
                                  SizedBox(height: 1.h,),
                                  TextP1("Fallo en la descarga", color: kRed, size: 3,)
                                ])),
                    imageBuilder: (context, imageProvider) {
                      return FullScreenImage(url: message.message, image: imageProvider);}),

              )),
          Padding(padding: EdgeInsets.only(left: 4.w, right: 4  .w, bottom: 1.h,),
              child: TextP2(message.date.toFormatStringHour(), color: kGrey,))
        ]);
  }
}

final AudioPlayer _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
Emitter<Duration?>   _positionStream = Emitter.stream((p0) => _audioPlayer.onPositionChanged);
Emitter<Duration?>   _durationStream = Emitter.stream((p0) => _audioPlayer.onDurationChanged);
Emitter<PlayerState?>   _stateStream = Emitter.stream((p0) => _audioPlayer.onPlayerStateChanged);

bool _isInit = false;
Creator<String> _currentAudio = Creator.value("");

void _init(String url, BuildContext  context) async{
  await _audioPlayer.setSourceUrl(url);
  await _audioPlayer.resume();
  context.ref.update<String>(_currentAudio, (p0) => url);
  _isInit = true;
}
Future<void> _play(Ref ref) async {
  final position = ref.watch(_positionStream.asyncData).data;
  if (isNotNull(position) && position!.inMilliseconds > 0) {
    await _audioPlayer.seek(position);
  }
  await _audioPlayer.resume();
}
Future<void> _pause() async {
  await _audioPlayer.pause();
}


class _AudioBox extends StatelessWidget {
  const _AudioBox({required this.message, Key? key}) : super(key: key);
  final Message message;
  @override
  Widget build(BuildContext context) {
    final bool fromUser = message.user != authUser.uid;
    return Watcher((context, ref, child){
      String audio = ref.watch(_currentAudio);

      if(audio == message.message){
        return _AudioBoxPLayer(message: message);
      }

      return _StaticAudioBox(message: message);

    });
  }
}

class _AudioBoxPLayer extends StatelessWidget {
  const _AudioBoxPLayer({required this.message, Key? key}) : super(key: key);
  final Message message;

  @override
  Widget build(BuildContext context) {
    final bool fromUser = message.user != authUser.uid;
    return Column(
        crossAxisAlignment: fromUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children:[
          Container(
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
            child: Container(width: 70.w, height: 5.2.h,
                color: fromUser ? kBlack : kBlue,
                child: Row(
                  children: [
                    message.message.isEmpty ?
                    Icon(Icons.file_download, color: kWhite, size: 7.w,) :
                    Watcher((context, ref, child){
                      PlayerState? state =  ref.watch(_stateStream.asyncData).data;
                      logWarning(PlayerState.values[state?.index ?? 0]);
                      return GestureDetector(
                        onTap: () async {

                          if(!_isInit){ _init(message.message, context); }
                          else if(state == PlayerState.playing){ _pause(); }
                          else{ _play(ref); }

                        },
                        child: Icon(state == PlayerState.paused || state == PlayerState.completed  ?
                        Icons.play_circle_fill_rounded
                            :
                        Icons.stop_circle_rounded,
                          color: kWhite, size: 8.w,),
                      );
                    }),
                    Column( mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 1.2.h,),
                        SizedBox(width: 60.w, height: 2.h,
                            child: Watcher((context, ref, child) {
                              Duration? position = ref.watch(_positionStream.asyncData).data;
                              Duration? duration = ref.watch(_durationStream.asyncData).data;
                              return Slider(
                                onChanged: (v) {
                                  if (isNull(duration)) { return; }
                                  final position = v * duration!.inMilliseconds;
                                  _audioPlayer.seek(Duration(milliseconds: position.round()));
                                },
                                value: (isNotNull(position) &&
                                    isNotNull(duration) &&
                                    position!.inMilliseconds > 0 &&
                                    position.inMilliseconds < duration!.inMilliseconds)
                                    ? position.inMilliseconds / duration.inMilliseconds
                                    : 0.0,
                                inactiveColor: kBlueSec,
                                activeColor: kWhite,
                                thumbColor: kBlack,

                              );
                            })),
                        Padding(padding: EdgeInsets.only(left: 6.w),
                            child: Watcher((context, ref, child) {
                              final duration = ref.watch(_positionStream.asyncData).data ?? Duration.zero;
                              return TextP1("${Duration(seconds: message.duration -  duration.inSeconds ).printDuration()} ",
                                  size: 2.5, color: kWhite);
                            }))
                      ],)
                  ],
                )),
          ),
          Padding(padding: EdgeInsets.only(left: 4.w, right: 4  .w, bottom: 1.h,),
              child: TextP2(message.date.toFormatStringHour(), color: kGrey,))
        ]);
  }
}

class _StaticAudioBox extends StatelessWidget {
  const _StaticAudioBox({required this.message, Key? key}) : super(key: key);
  final Message message;
  @override
  Widget build(BuildContext context) {
    final bool fromUser = message.user != authUser.uid;
    return Column(
        crossAxisAlignment: fromUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children:[
          Container(
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
            child: Container(width: 70.w, height: 5.2.h,
                color: fromUser ? kBlack : kBlue,
                child: Row(
                  children: [
                    message.message.isEmpty ?
                    Icon(Icons.file_download, color: kWhite, size: 7.w,) :
                    GestureDetector(
                      onTap: () async {
                        _init(message.message, context);
                      },
                      child: Icon(Icons.play_circle_fill_rounded,  color: kWhite, size: 8.w,),
                    ),
                    Column( mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 1.2.h,),
                          SizedBox(width: 60.w, height: 2.h,
                              child: Slider(
                                onChanged: (v) { },
                                value:  0.0,
                                inactiveColor: kBlueSec,
                                activeColor: kWhite,
                                thumbColor: kBlack,
                              )),
                          Padding(padding: EdgeInsets.only(left: 6.w),
                              child: TextP1("${Duration(seconds: message.duration ).printDuration()} ", size: 2.5, color: kWhite)),
                        ])
                  ],
                )),
          ),
          Padding(padding: EdgeInsets.only(left: 4.w, right: 4  .w, bottom: 1.h,),
              child: TextP2(message.date.toFormatStringHour(), color: kGrey,))
        ]);
  }
}

