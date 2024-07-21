import 'package:flutter/material.dart';
import 'package:jmcomic/foundation/state_controller.dart';
import 'package:jmcomic/foundation/widget_extension.dart';
import 'package:jmcomic/views/comic_read_page.dart';
import 'package:jmcomic/views/main_page.dart';

extension ToolBar on ComicReadPage {
  // 我就知道加不加init、tag参数都一样，毕竟用的都是同一个logic
  Widget buildTopToolbar(ComicReadPageLogic logic, BuildContext context) {
    return Positioned(
        top: 0,
        child: StateBuilder<ComicReadPageLogic>(
            id: 'toolbar',
            builder: (logic) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                reverseDuration: const Duration(milliseconds: 150),
                child: logic.showToolbar
                    ? Material(
                        surfaceTintColor:
                            Theme.of(context).colorScheme.surfaceTint,
                        elevation: 3,
                        shadowColor: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withOpacity(0.3),
                        child: SizedBox(
                          width:
                              MediaQuery.of(context).size.width, // 删了就不显示name了？
                          height: 50, // 感觉高度由内组件决定
                          child: Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: Tooltip(
                                      message: '返回',
                                      child: IconButton(
                                          iconSize: 25,
                                          icon: Icon(Icons.arrow_back),
                                          onPressed: () => MainPage.back()))),
                              Expanded(
                                  child: Container(
                                height: 50,
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 75),
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    readData.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ).paddingTop(MediaQuery.of(context).padding.top))
                    : const SizedBox())));
  }

  // 不知道为什么透明的红屏，所以改为topToolBar的写法
  Widget buildBottomToolbar(ComicReadPageLogic logic, BuildContext context) {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: StateBuilder<ComicReadPageLogic>(
            id: 'toolbar',
            builder: (logic) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                reverseDuration: const Duration(milliseconds: 150),
                child: logic.showToolbar
                    ? Material(
                        surfaceTintColor:
                            Theme.of(context).colorScheme.surfaceTint,
                        elevation: 3,
                        shadowColor: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withOpacity(0.3),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 80, // 限高之后可以滑动了
                            child: Column(children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Container(
                                      height: 24,
                                      padding:
                                          const EdgeInsets.fromLTRB(6, 2, 6, 2),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text('E1 : P1')) // 这里为null导致红屏且划不动
                                ],
                              ),
                              const Spacer(),
                              Row(children: [
                                Tooltip(
                                    message: '方向',
                                    child: IconButton(
                                      icon: const Icon(Icons.directions),
                                      onPressed: () {},
                                    )),
                                Tooltip(
                                    message: '收藏图片',
                                    child: IconButton(
                                        icon: const Icon(Icons.favorite),
                                        onPressed: () {}))
                              ])
                            ])).paddingBottom(MediaQuery.of(
                                context)
                            .padding
                            .bottom))
                    : const SizedBox())));
  }
}
