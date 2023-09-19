import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

initializeScreenSize(BuildContext context,
    {double width = 360, double height = 690}) {
  ScreenUtil.init(context, designSize: Size(width, height), minTextAdapt: true);
}

class ConstantWidgets {
  static Widget getCustomText(String text, Color color, int maxLine,
      TextAlign textAlign, FontWeight fontWeight, double textSizes) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: textSizes,
          color: color,
          fontWeight: fontWeight),
      maxLines: maxLine,
      textAlign: textAlign,
    );
  }

  static ButtonStyle dailyCountButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.redAccent[100]),
    );
  }

  /// Streaks, 달성일수, 전체일수, 퍼센트 감싸주는 원형 라인
  static BoxDecoration circularLineDecoration() {
    return BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        color: Colors.white,
        shape: BoxShape.circle);
  }
}
