import 'package:flutter/cupertino.dart';

class JmHomePage extends StatelessWidget {
  const JmHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      return const Center(child: Text('jm_home'));
    });
  }
}
