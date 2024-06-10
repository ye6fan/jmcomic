import 'base.dart';
import 'foundation/app.dart';
import 'foundation/log.dart';

Future<void> init() async {
  try {
    LogManager.addLog(LogLevel.info, "App Status", "Start initialization.");
    //获取jm账号密码
    await appdata.readData();
    //获取缓存路径和数据路径
    await App.init();
  } catch (e, s) {
    LogManager.addLog(
        LogLevel.error, "Init", "App initialization failed!\n$e$s");
  }
}
