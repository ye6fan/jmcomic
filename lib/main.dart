import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plagiarize/views/main_page.dart';

import 'foundation/app_page_route.dart';
import 'foundation/log.dart';
import 'init.dart';

bool notFirstUse = false;

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    //初始化
    await init();
    FlutterError.onError = (details) {
      LogManager.addLog(LogLevel.error, "Unhandled Exception",
          "${details.exception}\n${details.stack}");
    };
    runApp(const MyApp());
  }, (error, stack) {
    LogManager.addLog(LogLevel.error, "Unhandled Exception", "$error\n$stack");
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    //不知道什么用？
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    //一个统一的颜色控制
    return DynamicColorBuilder(builder: (light, dark) {
      dark = ColorScheme.fromSeed(
          seedColor: const Color(0XFFEC407A), brightness: Brightness.dark);
      return MaterialApp(
        title: 'yefan',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: dark),
        onGenerateRoute: (settings) =>
            AppPageRoute(builder: (context) => const MainPage()),
      );
    });
  }
}
