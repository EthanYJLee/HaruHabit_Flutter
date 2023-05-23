import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Card(
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.heart_fill,
                    size: 30,
                  ),
                  Text("Connect with Health")
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
