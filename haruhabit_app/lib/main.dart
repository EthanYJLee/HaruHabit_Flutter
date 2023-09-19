import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:haruhabit_app/app.dart';
import 'package:haruhabit_app/src/views/home.dart';
import 'package:haruhabit_app/src/views/tabbar.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

final supportedLocales = [
  const Locale('en', 'US'),
  const Locale('ko', 'KR'),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    Phoenix(
      child: EasyLocalization(
          supportedLocales: supportedLocales,
          path: "assets/translations",
          // supportedLocales에 설정한 언어가 없는 경우 default로 영어 설정
          fallbackLocale: const Locale('en', 'US'),
          child: const App()),
    ),
  );
}
