import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmcomic/foundation/app_data.dart';
import 'package:jmcomic/foundation/state_controller.dart';
import 'package:jmcomic/views/comic_read_page.dart';

const _kMaxTapOffset = 4.0;

class ScrollManager {
  ComicReadPageLogic logic;
  BuildContext context;

  // 不知道为什么up和down方法都没有使用这个logic
  ScrollManager(this.logic, this.context);

  Offset? pointerLocation;
  Offset? moveOffset;
  int? startTime;

  int get fingers => PointerController.fingers;
}

class _PointerTap {
  int id;
  Offset offset;

  _PointerTap(this.id) : offset = Offset(0, 0);

  double getDistance() {
    return offset.dx * offset.dx + offset.dy * offset.dy;
  }
}

class PointerController {
  static int fingers = 0;
  static Offset? _pointerOffset;
  static bool ignoreNextPointer = false;
  static _PointerTap? _pointerTap;
  static void Function(PointerUpEvent event)? onPointerUpReplacement;
  static void Function(PointerUpEvent event)? _doubleClickRecognizer;

  static DateTime lastScrollTime = DateTime(2023);

  static void onPointerDown(PointerDownEvent event) {
    if (event.buttons == kSecondaryMouseButton) {
      return;
    }
    fingers++;
    if (ignoreNextPointer) {
      ignoreNextPointer = false;
      return;
    }
    var logic = StateController.findOrNull<ComicReadPageLogic>()!;
    // 这里运行的时候，总是globalContext为空并报错,而且这个刚好就是toolbar的上下高度
    if (logic.showToolbar &&
            event.position.dy <
                MediaQuery.of(logic.scrollManager!.context).padding.top + 50 ||
        MediaQuery.of(logic.scrollManager!.context).size.height -
                event.position.dy <
            MediaQuery.of(logic.scrollManager!.context).padding.bottom + 105) {
      return;
    }
    // if (event.buttons == kSecondaryMouseButton) {} // 原作者这里有个方法，但是这里明显是执行不到的
    // 判断是否含有‘客户端’？我感觉这个作者的所有代码都可以去优化，应该是否被注册
    _pointerOffset = event.position;
  }

  static void onPointerUp(PointerUpEvent event) async {
    fingers--;
    if (onPointerUpReplacement != null) {
      onPointerUpReplacement!(event);
      onPointerUpReplacement = null;
      return;
    }
    var logic = StateController.findOrNull<ComicReadPageLogic>()!;
    _pointerTap = null;
    if (_pointerOffset != null) {
      var distance = event.position.dy - _pointerOffset!.dy;
      // 这里怎么是正和负呢
      if (distance > _kMaxTapOffset || distance < -_kMaxTapOffset) {
        return;
      }
      _pointerOffset = null;
    } else {
      return;
    }
    if (appdata.settings[1] == '1') {
      if (_doubleClickRecognizer == null) {
        bool flag = false;
        _doubleClickRecognizer = (another) async {
          var d = event.delta - another.delta;
          if (d.dx.abs() < 30 && d.dy.abs() < 30) {
            flag = true;
          }
          await Future.delayed(const Duration(milliseconds: 200));
          _doubleClickRecognizer = null;
          if (flag) {
            _handleDoubleClick(event.position);
            return;
          } else {
            _doubleClickRecognizer!.call(event);
            return;
          }
        };
      }
    }
    _handleClick(event, logic, logic.scrollManager!.context);
  }

  static void onPointerCancel(PointerCancelEvent event) {
    fingers--;
  }

  static void _handleDoubleClick(Offset position) {
    var logic = StateController.findOrNull<ComicReadPageLogic>()!;
    var controller = logic.photoViewController;
    double target;
    // 很多方法都没有定义
    /*if (controller.scale == null ||
        controller.getInitialScale?.call() == null) {
      return;
    }
    if (controller.scale != controller.getInitialScale?.call()) {
      target = controller.getInitialScale!.call()!;
    } else {
      target = controller.getInitialScale!.call()! * 1.75;
    }
    var size = MediaQuery
        .of(App.globalContext!)
        .size;
    controller.animateScale?.call(target,
        Offset(size.width / 2 - position.dx, size.height / 2 - position.dy));*/
  }

  static void _handleClick(
      PointerUpEvent event, ComicReadPageLogic logic, BuildContext context) {
    bool flag1 = false;
    bool flag2 = false;
    // 为什么这里是活的，这个是翻页时，识别的屏幕比例
    final range = 25 / 100;
    if (appdata.settings[4] == '1' && !logic.showToolbar) {
      event.position.dy > MediaQuery.of(context).size.height * (1 - range)
          ? logic.jumpToNextPage()
          : flag1 = true;
      event.position.dy < MediaQuery.of(context).size.height * range
          ? logic.jumpToNextPage()
          : flag2 = true;
    } else {
      flag1 = true;
      flag2 = true;
    }
    // 这里就是更新导航栏的地方
    if (flag1 && flag2) {
      logic.showToolbar = !logic.showToolbar;
      logic.update(['toolbar']); // 这个方法我还真没有写
      if (!logic.showToolbar) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      }
    }
  }
}
