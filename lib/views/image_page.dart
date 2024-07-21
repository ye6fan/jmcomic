import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:jmcomic/foundation/app_controller.dart';
import 'package:jmcomic/foundation/image_loader/animated_image.dart';
import 'package:jmcomic/foundation/image_loader/image_manager.dart';
import 'package:jmcomic/views/comic_read_page.dart';
import 'package:photo_view/photo_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../foundation/app_data.dart';

extension ScrollExtension on ScrollController {
  static double? futurePosition;

  void smoothTo(double value) {
    futurePosition ??= position.pixels;
    futurePosition = futurePosition! + value * 1.2;
    futurePosition = futurePosition!
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    animateTo(futurePosition!,
        duration: Duration(milliseconds: 200), curve: Curves.linear);
  }
}

extension ImageExt on ComicReadPage {
  Widget buildComicView(
      ComicReadPageLogic logic, BuildContext context, String ep) {
    ScrollExtension.futurePosition = null; // 滚动扩展的属性声明为null
    logic.photoViewControllers[0] ??= PhotoViewController(); // 赋值
    // 构造漫画的列表
    Widget buildTopToBottomContinuous() {
      //普通的构造方法，还有一个是多一个构建分隔符的方法
      return ScrollablePositionedList.builder(
          itemScrollController: logic.itemScrollController,
          itemPositionsListener: logic.itemScrollListener,
          itemCount: logic.urls.length,
          addSemanticIndexes: false,
          // 感觉是滑动时的位置指示条
          physics: (logic.noScroll ||
                  logic.isCtrlPressed ||
                  (logic.mouseScroll && !AppController.isMacOS))
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          // 物理特性，clamping夹紧
          itemBuilder: (context, index) {
            double width = MediaQuery.of(context).size.width;
            double height = MediaQuery.of(context).size.height;
            // 不知道是否没有设置图片宽度导致图片没有全屏，感觉不是
            double imageWidget = width;
            // 判断是否为宽屏，宽屏就不铺满屏幕了
            if (height / width < 1.2 && appdata.settings[2] == '1') {
              imageWidget = height / 1.2;
            }
            // 处理当前的漫画图片
            ImageProvider imageProvider = createImageProvider(logic, index, ep);
            // 预处理往后的漫画图片
            precacheComicImage(logic, context, index + 1, ep);
            // 这个列表好用不用去设置什么每行几列、每列的宽和高是多少，全部自适应
            return AnimatedImage(image: imageProvider, width: imageWidget);
          });
    }

    // 构造图片查看器支持手势缩放和平移，它直接包裹整个漫画列表
    // 普通构造函数只可以传递ImageProvider，命名构造函数可以传递Widget
    Widget body = PhotoView.customChild(
      key: Key(logic.ep.toString()),
      minScale: 1.0,
      maxScale: 2.5,
      strictScale: true,
      // 严格遵守minScale和maxScale的限制
      controller: logic.photoViewControllers[0],
      onScaleEnd: (context, details, value) {
        var prev = logic.currentScale;
        logic.currentScale = value.scale ?? 1.0;
        if ((prev <= 1.05 && logic.currentScale > 1.05) ||
            (prev > 1.05 && logic.currentScale <= 1.05)) {
          logic.update();
        }
        if (appdata.settings[2] != '1') {
          return false;
        }
        return updateLocation(context, logic.photoViewController);
      },
      // 当用户完成缩放手势时调用
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: buildTopToBottomContinuous(),
      ),
    );

    return Positioned.fill(
        top: AppController.isDesktop ? MediaQuery.of(context).padding.top : 0,
        child: Listener(
          onPointerPanZoomUpdate: (event) {
            if (event.kind == PointerDeviceKind.trackpad) {
              if (event.scale == 1.0) {
                logic.scrollController.smoothTo(0 - event.panDelta.dy * 1.2);
              }
            }
          },
          onPointerDown: (event) => logic.mouseScroll = false,
          child: NotificationListener<ScrollUpdateNotification>(
            child: body,
            onNotification: (notification) {
              // update floating button
              if (!logic.scrollController.hasClients) return false;
              var value =
                  logic.itemScrollListener.itemPositions.value.first.index + 1;
              if (value != logic.index) {
                logic.index = value;
                logic.update();
              }
              return true;
            }, // 就这个通知导致漫画锁死，false没有处理滚动通知，向上抛；true已经处理不向上抛
          ),
        )); // 漫画锁死的原因就在这里
  }
}

// 添加这个方法后就成功显示漫画图片了
bool updateLocation(BuildContext context, PhotoViewController controller) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  // 对于电脑和平板并不给予全屏操作
  if (width / height < 1.2) {
    return false;
  }
  // 获取图片当前的位置和缩放比例
  final currentLocation = controller.position; // Offset
  final scale = controller.scale ?? 1;
  final imageWidth = height / 1.2; // 默认的图片宽度
  final showWidth = width / scale; // 展示的图片宽度
  // 如果手机竖屏imageWidth一定大于showWidth
  if (showWidth >= imageWidth && currentLocation.dx != 0) {
    // 修改x坐标让其变窄，y坐标不变
    controller.updateMultiple(
        position: Offset(controller.initial.position.dx, currentLocation.dy));
    return true;
  }
  if (showWidth < imageWidth) {
    // 这两个边界看不懂
    final lEdge = (width - imageWidth) / 2;
    final rEdge = width - lEdge;
    // 像这种除以2的操作都是为了求‘中心点坐标’
    final showLEdge =
        (0 - currentLocation.dx) / scale - showWidth / 2 + width / 2;
    final showREdge =
        (0 - currentLocation.dx) / scale + showWidth / 2 + width / 2;
    final updateValue = (width / 2 - (rEdge - showWidth / 2)) * scale;
    if (lEdge > showLEdge) {
      controller.updateMultiple(
          position: Offset(0 - updateValue, currentLocation.dy));
      return true;
    } else if (rEdge < showREdge) {
      controller.updateMultiple(
          position: Offset(updateValue, currentLocation.dy));
      return true;
    }
  }
  return false;
}

ImageProvider createImageProvider(
    ComicReadPageLogic logic, int index, String ep) {
  return logic.readData.createImageProvider(ep, index, logic.urls[index]);
}

void precacheComicImage(
    ComicReadPageLogic logic, BuildContext context, int index, String ep) {
  if (logic.requestedLoadingItems.length != logic.urls.length) {
    // 为什么多一位
    logic.requestedLoadingItems = List.filled(logic.urls.length + 1, false);
  }
  int precacheNum = int.parse(appdata.settings[3]) + index;
  for (; index < precacheNum; index++) {
    if (index >= logic.urls.length || logic.requestedLoadingItems[index]) {
      return;
    }
    // flutter内置方法
    precacheImage(createImageProvider(logic, index, ep), context);
  }
  // 唉，我倒是不反感敲代码的强迫症，所以if一定要带{},++、+=也是要用的
  if (!ImageManager.hasTask) {
    precacheNum += 3;
    for (; index < precacheNum; index++) {
      if (index >= logic.urls.length || logic.requestedLoadingItems[index]) {
        return;
      }
      precacheImage(createImageProvider(logic, index, ep), context);
    }
  }
}
