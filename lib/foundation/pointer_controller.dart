import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmcomic/app.dart';
import 'package:jmcomic/foundation/app_data.dart';
import 'package:jmcomic/foundation/state_controller.dart';
import 'package:jmcomic/views/comic_read_page.dart';

const _kMaxTapOffset = 4.0;

class PointerController {
  static int fingers = 0;
  static Offset? _pointerOffset;
  static bool ignoreNextPointer = false;
  static void Function(PointerUpEvent event)? onPointerUpReplacement;

  // Recognizer识别器absolute绝对
  static void Function(PointerUpEvent event)? _doubleClickRecognizer;

  static get logic => StateController.findOrNull<ComicReadPageLogic>()!;

  static void onPointerDown(PointerDownEvent event) {
    if (event.buttons == kSecondaryMouseButton) {
      return;
    }
    fingers++;
    if (ignoreNextPointer) {
      ignoreNextPointer = false;
      return;
    }
    // 这个刚好就是toolbar的上下高度
    if (logic.showToolbar &&
            event.position.dy <
                MediaQuery.of(App.globalContext!).padding.top + 50 ||
        MediaQuery.of(App.globalContext!).size.height - event.position.dy <
            MediaQuery.of(App.globalContext!).padding.bottom + 105) {
      return;
    }
    _pointerOffset = event.position;
  }

  static void onPointerUp(PointerUpEvent event) async {
    fingers--;
    if (onPointerUpReplacement != null) {
      onPointerUpReplacement!(event);
      onPointerUpReplacement = null;
      return;
    }
    if (_pointerOffset != null) {
      var distance = event.position.dy - _pointerOffset!.dy;
      if (distance > _kMaxTapOffset || distance < -_kMaxTapOffset) {
        return;
      }
      _pointerOffset = null;
    } else {
      return;
    }
    // 双击缩放
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
    _handleClick(event, logic, App.globalContext!);
  }

  static void onPointerCancel(PointerCancelEvent event) {
    fingers--;
  }

  static void _handleDoubleClick(Offset position) {}

  static void _handleClick(
      PointerUpEvent event, ComicReadPageLogic logic, BuildContext context) {
    bool flag1 = false;
    bool flag2 = false;
    // 翻页时识别的屏幕比例
    const range = 25 / 100;
    // 是否上下区域翻页
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
      logic.update(['toolbar']);
      if (!logic.showToolbar) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      }
    }
  }
}
