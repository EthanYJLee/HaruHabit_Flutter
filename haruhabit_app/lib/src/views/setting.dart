import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/utils/constant_widgets.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
    );
  }

  categoryMessage(String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ConstantWidgets.getCustomText(
          text, Colors.grey, 1, TextAlign.start, FontWeight.w500, 14),
    );
  }
}
