import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:sizer/sizer.dart';

import '../config/custom_icons.dart';
import '../constants/colors.dart';
import '../constants/components.dart';
import '../constants/theme.dart';
import '../utils/firebase/storage.dart';
import '../utils/marval_arq.dart';
import '../utils/objects/user.dart';

class SettingsUserData extends StatelessWidget {
  const SettingsUserData({required this.user, Key? key}) : super(key: key);
  final MarvalUser user;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfilePhoto(user: user),
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

XFile? _backgroundImage;
final ImagePicker _picker = ImagePicker();

///@TODO Add Watcher here instead of StatefulWidget
///@TODO Check if works without profile image loaded
class ProfilePhoto extends StatefulWidget {
  const ProfilePhoto({required this.user, Key? key}) : super(key: key);
  final MarvalUser user;
  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState();
}
class _ProfilePhotoState extends State<ProfilePhoto> {
  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
          onTap: () async{
            _backgroundImage = await _picker.pickImage(source: ImageSource.gallery);
            setState(() { });
            if(isNotNull(_backgroundImage)){
              String link = await uploadProfileImg(widget.user.id, _backgroundImage!);
              authUser.updatePhotoURL(link);
            }
          },
          child: CircleAvatar(
            backgroundColor: kBlack,
            backgroundImage:
            isNotNull(_backgroundImage) ?
            Image.file(File(_backgroundImage!.path)).image
                :
            isNotNull(widget.user.profileImage) ?
            Image.network(widget.user.profileImage!).image
                :
            null,
            radius: 6.h,
            child: isNull(_backgroundImage) && isNull(widget.user.profileImage) ?
            Icon(CustomIcons.person, color : kWhite, size: 4.w,)
                :
            const SizedBox(),
          )
    );
  }
}