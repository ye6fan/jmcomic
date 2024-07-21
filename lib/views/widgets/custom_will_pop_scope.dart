import 'package:flutter/cupertino.dart';

class CustomWillPopScope extends StatelessWidget {
  final Widget child;
  final VoidCallback action;

  const CustomWillPopScope(
      {required this.child, required this.action, super.key});

  @override
  Widget build(BuildContext context) {
    // 子树内的任何地方发生pop事件都会传到这里并调用action
    return PopScope(
        onPopInvoked: (value) {
          action();
        },
        child: child);
  }
}
