import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'foundation/app_page_route.dart';
import 'foundation/log_manager.dart';

class App {
  // 平台信息
  static bool get isAndroid => Platform.isAndroid;

  static bool get isIOS => Platform.isIOS;

  static bool get isWindows => Platform.isWindows;

  static bool get isMacOS => Platform.isMacOS;

  static bool get isDesktop => Platform.isWindows || Platform.isMacOS;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static final navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get globalContext => navigatorKey.currentContext;

  static late final String cachePath;

  static late final String separator;

  static Future<void> init() async {
    cachePath = (await getApplicationCacheDirectory()).path;
    separator = Platform.pathSeparator;
  }

  static Future<T?> to<T extends Object?>(
      BuildContext context, Widget Function() page) {
    LogManager.addLog(LogLevel.info, "App Status",
        "Going to Page /${page.runtimeType.toString().replaceFirst("() => ", "")}");
    return Navigator.of(context)
        .push<T>(AppPageRoute(builder: (context) => page()));
  }
}
