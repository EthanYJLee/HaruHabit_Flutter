import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haruhabit_app/src/views/home.dart';
import 'package:haruhabit_app/src/views/splash_screen.dart';
import 'package:haruhabit_app/src/views/tabbar.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          title: 'Haru Habit',
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              color: Colors.transparent,
              actionsIconTheme: IconThemeData(color: Colors.redAccent[100]),
              foregroundColor: Colors.redAccent[100],
            ),
            tabBarTheme: const TabBarTheme(),
            bottomAppBarTheme: const BottomAppBarTheme(
              color: Color.fromARGB(255, 255, 249, 244),
            ),
            fontFamily: 'text',
          ),
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        );
      },
    );
  }
}
