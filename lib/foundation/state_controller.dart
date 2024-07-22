import 'package:flutter/cupertino.dart';

class Pair<L, R> {
  L left;
  R right;

  Pair(this.left, this.right);
}

class StateControllerWrapped {
  StateController controller;
  bool autoRemove;
  String? tag;

  StateControllerWrapped(this.controller, this.autoRemove, this.tag);
}

abstract class StateController {
  static final _controllers = <StateControllerWrapped>[];
  List<Pair<String?, void Function()>> stateUpdates = [];

  void update([List<String>? ids]) {
    if (ids == null) {
      for (var element in stateUpdates) {
        element.right();
      }
    } else {
      for (var element in stateUpdates) {
        if (ids.contains(element.left)) {
          element.right();
        }
      }
    }
  }

  // 在这里调用autoRemove默认为false
  static T put<T extends StateController>(T controller,
      {String? tag, bool autoRemove = false}) {
    _controllers.add(StateControllerWrapped(controller, autoRemove, tag));
    return controller;
  }

  static T? findOrNull<T extends StateController>({Object? tag}) {
    // 这里之所以是tag == null是为了共用logic
    return _controllers
        .lastWhere((element) =>
            element.controller is T && (tag == null || tag == element.tag))
        .controller as T;
  }

  static void remove<T>([Object? tag]) {
    final index = _controllers.indexWhere((element) =>
        element.controller is T && tag == element.tag && element.autoRemove);
    if (index != -1) _controllers.removeAt(index);
  }
}

class StateBuilder<T extends StateController> extends StatefulWidget {
  final String? tag; // 标识一整个state
  final String? id; // 标识state中的部分组件，更新时可以部分更新
  final T? controller; // 外面传进来用作初始化的controller
  final Widget Function(T controller) builder;
  final void Function(T controller)? initState;
  final void Function(T controller)? dispose;

  const StateBuilder(
      {super.key,
      required this.builder,
      this.tag,
      this.id,
      this.controller,
      this.initState,
      this.dispose});

  @override
  State<StateBuilder<T>> createState() => _StateBuilderState<T>();
}

// 泛型要规定和声明好，不然state调不了widget的方法
class _StateBuilderState<T extends StateController>
    extends State<StateBuilder<T>> {
  late T _controller; // 查找列表中已经存在的_controller

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      // 在这里调用autoRemove默认为true
      StateController.put(widget.controller!,
          tag: widget.tag, autoRemove: true);
    }
    _controller = StateController.findOrNull<T>(tag: widget.tag)!;
    _controller.stateUpdates.add(Pair(widget.id, () {
      if (mounted) {
        setState(() {});
      }
    }));
    // 外界传递的initState函数可以在这里调用，不过要在_controller初始化后
    if (widget.initState != null) {
      widget.initState!(_controller);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller);

  @override
  void dispose() {
    // 写在remove前
    if (widget.dispose != null) {
      widget.dispose!(_controller);
    }
    StateController.remove<T>(widget.tag);
    super.dispose();
  }
}
