import 'package:shared_preferences/shared_preferences.dart';

class Appdata {
  ///设置
  List<String> settings = ['0,1'];

  //jm相关信息
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
