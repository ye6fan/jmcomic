import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmcomic/foundation/pointer_controller.dart';
import 'package:jmcomic/foundation/state_controller.dart';
import 'package:jmcomic/views/image_page.dart';
import 'package:jmcomic/views/widgets/toolbar.dart';
import 'package:photo_view/photo_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../network/base_models.dart';
import '../network/jm_network/jm_models.dart';

class ComicReadPageLogic extends StateController {
  bool loading = false;
  int page; // 漫画页数
  int epIndex; // 漫画的章节数
  ReadData readData;

  ComicReadPageLogic(this.page, this.epIndex, this.readData);

  String? errorMessage;
  var urls = <String>[]; // 漫画图片的请求URL
  var requestedLoadingItems = <bool>[]; // 防止重复加载
  var focusNode = FocusNode(); // 大概作为key使用
  bool showToolbar = false; // 展示工具栏
  bool? rotation; // null跟随系统, false竖向, true横向

  // 通过滚动条直接跳转
  var itemScrollController = ItemScrollController();

  // 当前滚动到的元素序号，底层创建了ItemPositionsNotifier（通知者）
  var itemScrollListener = ItemPositionsListener.create();

  PhotoViewController photoViewController = PhotoViewController();

  var photoViewControllers = <int, PhotoViewController>{};

  Future<void> get() async {
    if (loading) return;
    loading = true;
    var res = await readData.loadEp(epIndex);
    if (res.errorMessage != null) {
      errorMessage = res.errorMessage;
    } else {
      urls = res.data!;
    }
    update();
  }

  // 下面5个方法都没有实现
  void handleKeyboard(KeyEvent event) {}

  void jumpToNextPage() {}

  void jumpToLastPage() {}

  void fullscreen() {}

  void jumpToNextChapter() {}
}

class ComicReadPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final int initPage;
  final int initEpIndex;
  final ReadData readData;
  late final double? stateBarHeight; // immersive模式下状态栏高度为0，所以提前保存一下高度
  // 在调用构造函数时，就已经添加过logic
  ComicReadPage.jmComic(String id, String name, List<String> epIds,
      List<String> epNames, this.initEpIndex,
      {super.key, this.initPage = 1})
      : readData = JmReadData(id, name, epIds, epNames) {
    StateController.put(ComicReadPageLogic(initPage, initEpIndex, readData),
        autoRemove: true);
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder(initState: (logic) {
      stateBarHeight = MediaQuery.of(context).padding.top;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }, dispose: (logic) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }, builder: (logic) {
      return Scaffold(
          backgroundColor: Colors.black,
          key: _scaffoldKey,
          body: StateBuilder<ComicReadPageLogic>(builder: (logic) {
            if (!logic.loading) {
              logic.get();
              return DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Center(
                      child: Column(
                    children: [
                      SizedBox(height: stateBarHeight),
                      AppBar(
                          shadowColor: Colors.transparent,
                          title: const AnimatedOpacity(
                              opacity: 0.0,
                              duration: Duration(microseconds: 150))),
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    ],
                  )));
            } else if (logic.errorMessage != null) {
              return Column(children: [
                AppBar(
                    shadowColor: Colors.transparent,
                    title: const AnimatedOpacity(
                        opacity: 0.0, duration: Duration(microseconds: 150))),
                Center(child: Text(logic.errorMessage!))
              ]);
            } else {
              // 监听手势
              var body = Listener(
                  onPointerDown: PointerController.onPointerDown,
                  onPointerUp: PointerController.onPointerUp,
                  behavior: HitTestBehavior.translucent,
                  child: Stack(children: [
                    buildComicView(logic, context, readData.id),
                    Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                            child: ColoredBox(
                                color: Colors.black.withOpacity(0.2)))),
                    buildTopToolbar(logic, context),
                    buildBottomToolbar(logic, context)
                  ]));
              // 监听键盘
              return KeyboardListener(
                  focusNode: logic.focusNode,
                  autofocus: true,
                  onKeyEvent: logic.handleKeyboard,
                  child: body);
            }
          }));
    });
  }
}
