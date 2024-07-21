import 'package:flutter/material.dart';

class ListLoadingIndicator extends StatelessWidget {
  const ListLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // stroke笔画
    return const SizedBox(
        width: double.infinity,
        height: 80,
        child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(strokeWidth: 3)),
          SizedBox(width: 40),
          Text('加载中...')
        ])));
  }
}
