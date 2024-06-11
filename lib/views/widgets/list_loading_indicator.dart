import 'package:flutter/material.dart';

class ListLoadingIndicator extends StatelessWidget {
  const ListLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 80,
      child: Center(
        child: SizedBox(
          width: 100,
          height: 60,
          child: Row(
            children: [
              SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
              Text('    加载中...'),
            ],
          ),
        ),
      ),
    );
  }
}
