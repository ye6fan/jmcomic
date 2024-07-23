# jmcomic

[![flutter](https://img.shields.io/badge/flutter-3.22.2-blue)](https://flutter.dev/) 
[![Download](https://img.shields.io/github/v/release/ye6fan/jmcomic)](https://github.com/ye6fan/jmcomic/releases)

一个盗版的禁漫天堂。

## 功能

- 禁漫主页（最新页）
- 禁漫详情页
- 漫画观看（放大缩小、方向旋转）

## 开发中遇到的问题

- 问题1：在安卓虚拟机可以正常运行，但是安装到物理机后‘灰屏’卡死
- 解决1：Expanded组件必须在Row等组件中（所以为什么虚拟机就可以正确运行）
- 问题2：关于UI模式为immerse（全屏），状态栏依旧占用空间（一个黑条）
- 解决2：向android/app/src/main/res/values/styles.xml中的style标签里加入\<item name="android:windowLayoutInDisplayCutoutMode">shortEdges\</item>
- 问题3：安装在实体机上无法联网
- 解决3：直接在网上搜就可以了，向两个AndroidManifest.xml中加入一些配置

## Thanks

[![Readme Card](https://github-readme-stats.vercel.app/api/pin/?username=wgh136&repo=PicaComic)](https://github.com/wgh136/PicaComic)

本项目所有的代码都抄袭和修改自它，包括README格式。

## Screenshots

<img src="screenshots/jmlaste.jpg" style="width: 200px"><img src="screenshots/jminfo.jpg" style="width: 200px">
<img src="screenshots/jmlook.jpg" style="width: 200px"><img src="screenshots/fangda.jpg" style="width: 200px">
<img src="screenshots/hengping.jpg" style="width: 800px">
<img src="screenshots/winjm.bmp" style="width: 800px">
<img src="screenshots/wininfo.bmp" style="width: 800px">
<img src="screenshots/winlook.bmp" style="width: 800px">
