import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:haruhabit_app/src/views/home.dart';
import 'package:haruhabit_app/src/views/tabbar.dart';

class App extends StatelessWidget {
  const App({super.key});

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
        primaryColor: Color.fromARGB(255, 255, 249, 244),
        canvasColor: Color.fromARGB(255, 255, 249, 244),
        appBarTheme: AppBarTheme(
          color: Color.fromARGB(255, 255, 249, 244),
          actionsIconTheme: IconThemeData(color: Colors.redAccent[100]),
          foregroundColor: Colors.redAccent[100],
        ),
        tabBarTheme: const TabBarTheme(),
        bottomAppBarTheme: BottomAppBarTheme(
          color: Color.fromARGB(255, 255, 249, 244),
        ),
        fontFamily: 'text',
      ),
      debugShowCheckedModeBanner: false,
      // home: const Tabbar(),
      // home: const Home(),
      // home: const Steps(),
      home: const Tabbar(),
    );
  }
}
