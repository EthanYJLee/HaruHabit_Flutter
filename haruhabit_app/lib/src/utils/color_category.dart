import 'package:flutter/material.dart';

Color bgDarkWhite = "#FFFFFF".toColor();
Color textGrey = "#AAAAAA".toColor();
Color blueColor = "#EDF2FF".toColor();
Color primaryColor = const Color(0xFFF6F6F6);
Color accentColor = "#396ADB".toColor();
Color subTextColor = "#B3B3B3".toColor();
Color descriptionColor = "#525252".toColor();
Color introMainColor = "#E5EDFF".toColor();
Color textColorDark = "#777777".toColor();
Color greyWhite = const Color(0xFFEBEAEF);
Color darkGrey = const Color(0xFFEBEAEF);
Color greenButton = const Color(0xFF37BD4D);
Color blueButton = const Color(0xFF0078FF);
Color quickSvgColor = const Color(0xFF283182);
Color bmiBgColor = "#2C698D".toColor();
Color bmiDarkBgColor = const Color(0xFF134B6D);
Color lightPink = const Color(0xFFFBE8EA);
Color itemBgColor = const Color(0xFFF2F1F4);
Color textColor = Colors.black;
Color borderColor = "#DFDFDF".toColor();
Color shadowColor = "#1423408F".toColor();
Color lightOrange = "#FFF0EA".toColor();
Color containerShadow = "#33ACB6B5".toColor();
Color grayLight = "#DDDDDD".toColor();
Color mainColor = "#F0F0F0".toColor();
Color cellColor = "#F9F9F9".toColor();
Color bgColor = "#F4F4F4".toColor();
Color splashTxtColor = const Color.fromRGBO(255, 255, 255, 0.77);
Color category1 = "#D5F7E4".toColor();
Color category2 = "#E8E5FF".toColor();
Color category3 = "#CFE5FF".toColor();
Color category4 = "#FBD9FF".toColor();
Color category5 = "#D6F4FF".toColor();
Color category6 = "#FFECDB".toColor();
Color category7 = "#D6F4FF".toColor();

Color shapeColor1 = "#B3E2C8".toColor();
Color shapeColor2 = "#D1CBFF".toColor();
Color shapeColor3 = "#AED2FF".toColor();
Color shapeColor4 = "#F9C7FF".toColor();
Color shapeColor5 = "#B0E9FE".toColor();
Color shapeColor6 = "#FFD8B6".toColor();

getCellColor(int index) {
  if (index % 7 == 0) {
    return category1;
  } else if (index % 7 == 1) {
    return category2;
  } else if (index % 7 == 2) {
    return category3;
  } else if (index % 7 == 3) {
    return category4;
  } else if (index % 7 == 4) {
    return category5;
  } else if (index % 7 == 5) {
    return category6;
  } else if (index % 7 == 6) {
    return category7;
  } else {
    return category1;
  }
}

getCellShapeColor(int index) {
  if (index % 7 == 0) {
    return shapeColor1;
  } else if (index % 7 == 1) {
    return shapeColor2;
  } else if (index % 7 == 2) {
    return shapeColor3;
  } else if (index % 7 == 3) {
    return shapeColor4;
  } else if (index % 7 == 4) {
    return shapeColor5;
  } else if (index % 7 == 5) {
    return shapeColor6;
  } else {
    return shapeColor1;
  }
}

extension ColorExtension on String {
  toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}
