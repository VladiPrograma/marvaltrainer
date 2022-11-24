import 'package:sizer/sizer.dart';
import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/widgets/show_fullscreen_image.dart';
import 'package:marvaltrainer/firebase/gallery/model/gallery.dart';
import 'package:marvaltrainer/screens/home/profile/widgets/journal_title_row.dart';

import 'package:marvaltrainer/constants/colors.dart';
import 'package:marvaltrainer/constants/components.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/constants/theme.dart';



import 'package:marvaltrainer/utils/marval_arq.dart';

ScrollController _returnController(Ref ref){
  ScrollController  res = ScrollController();
  res.addListener((){ if(res.position.maxScrollExtent==res.offset){ galleryLogic.fetchMore(ref); }});
  return res;
}

class GalleryList extends StatelessWidget {
  const GalleryList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 100.w, height: 76.h,
        child: Watcher((context, ref, child) {
          List<Gallery>? images = galleryLogic.getList(ref);
          return ListView.builder(
              controller: _returnController(ref),
              itemCount: images.length+1,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                /// Title
                if(index==0){ return const JournalTitle(name: "Fotos del usuario"); }
                return GalleryLabel(gallery: images[index-1]);
              });
        }));
  }
}
class GalleryLabel extends StatelessWidget {
  const GalleryLabel({required this.gallery, Key? key}) : super(key: key);
  final Gallery gallery;
  @override
  Widget build(BuildContext context) {
    String aestheticDate = '${gallery.date.day} ${gallery.date.toStringMonth().toLowerCase()} ${gallery.date.year}';
    return  Container(
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 1.7.h),
        padding: EdgeInsets.symmetric( vertical: 2.h),
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(
                offset: Offset(0, 3.w),
                color: kBlackSec,
                blurRadius: 4.w
            )],
            color: kBlack,
            borderRadius: BorderRadius.circular(8.w)
        ),
        child:   Column( children: [
          // Date Title
          Row(children: [
            SizedBox(width: 6.w),
            TextH2(gallery.date.toStringWeekDayLong(), color: kWhite, size: 3.8),
            const Spacer(),
            TextH2(aestheticDate, color: kWhite, size: 3.8),
            SizedBox(width: 6.w),
          ]),
          SizedBox(height: 2.h,),
          ImageFrame(text: 'Frontal',  url: gallery.frontal),
          ImageFrame(text: 'Perfil',   url: gallery.perfil),
          ImageFrame(text: 'Espalda',  url: gallery.espalda),
          ImageFrame(text: 'Piernas',  url: gallery.piernas)
        ]));
  }
}
class ImageFrame extends StatelessWidget {
  const ImageFrame({required this.text, required this.url, Key? key}) : super(key: key);
  final String text;
  final String? url;
  @override
  Widget build(BuildContext context) {
    return  isNull(url) ? const SizedBox.shrink()
        :  Column(children: [
      Container(width: 47.w, height: 47.w,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(
                  offset: Offset(0, 2.w),
                  color: kBlackSec,
                  blurRadius: 3.w
              )],
              borderRadius: BorderRadius.circular(5.w)
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.w),
            child: CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => FullScreenImage(url: url!, image: imageProvider),
               placeholder: (context, url) =>  Container(color: kBlack, child: Icon(Icons.image, size: 25.w, color: kWhite)),
            ),
      )),
      SizedBox(height: 3.h)
    ]);
  }
}
