import 'package:flutter/material.dart';
import 'package:jmcomic/views/main_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      return Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  onPressed: () => MainPage.back(),
                  icon: const Icon(Icons.arrow_back))),
          body: const Center(child: Text('settings')));
    });
  }
}
