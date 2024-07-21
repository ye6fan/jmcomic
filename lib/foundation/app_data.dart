import 'package:shared_preferences/shared_preferences.dart';

class Appdata {
  // 设置
  List<String> settings = [
    '0,1', // 0 构建首页漫画导航页面
    '0', // 1 双击缩放
    '1', // 2 限制图片宽度
    '2', // 3 预加载图片个数
    '0', // 4 点击屏幕左右区域翻页
  ];

  // jm相关信息
  String jmName = "";
  String jmPwd = "";

  Future<void> writeData([bool sync = true]) async {
    var s = await SharedPreferences.getInstance();
    await s.setString("jmName", jmName);
    await s.setString("jmPwd", jmPwd);
  }

  Future<void> readData() async {
    var s = await SharedPreferences.getInstance();
    jmName = s.getString("jmName") ?? "";
    jmPwd = s.getString("jmPwd") ?? "";
  }
}

var appdata = Appdata();
