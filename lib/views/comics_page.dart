import 'package:flutter/material.dart';
import 'package:plagiarize/foundation/state_controller.dart';
import 'package:plagiarize/views/widgets/jm_comic_title.dart';
import 'package:plagiarize/views/widgets/list_loading_indicator.dart';
import 'package:plagiarize/views/widgets/sliver_grid_delegate_with.dart';

import '../network/jm_network/jm_models.dart';
import '../network/res.dart';

class ComicsPageLogic<T> extends StateController {
  bool loading = true;
  int current = 1;
  List<T>? comics;
  bool loadingData = false;

  void get(Future<Res<List<T>>> Function(int) getComics) async {
    if (loadingData) return;
    loadingData = true;
    if (comics == null) {
      var res = await getComics(1);
      if (res.errorMessage != null) return;
      comics = res.data;
      loading = false;
      update();
    } else {
      loading = false;
      update();
    }
    loadingData = false;
  }

  void loadNextPage(Future<Res<List<T>>> Function(int) getComic) async {
    if (loadingData) return;
    loadingData = true;
    var res = await getComic(current + 1);
    if (res.errorMessage != null) return;
    comics!.addAll(res.data as List<T>);
    current++;
    update();
    loadingData = false;
  }
}

abstract class ComicsPage<T> extends StatelessWidget {
  const ComicsPage({super.key});

  String? get tag;

  Future<Res<List<T>>> getComics(int i);

  @override
  Widget build(BuildContext context) {
    Widget body = StateBuilder<ComicsPageLogic<T>>(
      init: ComicsPageLogic<T>(),
      tag: tag,
      builder: (logic) {
        if (logic.loading) {
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
              if (logic.current < 100000)
                const SliverToBoxAdapter(
                  child: ListLoadingIndicator(),
                ),
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
