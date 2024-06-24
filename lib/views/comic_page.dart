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

  String get tag;

  String? get title;

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
                  buildTitle(logic),
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

  Widget buildTitle(ComicPageLogic<T> logic) {
    return SliverAppBar(
      shadowColor: Colors.transparent,
      title: AnimatedOpacity(
        opacity: 0.0,
        duration: const Duration(microseconds: 200),
        child: Text(title!),
      ),
      pinned: true,
      primary: true,
    );
  }

  Widget buildComicInfo(ComicPageLogic<T> logic, BuildContext context,
      [bool sliver = true]) {
    var body = LayoutBuilder(builder: (context, constrains) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 8,
                ),
                buildCover(context, logic, 136, 102),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: SelectableText(
                        title!,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                )),
              ],
            ),
          ).paddingHorizontal(10).paddingBottom(12),
          buildAction(logic, context, true).paddingHorizontal(12),
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

  Widget buildAction(
      ComicPageLogic<T> logic, BuildContext context, bool center) {
    if (logic.loading) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        height: 72,
        width: double.infinity,
      );
    }

    Widget buildItem(String title, IconData icon, void Function() onTap) {
      return SizedBox(
        width: 72,
        height: 64,
        child: Column(
          children: [
            const SizedBox(
              height: 12,
            ),
            Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            )
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
            alignment: center ? WrapAlignment.center : WrapAlignment.start,
            children: [
              buildItem('从头开始', Icons.not_started_outlined, () => read()),
            ],
          )
        ],
      ),
    );
  }

  Widget buildTags(ComicPageLogic<T> logic, BuildContext context) {
    return SliverToBoxAdapter(child: Text('tag'));
  }

  List<Widget> buildEpisodeInfo(BuildContext context) {
    return [SliverToBoxAdapter(child: Text('episode_info'))];
  }
}
