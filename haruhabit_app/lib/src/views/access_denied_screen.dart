import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class AccessDeniedScreen extends StatefulWidget {
  const AccessDeniedScreen({super.key});

  @override
  State<AccessDeniedScreen> createState() => _AccessDeniedScreenState();
}

class _AccessDeniedScreenState extends State<AccessDeniedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("접근 권한 허용"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Apple Health 접근 권한을 허용해주세요"))
          ],
        ),
      ),
    );
  }
}
