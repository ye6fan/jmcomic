import 'package:flutter/material.dart';

class AppPageRoute<T> extends PageRoute<T> with _AppRouteTransitionMixin {
  // 页面从路由被移除时，页面的状态（State）
  @override
  bool maintainState;

  @override
  bool preventRebuild;

  final WidgetBuilder builder;

  AppPageRoute({
    required this.builder,
    this.preventRebuild = true,
    this.maintainState = true,
  });

  @override
  Widget buildContent(BuildContext context) => builder(context);
}

mixin _AppRouteTransitionMixin<T> on PageRoute<T> {
  Widget? _child;

  @protected
  bool get preventRebuild;

  @protected
  Widget buildContent(BuildContext context);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

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
    // 判断是否阻止重新构建，如果阻止就重用，不阻止就导航新的
    if (preventRebuild) {
      _child = _child ?? buildContent(context);
    } else {
      _child = buildContent(context);
    }
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _child,
    );
  }
}
