import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

/// Desc : 일정, 건강 데이터 등 리스트를 보여주는 Card 범위의 Header
/// Date : 2023.06.20
class Header extends StatelessWidget {
  const Header({super.key, required this.title, required this.destination});
  final String title;
  final dynamic destination;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 30, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          // TextButton(
          //   onPressed: () {},
          //   child: const Text(
          //     "View all",
          //     style: TextStyle(
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.black),
          //   ),
          // ),
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => destination));
              },
              icon: const Icon(CupertinoIcons.right_chevron))
        ],
      ),
    );
  }
}
