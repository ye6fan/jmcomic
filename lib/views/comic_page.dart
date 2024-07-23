import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jmcomic/foundation/image_loader/image_manager.dart';
import 'package:jmcomic/foundation/image_loader/stream_image_provider.dart';
import 'package:jmcomic/foundation/state_controller.dart';
import 'package:jmcomic/foundation/widget_extension.dart';
import 'package:jmcomic/views/widgets/sliver_grid_delegate.dart';

import '../network/base_models.dart';

@immutable
class EpsData {
  final List<String> epNames;
  final void Function(int) onTap;

  const EpsData(this.epNames, this.onTap);
}

class ComicPageLogic<T> extends StateController {
  bool loading = false; // 是否加载完漫画信息
  T? data; // 接收漫画信息
  String? errorMessage;
  ScrollController controller = ScrollController();
  bool reserveEpsOrder = false;
  bool showFullEps = false;

  Future<void> get(Future<Res<T>> Function() loadComicInfo) async {
    var res = await loadComicInfo();
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

  String get tag;

  Future<Res<T>> loadComicInfo();

  String get name;

  EpsData? get epsData;

  String get coverUrl;

  Map<String, List<String>> get labels;

  ComicPageLogic<T> get _logic =>
      StateController.findOrNull<ComicPageLogic<T>>(tag: tag)!;

  @nonVirtual
  T get data => _logic.data!;

  void read();

  @override
  Widget build(BuildContext context) {
    final Widget appBar = AppBar(
        shadowColor: Colors.transparent,
        title: const AnimatedOpacity(
            opacity: 0.0, duration: Duration(microseconds: 150)));

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          body: StateBuilder<ComicPageLogic<T>>(
              tag: tag,
              controller: ComicPageLogic<T>(),
              builder: (logic) {
                if (!logic.loading) {
                  logic.get(loadComicInfo);
                  return Column(children: [
                    appBar,
                    const Expanded(
                        child: Center(child: CircularProgressIndicator()))
                  ]);
                } else if (logic.errorMessage != null) {
                  return Column(children: [
                    appBar,
                    Center(child: Text(_logic.errorMessage!))
                  ]);
                } else {
                  return CustomScrollView(
                      controller: logic.controller,
                      slivers: [
                        buildAppBar(logic, context),
                        buildComicInfo(logic, context),
                        buildTags(logic, context),
                        ...buildEpisodeInfo(context),
                        SliverPadding(
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).padding.bottom))
                      ]);
                }
              }));
    });
  }

  // 构建顶部导航栏pinned固定
  buildAppBar(ComicPageLogic<T> logic, BuildContext context) {
    return const SliverAppBar(
        shadowColor: Colors.transparent,
        title: AnimatedOpacity(
            opacity: 0.0, duration: Duration(microseconds: 200)),
        pinned: true);
  }

  // 构建封面和名字
  Widget buildComicInfo(ComicPageLogic<T> logic, BuildContext context) {
    var body = LayoutBuilder(builder: (context, constrains) {
      return Column(children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 6),
              buildCover(context, logic, 102, 136),
              const SizedBox(width: 16),
              Expanded(
                child:
                    SelectableText(name, style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ).paddingHorizontal(10).paddingBottom(16),
        buildAction(logic, context).paddingHorizontal(16)
      ]);
    });
    return SliverToBoxAdapter(child: body);
  }

  // 将构建封面进行抽离
  Widget buildCover(BuildContext context, ComicPageLogic<T> logic, double width,
      double height) {
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Image(
            image: StreamImageProvider(
                coverUrl, () => ImageManager().getImage(coverUrl))));
  }

  // 构建开始、收藏、喜欢、评论；下载、阅读;tonal音调的
  Widget buildAction(ComicPageLogic<T> logic, BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Wrap(alignment: WrapAlignment.center, children: [
            buildItem('开始', Icons.not_started_outlined, () => read(), context),
            buildItem('收藏', Icons.collections_bookmark_outlined, () => read(),
                context),
            buildItem('喜欢', Icons.favorite_border, () => read(), context),
            buildItem('评论', Icons.comment, () => read(), context)
          ]),
          const SizedBox(height: 8),
          SizedBox(
              height: 48,
              child: Row(children: [
                Expanded(
                    child: FilledButton.tonal(
                        onPressed: () => {}, child: const Text('下载'))),
                const SizedBox(width: 16),
                Expanded(
                    child: FilledButton.tonal(
                        onPressed: () => read(), child: const Text('阅读')))
              ]))
        ]));
  }

  // 将构建Action的4个图标方法进行解耦
  Widget buildItem(String title, IconData icon, void Function() onTap,
      BuildContext context) {
    return SizedBox(
        width: 72,
        height: 64,
        child: Column(children: [
          const SizedBox(height: 12),
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12))
        ]));
  }

  // 构建漫画标签
  Widget buildTags(ComicPageLogic<T> logic, BuildContext context) {
    return SliverToBoxAdapter(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Divider(),
      const Text('信息',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18))
          .paddingLeft(20),
      const SizedBox(height: 8),
      ...buildTagsCards(logic, context)
    ]));
  }

  // 构建漫画标签卡片的逻辑
  Iterable<Widget> buildTagsCards(
      ComicPageLogic<T> logic, BuildContext context) sync* {
    for (var key in labels.keys) {
      yield Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Wrap(children: [
            buildTagCard(key, context, true),
            for (var val in labels[key]!) buildTagCard(val, context, false)
          ]));
    }
  }

  // 具体的构建漫画标签过程
  Widget buildTagCard(String label, BuildContext context, bool title) {
    return Container(
        margin: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: InkWell(
            borderRadius: BorderRadius.circular(12),
            child: Card(
                color: title
                    ? const Color(0XFF5C6BC0).withOpacity(0.5)
                    : Theme.of(context).secondaryHeaderColor,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child:
                        Text(label, style: const TextStyle(fontSize: 13))))));
  }

  // 构建章节信息
  Iterable<Widget> buildEpisodeInfo(BuildContext context) sync* {
    yield const SliverToBoxAdapter(child: Divider());
    yield SliverToBoxAdapter(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Text('章节',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
              const Spacer(),
              Tooltip(
                  message: '排序',
                  child: IconButton(
                      icon: Icon(_logic.reserveEpsOrder
                          ? Icons.align_vertical_top
                          : Icons.align_vertical_bottom),
                      onPressed: () {
                        _logic.reserveEpsOrder = !_logic.reserveEpsOrder;
                        _logic.update();
                      }))
            ])));
    yield const SliverPadding(padding: EdgeInsets.all(6));
    int length = epsData!.epNames.length;
    if (!_logic.showFullEps) {
      length = min(length, 20);
    }
    if (epsData!.epNames.isEmpty) {
      return;
    }
    final colorScheme = Theme.of(context).colorScheme;
    yield SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverGrid(
          delegate:
              SliverChildBuilderDelegate(childCount: length, (context, index) {
            if (_logic.reserveEpsOrder) {
              index = epsData!.epNames.length - index - 1;
            }
            return Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: Material(
                        elevation: 5,
                        color: colorScheme.surface,
                        surfaceTintColor: colorScheme.surfaceTint,
                        borderRadius: BorderRadius.circular(12),
                        shadowColor: Colors.transparent,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Center(
                                child: Text(epsData!.epNames[index],
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis)))),
                    onTap: () => epsData!.onTap(index)));
          }),
          gridDelegate: SliverGridDelegateWithFixedHeight(48, 200)),
    );
    if (epsData!.epNames.length > 20 && !_logic.showFullEps) {
      yield SliverToBoxAdapter(
          child: Align(
              alignment: Alignment.center,
              child: FilledButton.tonal(
                      onPressed: () {
                        _logic.showFullEps = true;
                        _logic.update();
                      },
                      child: Text('显示全部 ( ${epsData!.epNames.length} )'))
                  .paddingTop(12)));
    }
  }
}
