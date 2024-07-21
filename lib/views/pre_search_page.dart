import 'package:flutter/material.dart';

import 'main_page.dart';

class PreSearchPage extends StatelessWidget {
  const PreSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      return Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  onPressed: () => MainPage.back(),
                  icon: const Icon(Icons.arrow_back))),
          body: const Center(child: Text('pre_search')));
    });
  }
}
