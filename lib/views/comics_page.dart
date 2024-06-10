import 'package:flutter/material.dart';
import 'package:plagiarize/foundation/state_controller.dart';
import 'package:plagiarize/views/widgets/jm_comic_title.dart';
import 'package:plagiarize/views/widgets/sliver_grid_delegate_with.dart';

import '../network/jm_network/jm_models.dart';
import '../network/res.dart';

class ComicsPageLogic<T> extends StateController {
  bool loading = true;
  int current = 1;
  int? maxPage;
  List<T>? comics;
  bool loadingData = false;

  void get(Future<Res<List<T>>> Function(int) getComics) async {
    if (loadingData) return;
    loadingData = true;
    if (comics == null) {
      var res = await getComics(1);
      if (res.errorMessage != null) {
        return;
      } else {
        if (res.data!.isEmpty) maxPage = 1;
      }
      comics = res.data;
      loading = false;
      update();
    } else {
      loading = false;
      update();
    }
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
                  return buildItem(context, comics[i]);
                }),
                gridDelegate: SliverGridDelegateWithComics(),
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
