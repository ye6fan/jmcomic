import 'package:flutter/material.dart';
import 'package:jmcomic/foundation/state_controller.dart';

import '../foundation/app_data.dart';
import 'jm_comic/jm_home_page.dart';
import 'jm_comic/jm_latest_page.dart';

class ExplorePage extends StatefulWidget {
  final int pages;

  const ExplorePage(this.pages, {super.key});

  static void Function(int index)? jumpTo;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  late TabController controller;

  Widget buildTab(String i) {
    return switch (i) {
      '0' => const Tab(text: 'jm最新', key: Key('jm最新')),
      '1' => const Tab(text: 'jm主页', key: Key('jm主页')),
      _ => Tab(text: i, key: Key(i)),
    };
  }

  Widget buildBody(String i) {
    return switch (i) {
      '0' => const JmLatestPage(),
      '1' => const JmHomePage(),
      _ => const Text('unknown'),
    };
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: widget.pages, vsync: this);
    ExplorePage.jumpTo = (index) {
      controller.animateTo(index);
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget tabBar = TabBar(
      tabs: appdata.settings[0].split(',').map((i) => buildTab(i)).toList(),
      splashBorderRadius: const BorderRadius.all(Radius.circular(10)),
      isScrollable: true,
      tabAlignment: TabAlignment.center,
      controller: controller,
    );

    return Stack(
      children: [
        Positioned.fill(
            child: Column(
          children: [
            tabBar,
            Expanded(
                child: TabBarView(
              controller: controller,
              children: appdata.settings[0]
                  .split(',')
                  .map((i) => buildBody(i))
                  .toList(),
            ))
          ],
        )),
        Positioned(
            right: 16,
            bottom: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 120),
              reverseDuration: const Duration(milliseconds: 120),
              transitionBuilder: (widget, animation) {
                var tween = Tween<Offset>(
                    begin: const Offset(0, 1), end: const Offset(0, 0));
                return SlideTransition(
                  position: tween.animate(animation),
                  child: widget,
                );
              },
            ))
      ],
    );
  }
}

class ExplorePageLogic extends StateController {}

class ExploreControllerPage extends StatelessWidget {
  const ExploreControllerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StateBuilder<ExplorePageLogic>(builder: (logic) {
      return const ExplorePage(
        2,
        key: Key('0,1'),
      );
    });
  }
}
