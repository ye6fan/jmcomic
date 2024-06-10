import 'package:flutter/cupertino.dart';

class StateControllerWrapped {
  StateController controller;
  bool autoRemove;
  String? tag;

  StateControllerWrapped(this.controller, this.autoRemove, this.tag);
}

abstract class StateController {
  static final _controllers = <StateControllerWrapped>[];
  void Function() stateUpdate = () {};

  static T put<T extends StateController>(T controller,
      {bool autoRemove = false, String? tag}) {
    _controllers.add(StateControllerWrapped(controller, autoRemove, tag));
    return controller;
  }

  static T putIfNotExists<T extends StateController>(T controller,
      {bool autoRemove = false, String? tag}) {
    return findOrNull<T>(tag: tag) ??
        put(controller, autoRemove: autoRemove, tag: tag);
  }

  static T? findOrNull<T extends StateController>({Object? tag}) {
    return _controllers
        .lastWhere((element) =>
            element.controller is T && (tag == null || tag == element.tag))
        .controller as T;
  }

  static void remove<T>([Object? tag, bool check = false]) {
    final index = _controllers.indexWhere((element) =>
        element.controller is T &&
        (tag == null || tag == element.tag) &&
        (!check || element.autoRemove));
    if (index != -1) _controllers.removeAt(index);
  }

  void update() => stateUpdate();
}

class StateBuilder<T extends StateController> extends StatefulWidget {
  final String? tag;
  final T? init;
  final Widget Function(T controller) builder;

  const StateBuilder({super.key, required this.builder, this.tag, this.init});

  @override
  State<StateBuilder> createState() => _StateBuilderState<T>();
}

class _StateBuilderState<T extends StateController>
    extends State<StateBuilder<T>> {
  late T controller;

  @override
  void initState() {
    super.initState();
    if (widget.init != null) {
      StateController.put(widget.init!, tag: widget.tag, autoRemove: true);
    }
    controller = StateController.findOrNull<T>(tag: widget.tag)!;
    controller.stateUpdate = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) => widget.builder(controller);

  @override
  void dispose() {
    StateController.remove<T>(widget.tag, true);
    super.dispose();
  }
}
