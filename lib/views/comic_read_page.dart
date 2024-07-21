import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmcomic/foundation/pointer_controller.dart';
import 'package:jmcomic/foundation/state_controller.dart';
import 'package:jmcomic/views/image_page.dart';
import 'package:jmcomic/views/widgets/toolbar.dart';
import 'package:photo_view/photo_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../app.dart';
import '../network/base_models.dart';
import '../network/jm_network/jm_models.dart';

class ComicReadPageLogic extends StateController {
  bool loading = false;
  int page; // 漫画页数
  int ep; // 漫画的章节数，第一章绝对不是1是546831（举个例子）
  ReadData readData;
  String? errorMessage;
  var urls = <String>[]; // 漫画图片的请求URL
  var requestedLoadingItems = <bool>[];
  var focusNode = FocusNode();
  bool noScroll = false; // 不滚动？
  bool showToolbar = true; // 展示工具栏
  int showFloatingButtonValue = 0;
  double fABValue = 0; // 什么作用？
  double currentScale = 1.0;
  ScrollManager? scrollManager;

  // 判断是否是桌面端，鼠标滚动
  bool mouseScroll = App.isDesktop;

  // ctrl键是否被按下 Hardware硬件、Keyboard键盘
  bool get isCtrlPressed => HardwareKeyboard.instance.isControlPressed;

  // 我真是服了，居然让我用各种各样的方法进行手动导包
  var itemScrollController = ItemScrollController(); // 通过滚动条直接跳转
  // 当前滚动到的元素序号，底层创建了ItemPositionsNotifier（通知者）
  var itemScrollListener = ItemPositionsListener.create();

  // 索引当前页
  late int _index;

  int get index => _index;

  var scrollController = ScrollController();

  set index(int value) {
    _index = value;
    for (var element in _indexChangeCallbacks) {
      element(value);
    }
  }

  final _indexChangeCallbacks = <void Function(int)>[];

  // 图像控制器
  PhotoViewController get photoViewController =>
      photoViewControllers[index] ?? photoViewControllers[0]!;

  var photoViewControllers = <int, PhotoViewController>{};

  ComicReadPageLogic(this.page, this.ep, this.readData);

  late final void Function() openEpsView; // 新加的方法，控制章节试图展示
  // 我笑了，统一成get了
  Future<void> get() async {
    if (loading) return;
    loading = true;
    var res = await readData.loadEp(ep);
    if (res.errorMessage != null) {
      errorMessage = res.errorMessage;
    } else {
      urls = res.data!;
    }
    update();
  }

  void handleKeyboard(KeyEvent event) {
    if (event is KeyUpEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.arrowRight:
          jumpToNextPage();
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.arrowLeft:
          jumpToLastPage();
        case LogicalKeyboardKey.f12:
          fullscreen();
      }
    }
  }

  void jumpToNextPage() {}

  void jumpToLastPage() {}

  void fullscreen() {}

  void jumpToNextChapter() {}
}

class ComicReadPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final int initPage;
  final int initEp;
  final ReadData readData;

  // 在调用构造函数时，就已经添加过logic
  ComicReadPage.jmComic(String id, String name, List<String> epIds,
      List<String> epNames, this.initEp,
      {super.key, this.initPage = 1})
      : readData = JmReadData(id, name, epIds, epNames) {
    StateController.put(ComicReadPageLogic(initPage, initEp, readData),
        autoRemove: true);
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder(initState: (logic) {
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
                      AppBar(
                        shadowColor: Colors.transparent,
                        title: const AnimatedOpacity(
                          opacity: 0.0,
                          duration: Duration(microseconds: 200),
                        ),
                        primary: true,
                      ),
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
                    opacity: 0.0,
                    duration: Duration(microseconds: 200),
                  ),
                  primary: true,
                ),
                Center(child: Text(logic.errorMessage!))
              ]);
            } else {
              logic.scrollManager = ScrollManager(logic, context);

              var body = Listener(
                  onPointerDown: PointerController.onPointerDown,
                  onPointerUp: PointerController.onPointerUp,
                  onPointerCancel: PointerController.onPointerCancel,
                  behavior: HitTestBehavior.translucent,
                  child: Stack(
                    children: [
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
                    ],
                  ));
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
