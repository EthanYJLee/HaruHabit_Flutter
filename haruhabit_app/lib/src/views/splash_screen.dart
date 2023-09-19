import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:haruhabit_app/src/utils/constant_widgets.dart';
import 'package:haruhabit_app/src/views/tabbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// 로딩 화면 보여주는 Splash Screen
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(milliseconds: 1200), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Tabbar()));
    });
  }

  @override
  Widget build(BuildContext context) {
    const String imageLogoName = 'assets/images/logo.png';
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    initializeScreenSize(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Scaffold(
          backgroundColor: Colors.redAccent[100],
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.3),
                Container(
                  child: Image.asset(
                    imageLogoName,
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.3,
                  ),
                ),
                Expanded(child: SizedBox()),
                Align(
                  child: Text("© Copyright 2023, Haru Habit",
                      style: TextStyle(
                        fontSize: screenWidth * (14 / 360),
                        color: Color.fromRGBO(255, 255, 255, 0.77),
                      )),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.0625,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
