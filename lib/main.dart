import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmcomic/views/main_page.dart';

import 'app.dart';
import 'foundation/app_page_route.dart';
import 'foundation/log_manager.dart';
import 'init.dart';

bool notFirstUse = false;

void main() {
  // Guarded守卫，经常用于main函数
  runZonedGuarded(() async {
    // 确保Flutter的渲染系统和其他关键组件已经被正确初始化
    WidgetsFlutterBinding.ensureInitialized();
    // 自定义的初始化
    await init();
    // 全局异常处理器
    FlutterError.onError = (details) {
      LogManager.addLog(LogLevel.error, 'Unhandled Exception',
          '${details.exception}\n${details.stack}');
    };
    // 入口
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
    // systemNavigationBar底部导航栏、statusBar顶部状态栏，将它们设置为transparent透明
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false));
    // dynamic_color包中提供统一的颜色和布局的根widget，theme主题scheme计划
    return DynamicColorBuilder(builder: (light, dark) {
      // 设置种子可以生成一个完整的颜色方案
      dark = ColorScheme.fromSeed(
          seedColor: const Color(0XFFEC407A), brightness: Brightness.dark);
      // messageKey、navigatorKey要在这里绑定，不然后续访问会为null
      return MaterialApp(
          title: 'yefan',
          scaffoldMessengerKey: App.messageKey,
          navigatorKey: App.navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorScheme: dark),
          onGenerateRoute: (settings) =>
              AppPageRoute(builder: (context) => const MainPage()));
    });
  }
}
