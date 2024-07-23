import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmcomic/foundation/state_controller.dart';
import 'package:jmcomic/foundation/widget_extension.dart';
import 'package:jmcomic/views/comic_read_page.dart';
import 'package:jmcomic/views/main_page.dart';

extension ToolBar on ComicReadPage {
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
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: Row(children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: Tooltip(
                                      message: '返回',
                                      child: IconButton(
                                          iconSize: 25,
                                          icon: const Icon(Icons.arrow_back),
                                          onPressed: () => MainPage.back()))),
                              Expanded(
                                  child: Container(
                                      height: 50,
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              75),
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Text(readData.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 20)))))
                            ])).paddingTop(MediaQuery.of(context).padding.top))
                    : const SizedBox())));
  }

  Widget buildBottomToolbar(ComicReadPageLogic logic, BuildContext context) {
    // rotation旋转direction方向portrait肖像、竖向的landscape景观、横向的
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
                            height: 80,
                            child: Column(children: [
                              const SizedBox(height: 8),
                              Row(children: [
                                const SizedBox(width: 8),
                                Container(
                                    height: 24,
                                    padding:
                                        const EdgeInsets.fromLTRB(6, 2, 6, 2),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Text('E1 : P1'))
                              ]),
                              const Spacer(),
                              Row(children: [
                                Tooltip(
                                    message: '方向',
                                    child: IconButton(
                                        icon: () {
                                          if (logic.rotation == null) {
                                            return const Icon(
                                                Icons.screen_rotation);
                                          } else if (logic.rotation == false) {
                                            return const Icon(
                                                Icons.screen_lock_portrait);
                                          } else {
                                            return const Icon(
                                                Icons.screen_lock_landscape);
                                          }
                                        }.call(),
                                        onPressed: () {
                                          if (logic.rotation == null) {
                                            logic.rotation = false;
                                            logic.update();
                                            SystemChrome
                                                .setPreferredOrientations([
                                              DeviceOrientation.portraitUp,
                                              DeviceOrientation.portraitDown,
                                            ]);
                                          } else if (logic.rotation == false) {
                                            logic.rotation = true;
                                            logic.update();
                                            SystemChrome
                                                .setPreferredOrientations([
                                              DeviceOrientation.landscapeLeft,
                                              DeviceOrientation.landscapeRight
                                            ]);
                                          } else {
                                            logic.rotation = null;
                                            logic.update();
                                            SystemChrome
                                                .setPreferredOrientations(
                                                    DeviceOrientation.values);
                                          }
                                        })),
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
