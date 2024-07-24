import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmcomic/views/main_page.dart';

import 'app.dart';
import 'foundation/app_page_route.dart';
import 'foundation/log_manager.dart';
import 'init.dart';

void main() {
  // Guarded守卫，经常用于main函数
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // 自定义的初始化
    await init();
    // 全局异常处理器
    FlutterError.onError = (details) {
      LogManager.addLog(LogLevel.error, 'Unhandled Exception',
          '${details.exception}\n${details.stack}');
    };
    runApp(const MyApp());
  }, (error, stack) {
    LogManager.addLog(LogLevel.error, 'Unhandled Exception', '$error\n$stack');
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false));
    // App.navigatorKey要在这里绑定，不然后续的globalContext为null
    return MaterialApp(
        title: 'yefan',
        navigatorKey: App.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.pinkAccent, brightness: Brightness.dark),
            useMaterial3: true),
        onGenerateRoute: (settings) =>
            AppPageRoute(builder: (context) => const MainPage()));
  }
}
