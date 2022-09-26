
import 'package:flutter/material.dart';
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
            child: GestureDetector(
            onTap: (){
              if(isNotNullOrEmpty(user.profileImage)){
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    barrierColor: kBlack,
                    pageBuilder: (BuildContext context, _, __) {
                      return FullScreenPage(
                        child: Image.network(user.profileImage!, height: 100.h,),
                        dark: false,
                        url: user.profileImage!,
                      );
                    },
                  ),
                );
              }
            },
            child: CircleAvatar(
            backgroundImage: isNullOrEmpty(user.profileImage) ?
            null :
            Image.network(user.profileImage!).image, radius: 5.h,
            backgroundColor: kBlack,
            ),
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

