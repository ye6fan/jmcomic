import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmcomic/foundation/state_controller.dart';
import 'package:jmcomic/views/pre_search_page.dart';
import 'package:jmcomic/views/settings_page.dart';
import 'package:jmcomic/views/widgets/custom_navigation_bar.dart';
import 'package:jmcomic/views/widgets/custom_will_pop_scope.dart';

import '../app.dart';
import '../foundation/app_page_route.dart';
import 'explore_page.dart';
import 'me_page.dart';

class MainPage extends StatefulWidget {
  // const减少内存分配和提高性能，在编译时就创建对象
  const MainPage({super.key});

  // key要被绑定到widget上，才可以正常使用
  @protected
  static final navigatorKey = GlobalKey<NavigatorState>();

  static void to(Widget Function() page) async {
    App.to(navigatorKey.currentContext!, page);
  }

  static bool canPop() {
    return Navigator.of(navigatorKey.currentContext!).canPop();
  }

  static void back() {
    if (canPop()) {
      navigatorKey.currentState?.pop();
    }
  }

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 标识app的导航栏索引
  int i = 0;

  final pages = [
    const ExploreControllerPage(
      key: Key('page0'),
    ),
    const MePage(
      key: Key('page1'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    //初始化logic，当调用页面的构造函数时，可以取出对应的logic
    StateController.put(ExplorePageLogic(), tag: 'explore_logic');
  }

  @override
  Widget build(BuildContext context) {
    var titles = ['探索', '我的'];
    // Expanded要在Row中，不然灰屏
    return Material(
        child: CustomWillPopScope(
            action: () {
              if (MainPage.canPop()) {
                MainPage.back();
              } else {
                SystemNavigator.pop();
              }
            },
            child: Row(children: [
              Expanded(
                  child: Column(children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                Expanded(
                    child: ClipRect(
                        child: Navigator(
                            key: MainPage.navigatorKey,
                            onGenerateRoute: (settings) => AppPageRoute(
                                preventRebuild: false,
                                builder: (context) {
                                  // 顶部状态栏、内容、底部导航栏，Destination目的地
                                  return Column(children: [
                                    AppBar(
                                      title: Text(titles[i]),
                                      actions: [
                                        Tooltip(
                                          message: '搜索',
                                          child: IconButton(
                                            icon: const Icon(Icons.search),
                                            onPressed: () => MainPage.to(
                                                () => const PreSearchPage()),
                                          ),
                                        ),
                                        Tooltip(
                                          message: '设置',
                                          child: IconButton(
                                            icon: const Icon(Icons.settings),
                                            onPressed: () => MainPage.to(
                                                () => const SettingsPage()),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 150),
                                        reverseDuration:
                                            const Duration(milliseconds: 150),
                                        child: pages[i],
                                      ),
                                    ),
                                    CustomNavigationBar(
                                        destinations: const <NavigationItemData>[
                                          NavigationItemData(
                                            icon: Icon(Icons.explore_outlined),
                                            selectedIcon: Icon(Icons.explore),
                                            label: '探索',
                                          ),
                                          NavigationItemData(
                                            icon: Icon(Icons.person_outlined),
                                            selectedIcon: Icon(Icons.person),
                                            label: '我的',
                                          ),
                                        ],
                                        selectedCallback: (int index) {
                                          setState(() {
                                            i = index;
                                          });
                                        },
                                        selectedIndex: i)
                                  ]);
                                }))))
              ]))
            ])));
  }
}
