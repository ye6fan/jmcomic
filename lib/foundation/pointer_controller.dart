import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmcomic/app.dart';
import 'package:jmcomic/foundation/state_controller.dart';
import 'package:jmcomic/views/comic_read_page.dart';

const _kMaxTapOffset = 4.0;

class PointerController {
  static Offset? _pointerOffset;

  static get logic => StateController.findOrNull<ComicReadPageLogic>()!;

  static void onPointerDown(PointerDownEvent event) {
    if (logic.showToolbar &&
        (event.position.dy <
                MediaQuery.of(App.globalContext!).padding.top + 50 ||
            event.position.dy >
                MediaQuery.of(App.globalContext!).size.height -
                    MediaQuery.of(App.globalContext!).padding.bottom -
                    75)) {
      return;
    }
    _pointerOffset = event.position;
  }

  static void onPointerUp(PointerUpEvent event) async {
    if (_pointerOffset != null) {
      var distance = event.position.dy - _pointerOffset!.dy;
      if (distance > _kMaxTapOffset || distance < -_kMaxTapOffset) {
        return;
      }
      _pointerOffset = null;
    } else {
      return;
    }
    _handleClick(event, logic, App.globalContext!);
  }

  static void _handleClick(
      PointerUpEvent event, ComicReadPageLogic logic, BuildContext context) {
    logic.showToolbar = !logic.showToolbar;
    logic.update(['toolbar']);
    if (!logic.showToolbar) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }
}
