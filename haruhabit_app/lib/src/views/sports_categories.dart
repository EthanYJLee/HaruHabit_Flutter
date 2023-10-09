import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/utils/add_health.dart';
import 'package:haruhabit_app/src/utils/card_dialog.dart';

class SportsCategories extends StatefulWidget {
  const SportsCategories({super.key});

  @override
  State<SportsCategories> createState() => _SportsCategoriesState();
}

class _SportsCategoriesState extends State<SportsCategories> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/wallpaper.jpg'), // 배경 이미지
          ),
        ),
        height: MediaQuery.of(context).size.height / 1.1,
        width: MediaQuery.of(context).size.width,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('sports categories'),
          ),
          body: Center(
            child: Column(
              children: [
                Container(
                  height: 70,
                  padding: const EdgeInsets.only(left: 7, right: 7),
                  child: Card(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    elevation: 3,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('first cat'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 70,
                  padding: const EdgeInsets.only(left: 7, right: 7),
                  child: Card(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    elevation: 3,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('second cat'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(CardDialog(builder: (context) => AddHealth()));
                    },
                    child: const Text('add Workout'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
