import 'package:flutter/material.dart';
import 'package:jmcomic/foundation/state_controller.dart';
import 'package:jmcomic/views/widgets/list_loading_indicator.dart';
import 'package:jmcomic/views/widgets/sliver_grid_delegate.dart';

import '../network/base_models.dart';
import '../network/jm_network/jm_models.dart';
import 'jm_comic/jm_comic_tile.dart';

class ComicsPageLogic<T> extends StateController {
  int current = 1;
  List<T>? comics;
  bool firstLoading = true; //判断是否初次加载，页面渲染
  bool loading = false; //判断是否加载当前页，防止重复加载
  String? errorMessage;

  void get(Future<Res<List<T>>> Function(int) getComics) async {
    if (loading) return;
    loading = true;
    if (comics == null) {
      var res = await getComics(1);
      if (res.errorMessage != null) {
        errorMessage = res.errorMessage;
        return;
      }
      comics = res.data;
      firstLoading = false;
      update();
    } else {
      firstLoading = false;
      update();
    }
    loading = false;
  }

  void loadNextPage(Future<Res<List<T>>> Function(int) getComics) async {
    if (loading) return;
    loading = true;
    var res = await getComics(current + 1);
    if (res.errorMessage != null) {
      errorMessage = res.errorMessage;
      return;
    }
    comics!.addAll(res.data as List<T>);
    current++;
    update();
    loading = false;
  }
}

abstract class ComicsPage<T> extends StatelessWidget {
  const ComicsPage({super.key});

  String? get tag;

  Future<Res<List<T>>> getComics(int i);

  @override
  Widget build(BuildContext context) {
    Widget body = StateBuilder<ComicsPageLogic<T>>(
      tag: tag,
      controller: ComicsPageLogic<T>(),
      builder: (logic) {
        if (logic.firstLoading) {
          logic.get(getComics);
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
                child: Icon(Icons.error),
              )
            ],
          );
        } else {
          var comics = logic.comics!;
          return CustomScrollView(
            slivers: [
              SliverGrid(
                delegate: SliverChildBuilderDelegate(childCount: comics.length,
                    (context, i) {
                  if (i == comics.length - 1) logic.loadNextPage(getComics);
                  return buildItem(context, comics[i]);
                }),
                gridDelegate: SliverGridDelegateWithComics(),
              ),
              if (logic.current < 44354)
                const SliverToBoxAdapter(
                  child: ListLoadingIndicator(),
                ), //这是个有趣的地方，在不加载最后一个时，是不会调用它的，因为从上到下
            ],
          );
        }
      },
    );
    return body;
  }

  Widget buildItem(BuildContext context, T comic) {
    return JmComicTile(comic as JmComicBrief);
  }
}
