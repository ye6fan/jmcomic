import 'package:flutter/cupertino.dart';
import 'package:jmcomic/foundation/image_loader/animated_image.dart';
import 'package:jmcomic/foundation/image_loader/image_manager.dart';
import 'package:jmcomic/views/comic_read_page.dart';
import 'package:photo_view/photo_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../app.dart';
import '../foundation/app_data.dart';

extension ImageExt on ComicReadPage {
  Widget buildComicView(
      ComicReadPageLogic logic, BuildContext context, String ep) {
    // 构造漫画的列表
    Widget buildTopToBottomContinuous() {
      // 普通的构造方法，另一个是多一个构建分隔符widget的方法
      // physics物理特性clamping夹紧，猜测作用是使用电脑端放大缩小
      return ScrollablePositionedList.builder(
          itemScrollController: logic.itemScrollController,
          itemPositionsListener: logic.itemScrollListener,
          itemCount: logic.urls.length,
          addSemanticIndexes: false,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            double width = MediaQuery.of(context).size.width;
            double imageWidget = width;
            ImageProvider imageProvider = createImageProvider(logic, index, ep);
            precacheComicImage(logic, context, index + 1, ep);
            // 只用设置宽度，高度会自动计算
            return AnimatedImage(image: imageProvider, width: imageWidget);
          });
    }

    // 构造图片查看器支持手势缩放和平移，它直接包裹整个漫画列表，但是手势必须平行屏幕边界
    // 普通构造函数只可以传递ImageProvider，命名构造函数可以传递Widget
    Widget body = PhotoView.customChild(
        key: Key('ep${logic.epIndex}'),
        minScale: 1.0,
        maxScale: 2.5,
        // 严格遵守minScale和maxScale的限制
        strictScale: true,
        controller: logic.photoViewControllers[0],
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: buildTopToBottomContinuous()));

    return Positioned.fill(
        top: App.isDesktop ? MediaQuery.of(context).padding.top : 0,
        child: Listener(
            child:
                NotificationListener<ScrollUpdateNotification>(child: body)));
  }
}

ImageProvider createImageProvider(
    ComicReadPageLogic logic, int index, String ep) {
  return logic.readData.createImageProvider(ep, index, logic.urls[index]);
}

void precacheComicImage(
    ComicReadPageLogic logic, BuildContext context, int index, String ep) {
  if (logic.requestedLoadingItems.length != logic.urls.length) {
    logic.requestedLoadingItems = List.filled(logic.urls.length, false);
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
