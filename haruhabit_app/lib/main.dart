import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  runApp(EasyLocalization(
      supportedLocales: supportedLocales,
      path: "assets/translations",
      // supportedLocales에 설정한 언어가 없는 경우 설정되는 Default 언어
      fallbackLocale: const Locale('en', 'US'),
      child: const App()));
}
