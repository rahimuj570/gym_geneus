import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../res/assets/asset.dart';

class BackButtonBox extends StatelessWidget {
  const BackButtonBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: SvgPicture.asset(ImageAssets.svg4, fit: BoxFit.contain),
      ),
    );
  }
}
