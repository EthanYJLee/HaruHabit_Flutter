import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:haruhabit_app/views/tabbar.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haru Habit',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ko'), // Korean
      ],
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 164, 158, 255),
        canvasColor: Color.fromRGBO(223, 221, 255, 1),
        appBarTheme: const AppBarTheme(color: Color.fromRGBO(223, 221, 255, 1)),
      ),
      debugShowCheckedModeBanner: false,
      home: const Tabbar(),
    );
  }
}
