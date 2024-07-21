import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmcomic/foundation/app_controller.dart';
import 'package:jmcomic/foundation/state_controller.dart';
import 'package:jmcomic/views/pre_search_page.dart';
import 'package:jmcomic/views/settings_page.dart';
import 'package:jmcomic/views/widgets/custom_navigation_bar.dart';
import 'package:jmcomic/views/widgets/custom_will_pop_scope.dart';

import '../foundation/app_page_route.dart';
import 'explore_page.dart';
import 'me_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static GlobalKey<NavigatorState>? navigatorKey;

  static void to(Widget Function() page) async {
    AppController.to(navigatorKey!.currentContext!, page);
  }

  //其实导航主要操作的是NavigatorState，of方法返回的就是context的state
  static bool canPop() =>
      Navigator.of(navigatorKey!.currentContext ?? AppController.globalContext!)
          .canPop();

  static void back() {
    if (canPop()) {
      navigatorKey!.currentState?.pop();
    }
  }

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int i = 0;

  final pages = [
    const ExploreControllerPage(
      key: Key('0'),
    ),
    const MePage(
      key: Key('1'),
    ),
  ];

  void initLogic() {
    //初始化（put）logic的目的就是为了取出来，然后进行构造函数
    StateController.put(ExplorePageLogic(), tag: 'explore_logic');
  }

  @override
  void initState() {
    super.initState();
    initLogic();
    MainPage.navigatorKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    var titles = ['探索', '我的'];

    return Material(
      child: CustomWillPopScope(
        action: () {
          if (MainPage.canPop()) {
            MainPage.back();
          } else {
            SystemNavigator.pop();
          }
        }, //返回时main页执行的返回逻辑
        child: Expanded(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ), //填充手机刘海
              Expanded(
                child: ClipRect(
                  child: Navigator(
                    key: MainPage.navigatorKey,
                    onGenerateRoute: (settings) => AppPageRoute(
                        preventRebuild: false,
                        builder: (context) {
                          return Column(
                            children: [
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
                                  duration: const Duration(milliseconds: 120),
                                  reverseDuration:
                                      const Duration(milliseconds: 120),
                                  child: pages[i],
                                ),
                              ),
                              CustomNavigationBar(
                                onDestinationSelected: (int index) {
                                  setState(() {
                                    i = index;
                                  });
                                },
                                selectedIndex: i,
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
                              )
                            ],
                          );
                        }),
                  ), //没想到Navigator也可以作为组件
                ),
              )
            ],
          ),
        ),
      ), //自定义返回弹窗操作
    );
  }
}
