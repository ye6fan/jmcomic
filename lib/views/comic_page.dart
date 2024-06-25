import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plagiarize/foundation/state_controller.dart';
import 'package:plagiarize/foundation/widget_extension.dart';

import '../network/res.dart';

class ComicPageLogic<T> extends StateController {
  bool loading = false;
  T? data;
  String? errorMessage;
  ScrollController controller = ScrollController();

  Future<void> get(Future<Res<T>> Function() loadData) async {
    var res = await loadData();
    loading = true;
    if (res.errorMessage != null) {
      errorMessage = res.errorMessage;
    } else {
      data = res.data;
    }
    update();
  }
}

abstract class ComicPage<T> extends StatelessWidget {
  const ComicPage({super.key});

  String get tag; // 用于标识controller(logic)的字符串

  Map<String, List<String>> get labels; // 漫画标签列表为了防止混淆，不起名为tags

  String? get name;

  @nonVirtual
  T? get data => _logic.data;

  Future<Res<T>> loadData();

  void read();

  ComicPageLogic<T> get _logic =>
      StateController.findOrNull<ComicPageLogic<T>>(tag: tag)!;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: StateBuilder<ComicPageLogic<T>>(
          tag: tag,
          init: ComicPageLogic<T>(),
          builder: (logic) {
            if (!logic.loading) {
              logic.get(loadData);
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            } else if (logic.errorMessage != null) {
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  const Center(
                    child: Text('error'),
                  )
                ],
              );
            } else {
              return CustomScrollView(
                controller: logic.controller,
                slivers: [
                  buildAppBar(logic),
                  buildComicInfo(logic, context),
                  buildTags(logic, context),
                  ...buildEpisodeInfo(context),
                  SliverPadding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom),
                  ),
                ],
              );
            }
          },
        ), // StateBuilder需要logic，因为调用builder时需要logic中的属性
      );
    });
  }

  Widget buildAppBar(ComicPageLogic<T> logic) {
    return SliverAppBar(
      shadowColor: Colors.transparent,
      title: AnimatedOpacity(
        opacity: 0.0,
        duration: const Duration(microseconds: 200),
        child: Text(name!),
      ),
      pinned: true,
      primary: true,
    ); // 这个组件默认包含了返回按钮并且可以使用，和自动去掉顶部导航栏
  }

  Widget buildComicInfo(ComicPageLogic<T> logic, BuildContext context,
      [bool sliver = true]) {
    var body = LayoutBuilder(builder: (context, constrains) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 6,
                ),
                buildCover(context, logic, 102, 136),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: SelectableText(
                    name!,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ).paddingHorizontal(10).paddingBottom(16),
          buildAction(logic, context).paddingHorizontal(16),
        ],
      );
    });
    return SliverToBoxAdapter(child: body);
  }

  Widget buildCover(BuildContext context, ComicPageLogic<T> logic,
      double widget, double height) {
    return Container(
      width: widget,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget buildAction(ComicPageLogic<T> logic, BuildContext context) {
    Widget buildItem(String title, IconData icon, void Function() onTap) {
      return SizedBox(
        width: 72,
        height: 64,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(
              height: 8,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ), // 额，事实证明字体大小不意味着像素大小
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              buildItem('开始', Icons.not_started_outlined, () => read()),
              buildItem(
                  '收藏', Icons.collections_bookmark_outlined, () => read()),
              buildItem('喜欢', Icons.favorite_border, () => read()),
              buildItem('评论', Icons.comment, () => read()),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                    child: FilledButton.tonal(
                        onPressed: () => {}, child: Text('下载'))),
                const SizedBox(width: 16),
                Expanded(
                    child: FilledButton.tonal(
                        onPressed: () => {}, child: Text('阅读'))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildTags(ComicPageLogic<T> logic, BuildContext context) {
    return SliverToBoxAdapter(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(
          '信息',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ).paddingLeft(16),
        const SizedBox(height: 8),
        ...buildTagsCards(logic, context),
        const Divider(),
      ],
    ));
  }

  Iterable<Widget> buildTagsCards(
      ComicPageLogic<T> logic, BuildContext context) sync* {
    for (var key in labels.keys) {
      yield Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Wrap(
          children: [
            buildTagCard(key, context, true),
            for (var val in labels[key]!) buildTagCard(val, context, false)
          ],
        ),
      );
    }
  }

  Widget buildTagCard(String label, BuildContext context, bool title) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Card(
          color: Color(title ? 0XFF5C6BC0 : 0XFF26A69A).withOpacity(0.5),
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Text(
              label,
              style: TextStyle(fontSize: 13),
            ),
          ), // 字体与边框的填充
        ),
      ),
    );
  }

  List<Widget> buildEpisodeInfo(BuildContext context) {
    return [SliverToBoxAdapter(child: Text('episode_info'))];
  }
}
