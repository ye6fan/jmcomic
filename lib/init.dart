import 'package:jmcomic/foundation/app_data.dart';

import 'app.dart';
import 'foundation/log_manager.dart';

Future<void> init() async {
  try {
    LogManager.addLog(LogLevel.info, 'App Status', 'Start initialization.');
    // 获取禁漫用户信息
    await appdata.readData();
    // 获取app默认的各种路径和分隔符
    await App.init();
  } catch (e) {
    LogManager.addLog(LogLevel.error, 'Init', 'App initialization failed!\n$e');
  }
}
