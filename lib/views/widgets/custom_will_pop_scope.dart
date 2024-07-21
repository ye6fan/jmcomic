import 'package:flutter/cupertino.dart';

class CustomWillPopScope extends StatelessWidget {
  final Widget child;
  final VoidCallback action;

  const CustomWillPopScope(
      {required this.child, required this.action, super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (value) {
          action();
        },
        child: child);
  }
}
