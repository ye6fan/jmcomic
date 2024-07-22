import 'package:shared_preferences/shared_preferences.dart';

class Appdata {
  // 设置
  List<String> settings = [
    '0,1', // 0 构建有哪些导航页面
    '0', // 1 双击缩放
    '1', // 2 限制图片宽度
    '2', // 3 预加载图片个数
    '0', // 4 点击屏幕上下区域翻页
  ];

  // jm用户信息
  String jmName = "";
  String jmPwd = "";

  Future<void> writeData([bool sync = true]) async {
    // shared_preferences包，保存全局的数据
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

// 默认单例模式
var appdata = Appdata();
