import 'package:flutter/material.dart';

mixin _AppRouteTransitionMixin<T> on PageRoute<T> {
  Widget? _child;

  // @protected注释表示自定义的方法，与父类无关
  @protected
  bool get preventRebuild;

  @protected
  Widget buildContent(BuildContext context);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  // 调试时输出额外信息
  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  // Transition转变barrier屏障maintain维护
  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // 判断是否阻止重新构建，如果阻止就重用_child，不阻止就构建新的
    if (preventRebuild) {
      _child = _child ?? buildContent(context);
    } else {
      _child = buildContent(context);
    }
    // Semantics提高应用的可访问性，支持阅读的辅助技术
    return Semantics(
        scopesRoute: true, explicitChildNodes: true, child: _child);
  }
}

class AppPageRoute<T> extends PageRoute<T> with _AppRouteTransitionMixin<T> {
  @override
  bool maintainState;

  @override
  bool preventRebuild;

  final WidgetBuilder builder;

  AppPageRoute(
      {required this.builder,
      this.preventRebuild = true,
      this.maintainState = true,
      super.settings});

  @override
  Widget buildContent(BuildContext context) => builder(context);
}
