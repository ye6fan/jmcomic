import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:jmcomic/foundation/image_loader/animated_image.dart';
import 'package:jmcomic/foundation/image_loader/image_manager.dart';
import 'package:jmcomic/views/comic_read_page.dart';
import 'package:photo_view/photo_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../app.dart';
import '../foundation/app_data.dart';

extension ScrollExtension on ScrollController {
  static double? futurePosition;

  void smoothTo(double value) {
    futurePosition ??= position.pixels;
    futurePosition = futurePosition! + value * 1.2;
    futurePosition = futurePosition!
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    animateTo(futurePosition!,
        duration: const Duration(milliseconds: 150), curve: Curves.linear);
  }
}

extension ImageExt on ComicReadPage {
  Widget buildComicView(
      ComicReadPageLogic logic, BuildContext context, String ep) {
    ScrollExtension.futurePosition = null; // 滚动扩展的属性声明为null
    logic.photoViewControllers[0] ??= PhotoViewController();
    // 构造漫画的列表
    Widget buildTopToBottomContinuous() {
      //普通的构造方法，另一个是多一个构建分隔符widget的方法
      // physics物理特性clamping夹紧
      return ScrollablePositionedList.builder(
          itemScrollController: logic.itemScrollController,
          itemPositionsListener: logic.itemScrollListener,
          itemCount: logic.urls.length,
          addSemanticIndexes: false,
          physics: (logic.noScroll ||
                  logic.isCtrlPressed ||
                  (logic.mouseScroll && !App.isMacOS))
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            double width = MediaQuery.of(context).size.width;
            double height = MediaQuery.of(context).size.height;
            double imageWidget = width;
            if (height / width < 1.2 && appdata.settings[2] == '1') {
              imageWidget = height / 1.2;
            }
            ImageProvider imageProvider = createImageProvider(logic, index, ep);
            precacheComicImage(logic, context, index + 1, ep);
            return AnimatedImage(image: imageProvider, width: imageWidget);
          });
    }

    // 构造图片查看器支持手势缩放和平移，它直接包裹整个漫画列表
    // 普通构造函数只可以传递ImageProvider，命名构造函数可以传递Widget
    Widget body = PhotoView.customChild(
        key: Key('ep${logic.epIndex}'),
        minScale: 1.0,
        maxScale: 2.5,
        // 严格遵守minScale和maxScale的限制
        strictScale: true,
        controller: logic.photoViewControllers[0],
        // 当用户完成缩放手势时调用
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
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: buildTopToBottomContinuous()));

    return Positioned.fill(
        top: App.isDesktop ? MediaQuery.of(context).padding.top : 0,
        child: Listener(
            onPointerPanZoomUpdate: (event) {
              if (event.kind == PointerDeviceKind.trackpad) {
                if (event.scale == 1.0) {
                  logic.scrollController.smoothTo(0 - event.panDelta.dy * 1.2);
                }
              }
            },
            onPointerDown: (event) => logic.mouseScroll = false,
            child:
                NotificationListener<ScrollUpdateNotification>(child: body)));
  }
}

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
