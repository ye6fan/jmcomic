import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmcomic/foundation/app_controller.dart';
import 'package:jmcomic/views/main_page.dart';

import 'foundation/app_page_route.dart';
import 'foundation/log_manager.dart';
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
    // 设置导航栏为透明色
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false));
    //一个统一的颜色控制
    return DynamicColorBuilder(builder: (light, dark) {
      dark = ColorScheme.fromSeed(
          seedColor: const Color(0XFFEC407A), brightness: Brightness.dark);
      // scaffoldMessengerKey、navigatorKey是必要的，不然globalContext一直为null，必须在这里绑定
      // 根Element获得了一个初始的BuildContext，这个上下文包含了全局的环境信息，比如主题数据（ThemeData）
      // 随着构建过程向下遍历Element树，每个子Element都会继承其直接父级的context，并且可能会添加或修改某些特定于该Element的信息
      return MaterialApp(
        title: 'yefan',
        scaffoldMessengerKey: AppController.messageKey,
        navigatorKey: AppController.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: dark),
        onGenerateRoute: (settings) =>
            AppPageRoute(builder: (context) => const MainPage()),
      );
    });
  }
}
