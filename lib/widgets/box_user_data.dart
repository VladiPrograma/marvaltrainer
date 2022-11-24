
import 'package:flutter/material.dart';
import 'package:marvaltrainer/widgets/cached_avatar_image.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../constants/components.dart';
import '../constants/theme.dart';
import '../utils/marval_arq.dart';
import '../utils/objects/user.dart';
import 'image_editor.dart';

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
         child: CachedAvatarImage(
           url: user.profileImage,
           size: 5,
           expandable: true,
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

